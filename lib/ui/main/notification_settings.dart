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

import 'package:app_settings/app_settings.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/push_notification_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Notification preferences page, reachable from the drawer.
///
/// The choices are stored per device and applied immediately by
/// [PushNotificationProvider], which adjusts the FCM topic subscriptions.
/// The page also surfaces a warning when the OS notification permission is
/// not granted, since in that case nothing is displayed regardless of the
/// preferences below.
class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> with WidgetsBindingObserver {
  // last known OS notification authorization status (null while unknown or when Firebase is unavailable)
  AuthorizationStatus? _authStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // re-check when coming back to the app, e.g. after the user toggled the
    // permission in the system settings
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
    }
  }

  /// Read the current OS notification authorization status from FCM.
  Future<void> _refreshPermissionStatus() async {
    if (Firebase.apps.isEmpty) return;
    try {
      // note: `final` (not the explicit type) on purpose — the FCM class is also
      // named NotificationSettings and would clash with this widget's name
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (mounted) setState(() => _authStatus = settings.authorizationStatus);
    } catch (_) {
      // notifications simply unavailable, leave the banner hidden
    }
  }

  /// Ask for the permission again; if the system won't reprompt (permission
  /// permanently denied), fall back to opening the OS app settings so the
  /// user can enable it manually. Refreshes the displayed status afterwards.
  Future<void> _enableNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      final bool granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
    } catch (_) {
      // best effort, just try to open the settings
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
    await _refreshPermissionStatus();
  }

  /// Whether the OS currently blocks notifications for the app.
  bool get _notificationsBlocked =>
      _authStatus != null &&
      _authStatus != AuthorizationStatus.authorized &&
      _authStatus != AuthorizationStatus.provisional;

  /// Warning card shown when the OS permission is missing.
  Widget _buildPermissionWarning() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange[300]!, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.orange[50],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange[700]!.withValues(alpha: 0.15)),
                child: Icon(Icons.notifications_off, color: Colors.orange[700], size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppString.notificationsPermissionDeniedTitle,
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      AppString.notificationsPermissionDeniedMessage,
                      style: TextStyle(color: Colors.black.withAlpha(180), fontSize: 12.5, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _enableNotifications,
              icon: const Icon(Icons.settings, size: 18.0),
              label: Text(AppString.notificationsPermissionEnableButton),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!_loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.notifications),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    final PushNotificationProvider _pushNotificationProvider = Provider.of<PushNotificationProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.notifications),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: ListView(
          children: <Widget>[
            const InfoBanner(message: AppString.notificationsHelp),
            const SizedBox(height: 8.0),
            // OS permission warning, only when notifications are blocked by the system
            if (_notificationsBlocked) ...[_buildPermissionWarning(), const SizedBox(height: 8.0)],
            // news notifications on/off
            Container(
              decoration: CustomDecorations.cardLight,
              child: SwitchListTile(
                title: const Text(AppString.notificationsNewsLabel),
                subtitle: const Text(AppString.notificationsNewsSubtitle),
                secondary: Icon(Icons.article, color: Colors.indigo[600]),
                value: _pushNotificationProvider.newsEnabled,
                onChanged: (bool value) => _pushNotificationProvider.setNewsEnabled(value),
              ),
            ),
            const SizedBox(height: 8.0),
            // event reminders on/off + selection of the reminder delays
            Container(
              decoration: CustomDecorations.cardLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SwitchListTile(
                    title: const Text(AppString.notificationsEventsLabel),
                    subtitle: const Text(AppString.notificationsEventsSubtitle),
                    secondary: Icon(Icons.event, color: Colors.purple[600]),
                    value: _pushNotificationProvider.eventRemindersEnabled,
                    onChanged: (bool value) => _pushNotificationProvider.setEventRemindersEnabled(value),
                  ),
                  if (_pushNotificationProvider.eventRemindersEnabled) ...[
                    Divider(height: 1, thickness: 1, color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                      child: Text(
                        AppString.notificationsEventDelaysLabel,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final ReminderOffset offset in ReminderOffset.all)
                      CheckboxListTile(
                        title: Text(offset.label),
                        value: _pushNotificationProvider.selectedOffsetKeys.contains(offset.key),
                        onChanged: (bool? value) =>
                            _pushNotificationProvider.setOffsetSelected(offset.key, value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    const SizedBox(height: 4.0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
