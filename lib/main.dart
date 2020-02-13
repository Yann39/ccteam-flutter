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

import 'package:chachatte_team/providers/drawer_provider.dart';
import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/providers/home_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/providers/news_provider.dart';
import 'package:chachatte_team/ui/events/add_edit_event.dart';
import 'package:chachatte_team/ui/main/image_crop.dart';
import 'package:chachatte_team/ui/unauthenticated/forgot_password.dart';
import 'package:chachatte_team/ui/main/home.dart';
import 'package:chachatte_team/ui/unauthenticated/loading.dart';
import 'package:chachatte_team/ui/unauthenticated/login.dart';
import 'package:chachatte_team/ui/members/add_edit_member.dart';
import 'package:chachatte_team/ui/members/member_detail.dart';
import 'package:chachatte_team/ui/news/add_edit_news.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/news/news_detail.dart';
import 'package:chachatte_team/ui/unauthenticated/register.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DrawerProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
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
    return MaterialApp(
      title: AppString.applicationTitle,
      initialRoute: '/',
      routes: {
        '/register': (context) => Register(),
        '/forgotPassword': (context) => ForgotPassword(),
        '/newsList': (context) => NewsList(),
        '/imageCrop': (context) => ImageCrop(),
        '/addEditNews': (context) => AddEditNews(news: ModalRoute.of(context).settings.arguments),
        '/addEditEvent': (context) => AddEditEvent(event: ModalRoute.of(context).settings.arguments),
        '/addEditMember': (context) => AddEditMember(member: ModalRoute.of(context).settings.arguments),
        '/newsDetail': (context) => NewsDetail(news: ModalRoute.of(context).settings.arguments),
        '/memberDetail': (context) => MemberDetail(member: ModalRoute.of(context).settings.arguments),
      },
      home: Consumer<LoginProvider>(builder: (context, loginProvider, child) {
        if (loginProvider.status == AuthStatus.Authenticated) {
          _log.info("Going to home page");
          return Home();
        } else if (loginProvider.status == AuthStatus.Initializing) {
          _log.info("Going to loading page");
          return Loading();
        } else {
          _log.info("Going to login page");
          return Login();
        }
      }),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.red[700],
      ),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
