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

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/push_notification_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Notification preferences page, reachable from the drawer.
///
/// The choices are stored per device and applied immediately by [PushNotificationProvider],
/// which adjusts the FCM topic subscriptions.
class NotificationSettings extends StatelessWidget {
  const NotificationSettings({Key? key}) : super(key: key);

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
