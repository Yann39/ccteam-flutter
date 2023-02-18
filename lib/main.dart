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

import 'package:chachatte_team/providers/avatar_provider.dart';
import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/providers/home_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/providers/news_creation_provider.dart';
import 'package:chachatte_team/providers/news_detail_provider.dart';
import 'package:chachatte_team/providers/news_list_provider.dart';
import 'package:chachatte_team/providers/passcode_provider.dart';
import 'package:chachatte_team/providers/photo_provider.dart';
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/providers/timer_provider.dart';
import 'package:chachatte_team/providers/track_provider.dart';
import 'package:chachatte_team/services/notifications_service.dart';
import 'package:chachatte_team/ui/events/add_edit_event.dart';
import 'package:chachatte_team/ui/events/event_detail.dart';
import 'package:chachatte_team/ui/main/edit_avatar.dart';
import 'package:chachatte_team/ui/main/home.dart';
import 'package:chachatte_team/ui/main/image_crop.dart';
import 'package:chachatte_team/ui/members/add_edit_member.dart';
import 'package:chachatte_team/ui/members/add_edit_record.dart';
import 'package:chachatte_team/ui/members/member_chronos.dart';
import 'package:chachatte_team/ui/members/member_detail.dart';
import 'package:chachatte_team/ui/members/member_events.dart';
import 'package:chachatte_team/ui/news/add_edit_news.dart';
import 'package:chachatte_team/ui/news/news_detail.dart';
import 'package:chachatte_team/ui/photos/add_edit_photo.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/ui/photos/photo_detail.dart';
import 'package:chachatte_team/ui/tracks/track_detail.dart';
import 'package:chachatte_team/ui/unauthenticated/forgot_password.dart';
import 'package:chachatte_team/ui/unauthenticated/loading.dart';
import 'package:chachatte_team/ui/unauthenticated/login.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void main() {
  // logging configuration
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint('${rec.loggerName.padRight(18)} - ${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => NewsListProvider()),
        ChangeNotifierProxyProvider<LoginProvider, NewsListProvider>(
          create: (context) => NewsListProvider(),
          update: (context, loginProvider, newsListProvider) => newsListProvider..update(loginProvider),
        ),
        /*ChangeNotifierProxyProvider<NewsListProvider, LoginProvider>(
          create: (_) => LoginProvider(),
          update: (_, newsListProvider, loginProvider) => loginProvider..update(newsListProvider),
          //lazy: false,
        ),*/
        /*ChangeNotifierProxyProvider<NewsListProvider, NewsDetailProvider>(
          update: (context, newsListProvider, previousNews) => NewsDetailProvider(newsListProvider),
          create: (BuildContext context) => NewsDetailProvider(),
        ),*/
        //ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => NewsCreationProvider()),
        ChangeNotifierProvider(create: (_) => NewsDetailProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => TrackProvider()),
        ChangeNotifierProvider(create: (_) => RecordProvider()),
        ChangeNotifierProvider(create: (_) => PasscodeProvider()),
      ],
      child: ChachatteTeamApp(),
    ),
  );
}

class ChachatteTeamApp extends StatelessWidget {
  final Logger _log = new Logger('ChachatteTeamApp');

  @override
  Widget build(BuildContext context) {
    _log.info("Building ChachatteTeamApp...");

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
          '/addEditEvent': (context) => AddEditEvent(event: ModalRoute.of(context).settings.arguments),
          '/addEditMember': (context) => AddEditMember(member: ModalRoute.of(context).settings.arguments),
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
        home: Consumer<LoginProvider>(
          builder: (context, loginProvider, child) {
            // if an error message is set in the provider, display it in a dialog
            if (loginProvider.errorMessage != null) {
              // to prevent calling setState() during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.error(
                    message: loginProvider.errorMessage,
                    backgroundColor: Colors.red[700],
                    textStyle: TextStyle(fontSize: 12),
                  ),
                );
                loginProvider.clearErrorMessage();
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
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
