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

import 'package:chachatte_team/providers/home_provider.dart';
import 'package:chachatte_team/ui/events/calendar.dart';
import 'package:chachatte_team/ui/members/team.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/ui/tracks/tracks.dart';
import 'package:chachatte_team/utils/custom_icons_icons.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final Logger _log = new Logger('Home');

  // list of pages of the bottom navigation bar
  final List<Widget> _children = [NewsList(), Calendar(), Team(), Tracks(), Gallery()];

  // this should be called for at least one locale before any date formatting methods are called
  //initializeDateFormatting();

  /// handle tabs clicks
  void onTabTapped(int index, BuildContext context) {
    Provider.of<HomeProvider>(context, listen: false).setCurrentIndex(index);
  }

  Widget build(BuildContext context) {
    _log.info("Building home page...");
    final HomeProvider _homeProvider = Provider.of<HomeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _children[_homeProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _homeProvider.setCurrentIndex(index),
        currentIndex: _homeProvider.currentIndex,
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
            icon: Icon(CustomIcons.group_helmet, color: Colors.white),
            title: Text(AppString.tabTeam, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.track_sample, color: Colors.white, size: 20,),
            title: Text(AppString.tabTracks, style: TextStyle(color: Colors.white)),
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
