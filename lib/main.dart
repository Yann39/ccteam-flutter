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

import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/ui/home.dart';
import 'package:chachatte_team/ui/login.dart';
import 'package:chachatte_team/ui/register.dart';
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
    ChangeNotifierProvider<MemberProvider>(
      builder: (context) => MemberProvider(),
      child: ChachatteTeamApp(),
    ),
  );
}

class ChachatteTeamApp extends StatelessWidget {
  final Logger _log = new Logger('ChachatteTeamApp');

  @override
  Widget build(BuildContext context) {
    _log.info("Building MaterialApp");
    return MaterialApp(
      title: AppString.applicationTitle,
      initialRoute: '/',
      routes: {
        '/register': (context) => Register(),
      },
      home: Consumer<MemberProvider>(builder: (context, memberModel, child) {
        if (memberModel.status == Status.Authenticated) {
          _log.info("Going to home page");
          return Home();
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
