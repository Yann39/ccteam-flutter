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

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  /// Log out the current user
  void _logout(BuildContext context) async {
    Provider.of<LoginProvider>(context, listen: false).logoutMember();
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: true);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[500]!],
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
                  decoration: BoxDecoration(color: Colors.red[600]),
                  accountName: Row(
                    children: <Widget>[
                      Icon(Icons.person_outline, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "${_loginProvider.loggedMember!.firstName} ${_loginProvider.loggedMember!.lastName}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  accountEmail: Row(
                    children: <Widget>[
                      Icon(Icons.mail_outline, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(_loginProvider.loggedMember!.email!),
                    ],
                  ),
                  currentAccountPicture: Container(
                    decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                    padding: EdgeInsets.all(2.0),
                    child: AvatarImage(
                      memberId: _loginProvider.loggedMember!.id,
                      hasAvatar: _loginProvider.loggedMember!.hasAvatar == true,
                      radius: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 210,
                  height: 58,
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    'images/app_logos/ccteam_logo_text_only_black_white.svg',
                    width: 140,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle, color: Colors.green[700]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.myAccount, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/myAccount');
                    },
                  ),
                  Divider(color: Colors.white60),
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.purple[600]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.myTrackEvents, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/memberEvents', arguments: _loginProvider.loggedMember);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: Colors.orange[800]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.myChronos, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      // fetch the logged member's records, private ones included
                      Provider.of<RecordListProvider>(
                        context,
                        listen: false,
                      ).fetchMyRecords();
                      Navigator.pushNamed(context, '/memberChronos');
                    },
                  ),
                  ListTile(
                    leading: Icon(CustomIcons.motorbike_plain, color: Colors.blue[900]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.myBikes, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/myBikes');
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue[700]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.notifications, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notificationSettings');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.teal[700]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.preferences, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.red[900]),
                    trailing: Icon(Icons.arrow_right, color: Colors.black),
                    title: Text(AppString.disconnect, style: TextStyle(color: Colors.black)),
                    onTap: () {
                      _logout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
