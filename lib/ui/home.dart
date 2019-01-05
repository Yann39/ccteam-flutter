import 'package:chachatte_team/ui/add_news.dart';
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

/// class representing the floating action button to add a news
/// await the result from the "Add News" screen to display a message
class _AddNewsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        elevation: 0.0,
        child: new Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateAndDisplaySelection(context);
        });
  }

  /// Method that launches the Add News screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddNews()));

    // after the Add News Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
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
    final double width = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return /*new Container(
        child: new Stack(children: <Widget>[
      new Container(
        padding: new EdgeInsets.only(top: statusBarHeight),
        height: statusBarHeight + 66,
        child: Image.asset(
                'images/chachatte-team-banner.png',
                width: width,
                fit: BoxFit.fitWidth,
              ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Colors.red[700], Colors.white]),
        ),
      ),*/
      new Scaffold(
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
        floatingActionButton: _AddNewsButton(),
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
