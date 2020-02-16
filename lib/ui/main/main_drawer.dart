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
import 'package:chachatte_team/providers/drawer_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
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
    final DrawerProvider _drawerProvider = Provider.of<DrawerProvider>(context, listen: false);

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
                  accountName: Text("${_loginProvider.loggedMember.firstName} ${_loginProvider.loggedMember.lastName}"),
                  accountEmail: Text(_loginProvider.loggedMember.email),
                  arrowColor: Colors.green,
                  currentAccountPicture: InkWell(
                    onTap: () {
                      _drawerProvider.loadImage(null);
                      Navigator.of(context).pushNamed('/editAvatar');
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      backgroundImage: _loginProvider.loggedMember.avatar != null
                          ? NetworkImage("${AppConstants.SERVER_ROOT_PATH}${AppConstants.SERVER_AVATAR_FOLDER}${_loginProvider.loggedMember.avatar}")
                          : AssetImage("images/helmet-face.png"),
                    ),
                  ),
                ),
                Container(
                  width: 210,
                  height: 110,
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'images/chachatte-team-banner-drawer.png',
                    fit: BoxFit.fitWidth,
                    width: 160,
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.green[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Profile'),
                  onTap: () {
                    _navigateToEditMemberScreen(context, _loginProvider.loggedMember);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.blue[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.teal[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Préférences'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.purple[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Déconnexion'),
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
