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

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/home_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/member_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/providers/passcode_provider.dart';
import 'package:ccteam/providers/photo_provider.dart';
import 'package:ccteam/providers/record_provider.dart';
import 'package:ccteam/providers/timer_provider.dart';
import 'package:ccteam/providers/track_provider.dart';
import 'package:ccteam/services/notifications_service.dart';
import 'package:ccteam/ui/events/add_edit_event.dart';
import 'package:ccteam/ui/events/event_detail.dart';
import 'package:ccteam/ui/main/edit_avatar.dart';
import 'package:ccteam/ui/main/home.dart';
import 'package:ccteam/ui/main/image_crop.dart';
import 'package:ccteam/ui/members/add_edit_member.dart';
import 'package:ccteam/ui/members/add_edit_record.dart';
import 'package:ccteam/ui/members/member_chronos.dart';
import 'package:ccteam/ui/members/member_detail.dart';
import 'package:ccteam/ui/members/member_events.dart';
import 'package:ccteam/ui/news/add_edit_news.dart';
import 'package:ccteam/ui/news/news_detail.dart';
import 'package:ccteam/ui/photos/add_edit_photo.dart';
import 'package:ccteam/ui/photos/gallery.dart';
import 'package:ccteam/ui/photos/photo_detail.dart';
import 'package:ccteam/ui/tracks/track_detail.dart';
import 'package:ccteam/ui/unauthenticated/forgot_password.dart';
import 'package:ccteam/ui/unauthenticated/loading.dart';
import 'package:ccteam/ui/unauthenticated/login.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() {
  // logging configuration
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint('${rec.loggerName.padRight(18)} - ${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AvatarProvider()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (context) => PhotoProvider()),
        ChangeNotifierProvider(create: (context) => TrackProvider()),
        ChangeNotifierProvider(create: (context) => RecordProvider()),
        ChangeNotifierProvider(create: (context) => PasscodeProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        // so that we can set messages from login provider
        ChangeNotifierProxyProvider<MessageProvider, LoginProvider>(
          create: (context) => LoginProvider(),
          update: (context, messageProvider, loginProvider) => loginProvider..updateMessageProvider(messageProvider),
        ),
        // so that we can set messages and logout user from NewsListProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, NewsListProvider>(
          create: (context) => NewsListProvider(),
          update: (context, messageProvider, loginProvider, newsListProvider) => newsListProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from NewsDetailProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, NewsDetailProvider>(
          create: (context) => NewsDetailProvider(),
          update: (context, messageProvider, loginProvider, newsDetailProvider) => newsDetailProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from NewsCreationProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, NewsCreationProvider>(
          create: (context) => NewsCreationProvider(),
          update: (context, messageProvider, loginProvider, newsCreationProvider) => newsCreationProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventListProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, EventListProvider>(
          create: (context) => EventListProvider(),
          update: (context, messageProvider, loginProvider, eventListProvider) => eventListProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventDetailProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, EventDetailProvider>(
          create: (context) => EventDetailProvider(),
          update: (context, messageProvider, loginProvider, eventDetailProvider) => eventDetailProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventCreationProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, EventCreationProvider>(
          create: (context) => EventCreationProvider(),
          update: (context, messageProvider, loginProvider, eventCreationProvider) => eventCreationProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberListProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, MemberListProvider>(
          create: (context) => MemberListProvider(),
          update: (context, messageProvider, loginProvider, memberListProvider) => memberListProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberDetailProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, MemberDetailProvider>(
          create: (context) => MemberDetailProvider(),
          update: (context, messageProvider, loginProvider, memberDetailProvider) => memberDetailProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberCreationProvider
        ChangeNotifierProxyProvider2<MessageProvider, LoginProvider, MemberCreationProvider>(
          create: (context) => MemberCreationProvider(),
          update: (context, messageProvider, loginProvider, memberCreationProvider) => memberCreationProvider
            ..updateMessageProvider(messageProvider)
            ..updateLoginProvider(loginProvider),
        ),
      ],
      child: CCTeamApp(),
    ),
  );
}

class CCTeamApp extends StatelessWidget {
  final Logger _log = new Logger('CCTeamApp');

  @override
  Widget build(BuildContext context) {
    _log.info("Building CCTeamApp...");

    // initialize notifications plugin
    NotificationsService.initialize(context);

    return GraphQLProvider(
      client: GraphQLConnection().client,
      child: MaterialApp(
        title: AppString.applicationTitle,
        initialRoute: '/',
        routes: {
          '/forgotPassword': (context) => ForgotPassword(),
          '/imageCrop': (context) => ImageCrop(),
          '/gallery': (context) => Gallery(title: ModalRoute.of(context).settings.arguments),
          '/editAvatar': (context) => EditAvatar(member: ModalRoute.of(context).settings.arguments),
          '/addEditNews': (context) => AddEditNews(),
          '/addEditEvent': (context) => AddEditEvent(),
          '/addEditMember': (context) => AddEditMember(),
          '/addEditPhoto': (context) => AddEditPhoto(photo: ModalRoute.of(context).settings.arguments),
          '/addEditRecord': (context) => AddEditRecord(record: ModalRoute.of(context).settings.arguments),
          '/newsDetail': (context) => NewsDetail(),
          '/eventDetail': (context) => EventDetail(),
          '/memberDetail': (context) => MemberDetail(),
          '/memberEvents': (context) => MemberEvents(member: ModalRoute.of(context).settings.arguments),
          '/memberChronos': (context) => MemberChronos(member: ModalRoute.of(context).settings.arguments),
          '/photoDetail': (context) => PhotoDetail(photo: ModalRoute.of(context).settings.arguments),
          '/trackDetail': (context) => TrackDetail(track: ModalRoute.of(context).settings.arguments),
        },
        home: Consumer2<LoginProvider, MessageProvider>(
          builder: (context, loginProvider, messageProvider, child) {
            // if an error message is set in the message provider, display it in a dialog
            if (messageProvider.message != null) {
              // to prevent calling setState() during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final Color notificationColor = messageProvider.messageType == MessageType.ERROR
                    ? Color(0xFFB43636)
                    : messageProvider.messageType == MessageType.WARNING
                        ? Color(0xFFC9922D)
                        : messageProvider.messageType == MessageType.SUCCESS
                            ? Color(0xFF42914A)
                            : Color(0xFF2368AF);
                final String notificationTitle = messageProvider.messageType == MessageType.ERROR
                    ? "Erreur"
                    : messageProvider.messageType == MessageType.WARNING
                        ? "Attention"
                        : messageProvider.messageType == MessageType.SUCCESS
                            ? "Succès"
                            : "Information";
                final IconData notificationIcon = messageProvider.messageType == MessageType.ERROR
                    ? Icons.error_outline
                    : messageProvider.messageType == MessageType.WARNING
                        ? Icons.warning_amber_rounded
                        : messageProvider.messageType == MessageType.SUCCESS
                            ? Icons.check_circle_outline
                            : Icons.info_outline;
                final snackBar = SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  showCloseIcon: true,
                  closeIconColor: Colors.white,
                  backgroundColor: notificationColor,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  duration: Duration(minutes: 1),
                  content: Row(
                    children: [
                      Icon(notificationIcon, color: Colors.white, size: 35),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notificationTitle, textScaleFactor: 1.3),
                            SizedBox(height: 8),
                            Text(messageProvider.message, textScaleFactor: 0.9),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                messageProvider.clearMessage();
              });
            }
            switch (loginProvider.authStatus) {
              case AuthStatus.Initializing:
              case AuthStatus.Authenticating:
                _log.info("Going to loading page...");
                return Loading();
              case AuthStatus.Unauthenticated:
                _log.info("Going to login page...");
                return Login();
              case AuthStatus.Authenticated:
                _log.info("Going to home page...");
                return Home();
            }
            return Text("Unknown authentication status");
          },
        ),
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFD32F2F, {
            50: Color(0xFFFFEBEE),
            100: Color(0xFFFFCDD2),
            200: Color(0xFFEF9A9A),
            300: Color(0xFFE57373),
            400: Color(0xFFEF5350),
            500: Color(0xFFF44336),
            600: Color(0xFFE53935),
            700: Color(0xFFD32F2F),
            800: Color(0xFFC62828),
            900: Color(0xFFB71C1C),
          }),
          primaryColor: Colors.red[700], // main top bar and other stuff
        ),
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('fr', 'FR'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
