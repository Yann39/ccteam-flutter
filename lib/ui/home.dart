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
import 'package:chachatte_team/ui/login.dart';
import 'package:chachatte_team/ui/members/add_member.dart';
import 'package:chachatte_team/ui/members/team.dart';
import 'package:chachatte_team/ui/news/news.dart';
import 'package:chachatte_team/ui/photos/gallery.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember(member: member)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
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

  Widget build(BuildContext context) {
    // list of pages of the bottom navigation bar
    final List<Widget> _children = [
      NewsList(
        member: widget.member,
      ),
      Calendar(),
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
      drawer: Drawer(
        child: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.blue[100], Colors.blue[300]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("${widget.member.firstName} ${widget.member.lastName}"),
                accountEmail: Text(widget.member.email),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: new NetworkImage('http://i.pravatar.cc/300'),
                ),
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.green[600],),
                    trailing: Icon(Icons.arrow_right),
                    title: Text('Profile'),
                    onTap: () {
                      _navigateToEditMemberScreen(context, widget.member);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue[600],),
                    trailing: Icon(Icons.arrow_right),
                    title: Text('Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.teal[600],),
                    trailing: Icon(Icons.arrow_right),
                    title: Text('Préférences'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.purple[600],),
                    trailing: Icon(Icons.arrow_right),
                    title: Text('Déconnexion'),
                    onTap: () {
                      _logout();
                    },
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
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
