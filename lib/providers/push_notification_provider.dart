/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A delay before an event's start at which a reminder notification can be sent.
/// The [key]s must match the backend catalog (`ReminderOffset` in ccteam-graphql),
/// each (event, offset) pair has its own FCM topic (`event-{id}-{key}`).
class ReminderOffset {
  final String key;
  final String label;

  const ReminderOffset(this.key, this.label);

  /// Catalog of the selectable offsets, in display order.
  static const List<ReminderOffset> all = [
    ReminderOffset('1h', AppString.notificationsOffset1h),
    ReminderOffset('12h', AppString.notificationsOffset12h),
    ReminderOffset('1d', AppString.notificationsOffset1d),
    ReminderOffset('2d', AppString.notificationsOffset2d),
    ReminderOffset('1w', AppString.notificationsOffset1w),
  ];
}

/// Keeps the Firebase Cloud Messaging topic subscriptions in sync with the
/// login state, the logged member's event registrations and the user's
/// notification preferences (set in the notification settings page, stored
/// per device in the shared preferences).
///
/// Members (and admins) are subscribed to:
///  - the [topicNews] topic when they enabled news notifications, notified
///    when a news is published,
///  - when they enabled event reminders, one `event-{id}-{offset}` topic per
///    upcoming event they are registered to and per reminder offset they
///    selected ([ReminderOffset.all]), so only the participants of an event
///    receive its reminders, and only at the delays they asked for.
///
/// The sync is a diff between the desired topics and the topics currently
/// subscribed. Registering to or leaving an event refreshes the logged
/// member, which lands here through the proxy provider and adjusts the
/// subscriptions; changing a preference re-syncs immediately; everything is
/// unsubscribed on logout. The topic names must match the ones the backend
/// sends to (`PushNotificationService` in ccteam-graphql).
///
/// Known limit: the diff is tracked per app session, so a registration
/// removed from another device (or by an admin) only stops this device's
/// reminders after the next logged-member refresh on this device.
///
/// Notifications received while the app is in the background (or closed) are
/// displayed by the system automatically. Foreground messages are not, so we
/// surface them through the existing global [MessageProvider] snackbar.
class PushNotificationProvider extends ChangeNotifier {
  static const String topicNews = 'news';

  /// Prefix of the per-event reminder topics: `event-{id}-{offset key}`.
  static const String topicEventPrefix = 'event-';

  // shared preferences keys for the notification choices (per device)
  static const String _prefNewsEnabled = 'notifNewsEnabled';
  static const String _prefEventRemindersEnabled = 'notifEventRemindersEnabled';
  static const String _prefEventReminderOffsets = 'notifEventReminderOffsets';

  final Logger _log = new Logger('PushNotificationProvider');

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider, kept so the
  // desired topics can be recomputed when a preference changes
  LoginProvider? _loginProvider;

  // notification preferences, the defaults (everything on, reminder one day
  // before) apply on fresh installs and mirror the historical behavior
  bool _newsEnabled = true;
  bool _eventRemindersEnabled = true;
  Set<String> _selectedOffsetKeys = {'1d'};

  // preferences are loaded asynchronously from the shared preferences, no
  // subscription is touched before they are known
  bool _preferencesLoaded = false;

  // topics subscribed by this provider and not unsubscribed yet, used to
  // compute the diff against the desired topics and to clean up on logout
  final Set<String> _subscribedTopics = {};

  // topics that should be subscribed given the current login state and preferences
  Set<String> _desiredTopics = {};

  // whether the notification permission has already been requested
  bool _permissionRequested = false;

  // serialize the syncs, LoginProvider notifies often and FCM calls are async
  bool _syncing = false;
  bool _resyncNeeded = false;

  // subscription to the foreground messages stream
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  PushNotificationProvider() {
    _loadPreferences();
  }

  /// Whether a notification is sent when a news is published.
  bool get newsEnabled => _newsEnabled;

  /// Whether reminders are sent before the events the member is registered to.
  bool get eventRemindersEnabled => _eventRemindersEnabled;

  /// Keys of the selected reminder offsets (see [ReminderOffset.all]).
  Set<String> get selectedOffsetKeys => Set.unmodifiable(_selectedOffsetKeys);

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
  }

  /// Update login provider with the specified [loginProvider].
  ///
  /// Recomputes the desired topics from the login state and schedules a
  /// subscription sync. Called by the proxy provider every time the login
  /// provider notifies (login, logout, logged member refresh after an event
  /// registration...), so it must stay cheap and idempotent.
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _refreshDesiredTopics();
  }

  /// Enable or disable the notification sent when a news is published.
  Future<void> setNewsEnabled(bool enabled) async {
    _newsEnabled = enabled;
    await _savePreferences();
    _refreshDesiredTopics();
    notifyListeners();
  }

  /// Enable or disable the reminders sent before the events the member is
  /// registered to.
  Future<void> setEventRemindersEnabled(bool enabled) async {
    _eventRemindersEnabled = enabled;
    await _savePreferences();
    _refreshDesiredTopics();
    notifyListeners();
  }

  /// Select or deselect the reminder offset identified by [key].
  Future<void> setOffsetSelected(String key, bool selected) async {
    if (selected) {
      _selectedOffsetKeys.add(key);
    } else {
      _selectedOffsetKeys.remove(key);
    }
    await _savePreferences();
    _refreshDesiredTopics();
    notifyListeners();
  }

  /// Load the notification preferences from the shared preferences, then
  /// trigger the initial topic sync.
  Future<void> _loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _newsEnabled = prefs.getBool(_prefNewsEnabled) ?? true;
      _eventRemindersEnabled = prefs.getBool(_prefEventRemindersEnabled) ?? true;
      final List<String>? offsets = prefs.getStringList(_prefEventReminderOffsets);
      if (offsets != null) {
        _selectedOffsetKeys = offsets.toSet();
      }
    } catch (error) {
      _log.warning("Failed to load the notification preferences, using defaults ($error)");
    }
    _preferencesLoaded = true;
    _refreshDesiredTopics();
    notifyListeners();
  }

  /// Persist the notification preferences in the shared preferences.
  Future<void> _savePreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefNewsEnabled, _newsEnabled);
      await prefs.setBool(_prefEventRemindersEnabled, _eventRemindersEnabled);
      await prefs.setStringList(_prefEventReminderOffsets, _selectedOffsetKeys.toList());
    } catch (error) {
      _log.warning("Failed to save the notification preferences ($error)");
    }
  }

  /// Recompute the desired topics and schedule a subscription sync.
  void _refreshDesiredTopics() {
    // Firebase did not initialize (e.g. missing google-services.json),
    // notifications are simply unavailable
    if (Firebase.apps.isEmpty) {
      return;
    }
    _desiredTopics = _computeDesiredTopics();
    _scheduleSync();
  }

  /// Topics the device should be subscribed to according to the login state
  /// and the notification preferences. Empty when nobody is logged in, the
  /// logged user is not a member, or the preferences are not loaded yet.
  Set<String> _computeDesiredTopics() {
    final LoginProvider? loginProvider = _loginProvider;
    if (!_preferencesLoaded || loginProvider == null || !loginProvider.isMember) {
      return {};
    }
    final Set<String> topics = {};
    if (_newsEnabled) {
      topics.add(topicNews);
    }
    if (_eventRemindersEnabled && _selectedOffsetKeys.isNotEmpty) {
      final DateTime now = DateTime.now();
      for (final EventMember eventMember in loginProvider.loggedMember?.eventMembers ?? const <EventMember>[]) {
        final int? eventId = eventMember.event?.id;
        final DateTime? startDate = eventMember.event?.startDate;
        // past events are excluded (their reminders already fired), which also
        // unsubscribes an event's topics on the first sync after it started
        if (eventId != null && startDate != null && startDate.isAfter(now)) {
          for (final String key in _selectedOffsetKeys) {
            topics.add('$topicEventPrefix$eventId-$key');
          }
        }
      }
    }
    return topics;
  }

  /// Run a sync now, or remember to run another one if a sync is already in
  /// progress (the desired topics may have changed in between).
  void _scheduleSync() {
    if (_syncing) {
      _resyncNeeded = true;
      return;
    }
    _syncing = true;
    _sync().whenComplete(() {
      _syncing = false;
      if (_resyncNeeded) {
        _resyncNeeded = false;
        _scheduleSync();
      }
    });
  }

  /// Subscribe/unsubscribe the difference between the desired topics and the
  /// currently subscribed ones, and keep the foreground-message listener
  /// active only while at least one topic is subscribed.
  Future<void> _sync() async {
    final Set<String> desired = Set.of(_desiredTopics);
    final Set<String> toSubscribe = desired.difference(_subscribedTopics);
    final Set<String> toUnsubscribe = _subscribedTopics.difference(desired);

    if (toSubscribe.isNotEmpty || toUnsubscribe.isNotEmpty) {
      try {
        // ask for the notification permission the first time we are about to subscribe to something
        if (desired.isNotEmpty && !_permissionRequested) {
          _permissionRequested = true;
          final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
          _log.info("Notification permission status: ${settings.authorizationStatus}");
        }

        // the tracked set is updated after each call, so a failure halfway
        // through leaves it accurate and the next sync retries the rest
        for (final String topic in toSubscribe) {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          _subscribedTopics.add(topic);
        }
        for (final String topic in toUnsubscribe) {
          await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
          _subscribedTopics.remove(topic);
        }
        _log.info("Notification topics synced: $_subscribedTopics");
      } catch (error) {
        // notification plumbing must never break the app, just log, the next
        // login state change will retry the remaining diff
        _log.warning("Failed to sync the notification topics ($error)");
      }
    }

    // notifications received while the app is in the foreground are not
    // displayed by the system, show them with the in-app snackbar instead
    if (_subscribedTopics.isNotEmpty) {
      _onMessageSubscription ??= FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final String? title = message.notification?.title;
        final String? body = message.notification?.body;
        _log.info("Push notification received in foreground: $title");
        if (title != null || body != null) {
          _messageProvider.setMessage([title, body].whereType<String>().join("\n"), MessageType.INFO);
        }
      });
    } else {
      await _onMessageSubscription?.cancel();
      _onMessageSubscription = null;
    }
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    super.dispose();
  }
}
