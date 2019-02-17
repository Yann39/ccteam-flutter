import 'dart:ui';

import 'package:chachatte_team/ui/home.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: Container(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 24.0,
                child: Image.asset(
                  'images/helmet-face.png',
                  //color: Colors.red[700],
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                "Chachatte team",
                style: TextStyle(color: Colors.white),
                textScaleFactor: 1.3,
              ),
              SizedBox(height: 6.0),
              Text(
                "Inscription",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16, 36, 16, 0)),
    );

    final email = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        keyboardAppearance: Brightness.dark,
        autofocus: false,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          icon: Icon(Icons.person, color: Colors.white),
          hintText: 'Votre adresse e-mail',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
      ),
    );

    final password = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        autofocus: false,
        style: TextStyle(color: Colors.white),
        obscureText: true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          icon: Icon(Icons.lock, color: Colors.white),
          hintText: 'Choisissez votre mot de passe',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
      ),
    );

    final passwordBis = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        autofocus: false,
        style: TextStyle(color: Colors.white),
        obscureText: true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          icon: Icon(Icons.lock, color: Colors.white),
          hintText: 'Retapez votre mot de passe',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
      ),
    );

    final loginButton = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      },
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      color: Colors.red[700],
      child: Text(
        'S\'inscrire',
        style: TextStyle(color: Colors.white),
      ),
    );

    return new GestureDetector(
      onTap: () {
        this._dismissKeyboard(context);
      },
      child: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/motos.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Color.fromRGBO(255, 255, 255, 0.4), BlendMode.modulate),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[logo, SizedBox(height: 32.0), email, SizedBox(height: 8.0), password, SizedBox(height: 8.0), passwordBis, SizedBox(height: 24.0), loginButton],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
