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

import 'dart:convert';

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/news.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static BuildContext buildContext;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  static final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  static final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  static final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);

  /// Initialize the notifications plugin
  /// This must be called before any other methods call of this class
  static Future<void> initialize(BuildContext context) async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    buildContext = context;
  }

  static void onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: buildContext,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              print("A notification has been clicked, payload is : $payload");
              dynamic jsonData = json.decode(payload);
              if (jsonData['type'] == 'news') {
                print("Navigates to news detail from notification");
                //await navigatorKey.currentState.pushNamed('/newsDetail', arguments: News.fromJson(jsonData['value']));
                Navigator.pushNamed(buildContext, '/newsDetail');
              } else if (jsonData['type'] == 'event') {
                print("Navigates to event detail from notification");
                //await CCTeamApp.navigatorKey.currentState.pushNamed('/eventDetail', arguments: Event.fromJson(jsonData['value']));
                Navigator.pushNamed(buildContext, '/eventDetail', arguments: Event.fromJson(jsonData['value']));
              }
            },
          )
        ],
      ),
    );
  }

  /// Function to be executed when a notification is clicked
  /// It navigates to the right page depending on the specified [payload]
  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    print("A notification has been clicked, payload is : $notificationResponse.payload");
    dynamic jsonData = json.decode(notificationResponse.payload);
    if (jsonData['type'] == 'news') {
      print("Navigates to news detail from notification");
      //await navigatorKey.currentState.pushNamed('/newsDetail', arguments: News.fromJson(jsonData['value']));
      Navigator.pushNamed(buildContext, '/newsDetail');
    } else if (jsonData['type'] == 'event') {
      print("Navigates to event detail from notification");
      //await CCTeamApp.navigatorKey.currentState.pushNamed('/eventDetail', arguments: Event.fromJson(jsonData['value']));
      await Navigator.pushNamed(buildContext, '/eventDetail', arguments: Event.fromJson(jsonData['value']));
    }
  }

  /// Push a new notification instantly for the specified [news]
  static void pushInstantNewsNotification(News news) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'news', 'News push notifications',
        channelDescription: 'Push notifications for news',
        importance: Importance.max,
        priority: Priority.high,
        color: Colors.blue[700],
        ticker: 'ticker');

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    final Map<String, dynamic> param = {
      "type": "news",
      "value": news != null ? news.toJson() : null,
    };

    await flutterLocalNotificationsPlugin.show(
      news.id,
      news.title,
      news.catchLine,
      notificationDetails,
      payload: json.encode(param),
    );
  }

  /// Schedule an event notification for the specified [event]
  /// The notification will be sent 6 hours before the event start date
  static void scheduleEventNotification(Event event) async {
    final DateTime scheduledNotificationDateTime = event.startDate.subtract(Duration(hours: 6));
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'track_events',
      'Track events push notifications',
      channelDescription: 'Push notifications for track events, 6 hours before the start of the event',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.blue[700],
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    final Map<String, dynamic> param = {
      "type": "event",
      "value": event != null ? event.toJson() : null,
    };

    await flutterLocalNotificationsPlugin.zonedSchedule(
      event.id,
      'Événement prévu dans 6 heures !',
      event.title,
      scheduledNotificationDateTime,
      notificationDetails,
      payload: json.encode(param),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
