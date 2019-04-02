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
import 'package:chachatte_team/ui/events/calendar.dart';
import 'package:chachatte_team/ui/members/team.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';

class Home extends StatefulWidget {
  final Member member;

  const Home({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {

  final Logger log = new Logger('NewsCard');

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  // current page index of the bottom navigation bar
  int _currentIndex = 0;

  Widget build(BuildContext context) {

    // list of pages of the bottom navigation bar
    final List<Widget> _children = [
      NewsList(member: widget.member,),
      Calendar(),
      Team(),
      Gallery(),
    ];

    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.red[700],
        type: BottomNavigationBarType.shifting,
        items: [
          new BottomNavigationBarItem(icon: new Icon(Icons.home), title: new Text(AppString.tabHome), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(icon: new Icon(Icons.event), title: new Text(AppString.tabCalendar), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(icon: new Icon(Icons.group), title: new Text(AppString.tabTeam), backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(icon: new Icon(Icons.photo_album), title: new Text(AppString.tabGallery), backgroundColor: Colors.red[700])
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
