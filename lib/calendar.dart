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
        title: Text('Calendar Screen'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go back'),
          onPressed: () {
            // Navigate to second screen when tapped!
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}