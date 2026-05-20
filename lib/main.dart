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
import 'package:ccteam/providers/bike_list_provider.dart';
import 'package:ccteam/providers/change_passcode_provider.dart';
import 'package:ccteam/providers/country_list_provider.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/home_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/providers/organizer_list_provider.dart';
import 'package:ccteam/providers/passcode_provider.dart';
import 'package:ccteam/providers/photo_detail_provider.dart';
import 'package:ccteam/providers/photo_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/providers/record_detail_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/timer_provider.dart';
import 'package:ccteam/providers/track_creation_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/ui/events/add_edit_event.dart';
import 'package:ccteam/ui/events/event_detail.dart';
import 'package:ccteam/ui/laprecord/add_edit_record.dart';
import 'package:ccteam/ui/laprecord/chrono_detail.dart';
import 'package:ccteam/ui/laprecord/member_chronos.dart';
import 'package:ccteam/ui/main/about.dart';
import 'package:ccteam/ui/main/change_passcode.dart';
import 'package:ccteam/ui/main/edit_avatar.dart';
import 'package:ccteam/ui/main/home.dart';
import 'package:ccteam/ui/main/image_crop.dart';
import 'package:ccteam/ui/main/my_account.dart';
import 'package:ccteam/ui/members/add_edit_bike.dart';
import 'package:ccteam/ui/members/add_edit_member.dart';
import 'package:ccteam/ui/members/add_edit_membership_fee.dart';
import 'package:ccteam/ui/members/member_detail.dart';
import 'package:ccteam/ui/members/member_events.dart';
import 'package:ccteam/ui/members/member_list.dart';
import 'package:ccteam/ui/members/my_bikes.dart';
import 'package:ccteam/ui/members/select_event_to_join.dart';
import 'package:ccteam/ui/news/add_edit_news.dart';
import 'package:ccteam/ui/news/news_detail.dart';
import 'package:ccteam/ui/news/news_list.dart';
import 'package:ccteam/ui/photos/gallery.dart';
import 'package:ccteam/ui/photos/photo_detail.dart';
import 'package:ccteam/ui/tracks/add_edit_track.dart';
import 'package:ccteam/ui/tracks/track_detail.dart';
import 'package:ccteam/ui/unauthenticated/loading.dart';
import 'package:ccteam/ui/unauthenticated/login.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:ccteam/utils/navigator_key.dart';
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
    debugPrint(
      '${rec.loggerName.padRight(18)} - ${rec.level.name}: ${rec.time}: ${rec.message}',
    );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => PhotoProvider()),
        ChangeNotifierProvider(create: (context) => PasscodeProvider()),
        ChangeNotifierProvider(create: (context) => ChangePasscodeProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        // so that we can set messages from login provider
        ChangeNotifierProxyProvider<MessageProvider, LoginProvider>(
          create: (context) => LoginProvider(),
          update: (context, messageProvider, loginProvider) =>
              loginProvider!..updateMessageProvider(messageProvider),
        ),
        // so that we can check member role from RecordListProvider
        ChangeNotifierProxyProvider<LoginProvider, RecordListProvider>(
          create: (context) => RecordListProvider(),
          update: (context, loginProvider, recordListProvider) =>
              recordListProvider!..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from NewsListProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          NewsListProvider
        >(
          create: (context) => NewsListProvider(),
          update: (context, messageProvider, loginProvider, newsListProvider) =>
              newsListProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from NewsDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          NewsDetailProvider
        >(
          create: (context) => NewsDetailProvider(),
          update:
              (context, messageProvider, loginProvider, newsDetailProvider) =>
                  newsDetailProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from NewsCreationProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          NewsCreationProvider
        >(
          create: (context) => NewsCreationProvider(),
          update:
              (context, messageProvider, loginProvider, newsCreationProvider) =>
                  newsCreationProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          BikeListProvider
        >(
          create: (context) => BikeListProvider(),
          update: (context, messageProvider, loginProvider, bikeListProvider) =>
              bikeListProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // organizer list — populated lazily on first event-form open
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          OrganizerListProvider
        >(
          create: (context) => OrganizerListProvider(),
          update:
              (
                context,
                messageProvider,
                loginProvider,
                organizerListProvider,
              ) => organizerListProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventListProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          EventListProvider
        >(
          create: (context) => EventListProvider(),
          update:
              (context, messageProvider, loginProvider, eventListProvider) =>
                  eventListProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          EventDetailProvider
        >(
          create: (context) => EventDetailProvider(),
          update:
              (context, messageProvider, loginProvider, eventDetailProvider) =>
                  eventDetailProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from EventCreationProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          EventCreationProvider
        >(
          create: (context) => EventCreationProvider(),
          update:
              (
                context,
                messageProvider,
                loginProvider,
                eventCreationProvider,
              ) => eventCreationProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberListProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          MemberListProvider
        >(
          create: (context) => MemberListProvider(),
          update:
              (context, messageProvider, loginProvider, memberListProvider) =>
                  memberListProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          MemberDetailProvider
        >(
          create: (context) => MemberDetailProvider(),
          update:
              (context, messageProvider, loginProvider, memberDetailProvider) =>
                  memberDetailProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from MemberCreationProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          MemberCreationProvider
        >(
          create: (context) => MemberCreationProvider(),
          update:
              (
                context,
                messageProvider,
                loginProvider,
                memberCreationProvider,
              ) => memberCreationProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from AvatarProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          AvatarProvider
        >(
          create: (context) => AvatarProvider(),
          update: (context, messageProvider, loginProvider, avatarProvider) =>
              avatarProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from TrackListProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          TrackListProvider
        >(
          create: (context) => TrackListProvider(),
          update:
              (context, messageProvider, loginProvider, trackListProvider) =>
                  trackListProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from TrackDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          TrackDetailProvider
        >(
          create: (context) => TrackDetailProvider(),
          update:
              (context, messageProvider, loginProvider, trackDetailProvider) =>
                  trackDetailProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from TrackCreationProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          TrackCreationProvider
        >(
          create: (context) => TrackCreationProvider(),
          update:
              (
                context,
                messageProvider,
                loginProvider,
                trackCreationProvider,
              ) => trackCreationProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // country list, populated lazily on first track-form open
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          CountryListProvider
        >(
          create: (context) => CountryListProvider(),
          update:
              (context, messageProvider, loginProvider, countryListProvider) =>
                  countryListProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from RecordCreationProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          RecordCreationProvider
        >(
          create: (context) => RecordCreationProvider(),
          update:
              (
                context,
                messageProvider,
                loginProvider,
                recordCreationProvider,
              ) => recordCreationProvider!
                ..updateMessageProvider(messageProvider)
                ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from RecordDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          RecordDetailProvider
        >(
          create: (context) => RecordDetailProvider(),
          update:
              (context, messageProvider, loginProvider, recordDetailProvider) =>
                  recordDetailProvider!
                    ..updateMessageProvider(messageProvider)
                    ..updateLoginProvider(loginProvider),
        ),
        // so that we can set messages and logout user from PhotoDetailProvider
        ChangeNotifierProxyProvider2<
          MessageProvider,
          LoginProvider,
          PhotoDetailProvider
        >(
          create: (context) => PhotoDetailProvider(),
          update:
              (context, messageProvider, loginProvider, photoDetailProvider) =>
                  photoDetailProvider!
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

    return GraphQLProvider(
      client: GraphQLConnection().client,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: AppString.applicationTitle,
        initialRoute: '/',
        routes: {
          '/imageCrop': (context) => ImageCrop(),
          '/gallery': (context) => Gallery(),
          '/editAvatar': (context) => EditAvatar(),
          '/myAccount': (context) => MyAccount(),
          '/changePasscode': (context) => ChangePasscode(),
          '/about': (context) => const About(),
          '/addEditNews': (context) => AddEditNews(),
          '/addEditEvent': (context) => AddEditEvent(),
          '/addEditMember': (context) => AddEditMember(),
          '/addEditRecord': (context) => AddEditRecord(),
          '/chronoDetail': (context) => const ChronoDetail(),
          '/newsList': (context) => NewsList(),
          '/newsDetail': (context) => NewsDetail(),
          '/eventDetail': (context) => EventDetail(),
          '/memberDetail': (context) => MemberDetail(),
          '/myBikes': (context) => MyBikes(),
          '/addEditBike': (context) => AddEditBike(),
          '/members': (context) => MemberList(),
          '/memberEvents': (context) => MemberEvents(),
          '/selectEventToJoin': (context) => SelectEventToJoin(),
          '/memberChronos': (context) => MemberChronos(),
          '/addEditMembershipFee': (context) => AddEditMembershipFee(),
          '/photoDetail': (context) => PhotoDetail(),
          '/trackDetail': (context) => TrackDetail(),
          '/addEditTrack': (context) => AddEditTrack(),
        },
        home: Consumer2<LoginProvider, MessageProvider>(
          builder: (context, loginProvider, messageProvider, child) {
            // if a message is set in the message provider, render it as a floating snackbar
            if (messageProvider.message != null) {
              // to prevent calling setState() during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // session expired, handled as a snackbar
                if (messageProvider.messageType ==
                    MessageType.SESSION_EXPIRED) {
                  // on cold start / mid-login the JWT being stale is expected, no need to interrupt with a snackbar
                  if (loginProvider.authStatus != AuthStatus.Authenticated) {
                    _log.info(
                      "Session expired detected before authentication completed, skipping snackbar, routing to passcode silently",
                    );
                    loginProvider.handleSessionExpired();
                    messageProvider.clearMessage();
                    return;
                  }
                  _log.info(
                    "Session expired during active navigation, showing snackbar + clearing nav stack",
                  );
                  loginProvider.handleSessionExpired();
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/',
                    (Route<dynamic> route) => false,
                  );
                  // intentionally NOT returning, fall through to the snackbar rendering so the user sees what happened
                }

                // global application success/warning/error snack bar messages.
                final Color notificationColor =
                    (messageProvider.messageType == MessageType.ERROR)
                    ? Color(0xFFB43636)
                    : messageProvider.messageType == MessageType.WARNING
                    ? Color(0xFFC9922D)
                    : messageProvider.messageType == MessageType.SUCCESS
                    ? Color(0xFF42914A)
                    : Color(0xFF2368AF);
                final String notificationTitle =
                    (messageProvider.messageType == MessageType.ERROR)
                    ? AppString.error
                    : messageProvider.messageType == MessageType.WARNING
                    ? AppString.warning
                    : messageProvider.messageType == MessageType.SUCCESS
                    ? AppString.success
                    : AppString.info;
                final IconData notificationIcon =
                    (messageProvider.messageType == MessageType.ERROR)
                    ? Icons.error_outline
                    : messageProvider.messageType == MessageType.WARNING
                    ? Icons.warning_amber_rounded
                    : messageProvider.messageType == MessageType.SUCCESS
                    ? Icons.check_circle_outline
                    : Icons.info_outline;
                final snackBar = SnackBar(
                  showCloseIcon: true,
                  closeIconColor: Colors.white,
                  backgroundColor: notificationColor,
                  padding: const EdgeInsets.all(24),
                  duration: const Duration(seconds: 6),
                  content: Row(
                    children: [
                      Icon(notificationIcon, color: Colors.white, size: 35),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notificationTitle,
                              textScaler: TextScaler.linear(1.3),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              messageProvider.message!,
                              textScaler: TextScaler.linear(0.9),
                              style: TextStyle(color: Colors.white),
                            ),
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
          },
        ),
        theme: ThemeData().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red[700]!,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        supportedLocales: [const Locale('en', 'US'), const Locale('fr', 'FR')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
