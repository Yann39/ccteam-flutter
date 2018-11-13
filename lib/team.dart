import 'package:flutter/material.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamState();
  }
}

class _TeamState extends State<Team> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Screen'),
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