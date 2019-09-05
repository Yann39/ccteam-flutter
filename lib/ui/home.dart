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
import 'package:chachatte_team/ui/events/calendar.dart';
import 'package:chachatte_team/ui/login.dart';
import 'package:chachatte_team/ui/members/team.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final Logger log = new Logger('Home');
  final GlobalKey<ScaffoldState> _homeScaffoldKey = new GlobalKey<ScaffoldState>();

  /// Launch URL to contact user
  _launchURL() async {
    const url = 'mailto:rockyracer@mailfence.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  /// Handle menu item click
  void _select(QuickActions choice) async {
    if (choice == QuickActions.contact) {
      _launchURL();
    } else if (choice == QuickActions.logout) {
      _logout();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  // current page index of the bottom navigation bar
  int _currentIndex = 0;

  _openDrawer() {
    _homeScaffoldKey.currentState.openDrawer();
  }

  Widget build(BuildContext context) {
    log.info("Build home");
    // list of pages of the bottom navigation bar
    final List<Widget> _children = [
      NewsList(),
      Calendar(
        title: AppString.eventScreenTitle,
      ),
      Team(),
      Gallery(),
    ];

    return new Scaffold(
      backgroundColor: Colors.transparent,
      key: _homeScaffoldKey,
      appBar: AppBar(
        title: Text(AppString.applicationTitle),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _homeScaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          PopupMenuButton<QuickActions>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.about),
                  value: QuickActions.about,
                ),
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.contact),
                  value: QuickActions.contact,
                ),
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.logout),
                  value: QuickActions.logout,
                ),
              ];
            },
            onSelected: _select,
          )
        ],
      ),
      drawer: MainDrawer(member: Provider.of<MemberProvider>(context, listen: false).member),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.red[700],
        type: BottomNavigationBarType.shifting,
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home, color: Colors.white), title: new Text(AppString.tabHome, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.event, color: Colors.white), title: new Text(AppString.tabCalendar, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.group, color: Colors.white), title: new Text(AppString.tabTeam, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.photo_album, color: Colors.white),
              title: new Text(AppString.tabGallery, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red[700])
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
