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
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  /// Log out the current user
  void _logout(BuildContext context) async {
    Provider.of<LoginProvider>(context, listen: false).logoutMember();
  }

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.pushNamed(context, '/addEditMember', arguments: member);

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[500]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Row(
                    children: <Widget>[
                      Icon(Icons.person_outline, color: Colors.white, size: 12),
                      SizedBox(width: 5),
                      Text("${_loginProvider.loggedMember.firstName} ${_loginProvider.loggedMember.lastName}"),
                    ],
                  ),
                  accountEmail: Row(
                    children: <Widget>[
                      Icon(Icons.mail_outline, color: Colors.white, size: 12),
                      SizedBox(width: 5),
                      Text(_loginProvider.loggedMember.email),
                    ],
                  ),
                  arrowColor: Colors.green,
                  currentAccountPicture: Container(
                    decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                    padding: EdgeInsets.all(2.0),
                    child: _loginProvider.loggedMember.avatar != null && _loginProvider.loggedMember.avatar.length > 0 ? CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      backgroundImage: NetworkImage("$SERVER_ROOT_PATH$SERVER_AVATAR_FOLDER${_loginProvider.loggedMember.avatar}"),
                    ) : CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.0, 1.0),
                          stops: [0.0, 1.0],
                          colors: [Colors.red[700], Colors.white],
                        ).createShader(bounds),
                        child: Icon(CustomIcons.pilot, size: 50),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 210,
                  height: 110,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      'images/chachatte-team-banner-drawer.png',
                      fit: BoxFit.fitWidth,
                      width: 160,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.green[700],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.profile),
                  onTap: () {
                    _navigateToEditMemberScreen(context, _loginProvider.loggedMember);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.event,
                    color: Colors.purple[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.myTrackEvents),
                  onTap: () {
                    Navigator.pushNamed(context, '/memberEvents', arguments: _loginProvider.loggedMember);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer,
                    color: Colors.orange[800],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.myChronos),
                  onTap: () {
                    Navigator.pushNamed(context, '/memberChronos', arguments: _loginProvider.loggedMember);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.blue[700],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.notifications),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.teal[700],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.preferences),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.red[900],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text(AppString.disconnect),
                  onTap: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
