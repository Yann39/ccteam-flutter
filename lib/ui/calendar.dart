import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.calendarTitle),
        backgroundColor: Colors.blue[300],
        leading: new Icon(Icons.event),
      ),
      body: Container(
        child: Container(child:Text("calendar here")),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Colors.blue[300], Colors.green[300]],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
      ),
    );
  }
}
