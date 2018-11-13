import 'package:chachatte_team/calendar.dart';
import 'package:chachatte_team/homeCard.dart';
import 'package:chachatte_team/team.dart';
import 'package:chachatte_team/gallery.dart';
import 'package:chachatte_team/gradientAppBar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        final double width = MediaQuery.of(context).size.width;
        return <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            floating: true,
            backgroundColor: Colors.transparent,
            pinned: false,
            flexibleSpace: new Container(
              child: FlexibleSpaceBar(
                centerTitle: true,
                background: Opacity(
                  child: Image.asset(
                    'images/chachatte-team-banner.png',
                    width: width,
                    fit: BoxFit.fitWidth,
                  ),
                  opacity: 1.0),
              ),
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp
                ),
              ),
            ),
          ),
        ];
      },
      body: new Column(
        children: <Widget>[
          new HomeCard("Repas le 24/11/2018",
            new AssetImage("images/helmet-blue.png"), Colors.blue[600], Colors.blue[300]),
          new HomeCard("Séance remise des prix",
            new AssetImage("images/helmet-green.png"), Colors.green[600], Colors.green[300]),
          new HomeCard("Réunion le 02 oct.",
            new AssetImage("images/helmet-yellow.png"), Colors.lime[600], Colors.lime[300])
        ],
      ),
    ),
    Team(),
    Calendar(),
    Gallery(),
  ];

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700], title: Text("Chachatte team")),
      backgroundColor: Colors.white,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.red[700],
        type: BottomNavigationBarType.shifting,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Accueil'),
            backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.group),
            title: new Text('Team'),
            backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.event),
            title: new Text('Calendrier'),
            backgroundColor: Colors.red[700]),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.photo_album),
            title: new Text('Gallerie'),
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
