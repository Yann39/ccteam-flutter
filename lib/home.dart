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
    PlaceholderWidget(Colors.lightBlueAccent),
    PlaceholderWidget(Colors.deepOrange),
    PlaceholderWidget(Colors.green),
    PlaceholderWidget(Colors.yellow),
  ];

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return new Container(
      child: new Stack(
        children: <Widget>[
          new Container(
            child: Opacity(
              child: Image.asset(
                'images/finish-flag.png',
                width: width,
                fit: BoxFit.fill,
              ),
              opacity: 0.15
            ),
            color: Colors.blue,
          ),
          new Scaffold(
            appBar: new AppBar(
              title: new Text('Chachatte Team'),
              backgroundColor: Colors.transparent,
              bottom: new PreferredSize(
                child: Image.asset(
                  'images/chachatte-team-banner.png',
                  width: width,
                  fit: BoxFit.fill,
                ),
                preferredSize: Size(width, 260.0)
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.transparent,
            body: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  _children[_currentIndex],
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: onTabTapped,
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.home),
                  title: new Text('Accueil'),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.group),
                  title: new Text('Team'),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.event), title: new Text('Calendrier')),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.photo_album),
                  title: new Text('Gallerie')
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /*Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: new Stack(
          children: <Widget>[
            new Container(
              child: Opacity(
                child: new PreferredSize(
                  child: Image.asset(
                    'images/finish-flag.png',
                    width: width,
                    fit: BoxFit.fill,
                  ),
                  preferredSize: Size(width, 260.0)),
                opacity: 0.15
              ),
            ),
            new Text('Chachatte Team')
          ],
        ),
        bottom: new PreferredSize(
          child: Image.asset(
            'images/chachatte-team-banner.png',
            width: width,
            fit: BoxFit.fill,
          ),
          preferredSize: Size(width, 260.0)
        ),
      ),
      body: ListView(
        children: [
          _children[_currentIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Accueil'),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.group),
            title: new Text('Team'),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.event), title: new Text('Calendrier')),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.photo_album),
            title: new Text('Gallerie'))
        ],
      ),
    );
  }*/

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 300.0,
    );
  }
}
