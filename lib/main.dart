import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(new ChachatteTeamApp());

class ChachatteTeamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chachatte Team',
      home: Home(),
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}