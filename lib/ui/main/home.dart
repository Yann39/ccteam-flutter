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

import 'package:ccteam/providers/home_provider.dart';
import 'package:ccteam/ui/events/event_list.dart';
import 'package:ccteam/ui/members/member_list.dart';
import 'package:ccteam/ui/news/news_list.dart';
import 'package:ccteam/ui/photos/galleries.dart';
import 'package:ccteam/ui/tracks/track_list.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final Logger _log = new Logger('Home');

  // list of pages of the bottom navigation bar
  final List<Widget> _children = [
    NewsList(),
    EventList(),
    MemberList(),
    Tracks(),
    Galleries(),
  ];

  /// handle tab click
  void onTabTapped(int index, BuildContext context) {
    Provider.of<HomeProvider>(context, listen: false).setCurrentIndex(index);
  }

  Widget build(BuildContext context) {
    _log.info("Building home page...");
    final HomeProvider _homeProvider = Provider.of<HomeProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _children[_homeProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _homeProvider.setCurrentIndex(index),
        currentIndex: _homeProvider.currentIndex,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: AppString.tabHome,
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.white),
            label: AppString.tabCalendar,
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.helmet_group, color: Colors.white),
            label: AppString.tabTeam,
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.track, color: Colors.white, size: 20),
            label: AppString.tabTracks,
            backgroundColor: Colors.red[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album, color: Colors.white),
            label: AppString.tabGallery,
            backgroundColor: Colors.red[700],
          ),
        ],
      ),
    );
  }
}
