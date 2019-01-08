import 'package:chachatte_team/ui/calendar.dart';
import 'package:chachatte_team/ui/gallery.dart';
import 'package:chachatte_team/ui/news.dart';
import 'package:chachatte_team/ui/team.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {

  // current page index of the bottom navigation bar
  int _currentIndex = 0;

  // list of pages of the bottom navigation bar
  final List<Widget> _children = [
    NewsList(),
    Calendar(),
    Team(),
    Gallery(),
  ];

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text(AppString.applicationTitle),
          leading: new Icon(Icons.motorcycle),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [PopupMenuItem(child: Text(AppString.about)), PopupMenuItem(child: Text(AppString.contact))];
              },
            )
          ],
        ),
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
    //]));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
