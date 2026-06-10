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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Keeps the Firebase Cloud Messaging topic subscriptions in sync with the
/// login state and the logged member's event registrations.
///
/// Members (and admins) are subscribed to:
///  - the [topicNews] topic, notified when a news is published,
///  - one `event-{id}` topic per upcoming event they are registered to,
///    notified when that event starts in less than 24 hours — so only the
///    participants of an event receive its reminder.
///
/// The sync is a diff between the desired topics (computed from the logged
/// member) and the topics currently subscribed. Registering to or leaving an
/// event refreshes the logged member, which lands here through the proxy
/// provider and adjusts the subscriptions; everything is unsubscribed on
/// logout. The topic names must match the ones the backend sends to
/// (`PushNotificationService` in ccteam-graphql).
///
/// Known limit: the diff is tracked per app session, so a registration
/// removed from another device (or by an admin) only stops this device's
/// reminder after the next logged-member refresh on this device.
///
/// Notifications received while the app is in the background (or closed) are
/// displayed by the system automatically. Foreground messages are not, so we
/// surface them through the existing global [MessageProvider] snackbar.
class PushNotificationProvider extends ChangeNotifier {
  static const String topicNews = 'news';

  /// Prefix of the per-event topics, followed by the event id.
  static const String topicEventPrefix = 'event-';

  final Logger _log = new Logger('PushNotificationProvider');

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // topics subscribed by this provider and not unsubscribed yet, used to
  // compute the diff against the desired topics and to clean up on logout
  final Set<String> _subscribedTopics = {};

  // topics that should be subscribed given the current login state
  Set<String> _desiredTopics = {};

  // whether the notification permission has already been requested
  bool _permissionRequested = false;

  // serialize the syncs, LoginProvider notifies often and FCM calls are async
  bool _syncing = false;
  bool _resyncNeeded = false;

  // subscription to the foreground messages stream
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

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
    // Firebase did not initialize (e.g. missing google-services.json),
    // notifications are simply unavailable
    if (Firebase.apps.isEmpty) {
      return;
    }
    _desiredTopics = _computeDesiredTopics(loginProvider);
    _scheduleSync();
  }

  /// Topics the device should be subscribed to: the news topic plus one
  /// topic per upcoming event the logged member is registered to. Empty when
  /// nobody is logged in or the logged user is not a member.
  Set<String> _computeDesiredTopics(LoginProvider loginProvider) {
    if (!loginProvider.isMember) {
      return {};
    }
    final Set<String> topics = {topicNews};
    final DateTime now = DateTime.now();
    for (final EventMember eventMember in loginProvider.loggedMember?.eventMembers ?? const <EventMember>[]) {
      final int? eventId = eventMember.event?.id;
      final DateTime? startDate = eventMember.event?.startDate;
      // past events are excluded (their reminder already fired), which also
      // unsubscribes an event's topic on the first sync after it started
      if (eventId != null && startDate != null && startDate.isAfter(now)) {
        topics.add('$topicEventPrefix$eventId');
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
