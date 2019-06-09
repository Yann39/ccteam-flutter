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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/ui/home.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginLoadingScreen extends StatefulWidget {
  const LoginLoadingScreen({Key key, this.member}) : super(key: key);

  final Member member;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginLoadingScreen> {
  initState() {
    _checkLogin(context);
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[100], Colors.blue[400]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text(AppString.loggingIn),
          ],
        ),
      ),
    );
  }

  _checkLogin(BuildContext context) {
    final MembersService membersService = new MembersService();
    final Logger log = new Logger('LoginLoadingScreen');

    membersService.loginMember(widget.member).then((value) async {
      // store the user e-mail in the shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', widget.member.email);
      log.fine("User ${widget.member.email} logged in successfully");
      // get the full member from the database
      try {
        Member fullMember = await membersService.getMemberByEmail(widget.member.email);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(member: fullMember)));
      } catch (exception) {
        log.warning("Problem when getting user ${widget.member.email} from database : $exception");
        Navigator.pop(context, AppString.loginFailed);
      }
    }, onError: (error) {
      log.warning("User ${widget.member.email} failed to log in", error);
      Navigator.pop(context, AppString.loginFailed);
    });
  }
}
