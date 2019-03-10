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

import 'package:chachatte_team/ui/home.dart';
import 'package:chachatte_team/ui/login.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  // logging configuration
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  // read shared preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // if email is set, we will consider user is already logged in
  String email = prefs.getString('email');
  // pass email as parameter so we can redirect user to home page or login page depending on the value
  runApp(new ChachatteTeamApp(email));
}

class ChachatteTeamApp extends StatelessWidget {
  final String email;

  ChachatteTeamApp(this.email);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppString.applicationTitle,
      home: email != null ? Home() : Login(),
      theme: new ThemeData(
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
