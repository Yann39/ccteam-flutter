/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/models/news.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static BuildContext buildContext;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  static final initializationSettingsIOS = IOSInitializationSettings();
  static final initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

  /// Function to be executed when a notification is clicked
  /// It navigates to the right page depending on the specified [payload]
  static Future onSelectNotification(String payload) async {
    print("A notification has been clicked, payload is : $payload");
    dynamic jsonData = json.decode(payload);
    if (jsonData['type'] == 'news') {
      print("Navigates to news detail from notification");
      //await navigatorKey.currentState.pushNamed('/newsDetail', arguments: News.fromJson(jsonData['value']));
      Navigator.pushNamed(buildContext, '/newsDetail', arguments: News.fromJson(jsonData['value']));
    } else if (jsonData['type'] == 'event') {
      print("Navigates to event detail from notification");
      //await ChachatteTeamApp.navigatorKey.currentState.pushNamed('/eventDetail', arguments: Event.fromJson(jsonData['value']));
      await Navigator.pushNamed(buildContext, '/eventDetail', arguments: Event.fromJson(jsonData['value']));
    }
  }

  /// Initialize the notifications plugin
  /// This must be called before any other methods call of this class
  static void initialize(BuildContext context) {
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    buildContext = context;
  }

  /// Push a new notification instantly for the specified [news]
  static Future pushInstantNewsNotification(News news) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'news',
      'News push notifications',
      'Push notifications for news',
      importance: Importance.Max,
      priority: Priority.High,
      color: Colors.blue[700],
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    Map<String, dynamic> param = {
      "type": "news",
      "value": news != null ? news.toJson() : null,
    };

    await flutterLocalNotificationsPlugin.show(
      news.id,
      news.title,
      news.catchLine,
      platformChannelSpecifics,
      payload: json.encode(param),
    );
  }

  /// Schedule an event notification for the specified [event]
  /// The notification will be sent 6 hours before the event start date
  static Future scheduleEventNotification(Event event) async {
    var scheduledNotificationDateTime = event.startDate.subtract(Duration(hours: 6));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'track_events',
      'Track events push notifications',
      'Push notifications for track events, 6 hours before the start of the event',
      importance: Importance.Max,
      priority: Priority.High,
      color: Colors.blue[700],
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    Map<String, dynamic> param = {
      "type": "event",
      "value": event != null ? event.toJson() : null,
    };

    await flutterLocalNotificationsPlugin.schedule(
      event.id,
      'Événement prévu dans 6 heures !',
      event.title,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: json.encode(param),
      androidAllowWhileIdle: true,
    );
  }
}
