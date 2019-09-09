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
import 'package:chachatte_team/providers/news_provider.dart';
import 'package:chachatte_team/ui/events/calendar.dart';
import 'package:chachatte_team/ui/members/team.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final Logger _log = new Logger('Home');

  // list of pages of the bottom navigation bar
  final List<Widget> _children = [
    NewsList(),
    Calendar(),
    ChangeNotifierProvider<MemberProvider>(builder: (context) => MemberProvider(), child: Team()),
    Gallery(),
  ];

  // current page index of the bottom navigation bar
  int _currentIndex = 0;

  /// handle tabs clicks
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  Widget build(BuildContext context) {
    _log.info("Build home");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.red[700],
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            title: Text(AppString.tabHome, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.white),
            title: Text(AppString.tabCalendar, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.white),
            title: Text(AppString.tabTeam, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album, color: Colors.white),
            title: Text(AppString.tabGallery, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
          )
        ],
      ),
    );
  }
}
