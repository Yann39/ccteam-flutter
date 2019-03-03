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

import 'dart:ui';

import 'package:chachatte_team/ui/home.dart';
import 'package:chachatte_team/ui/register.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget build(BuildContext context) {
    final header = Container(
        child: /*Image.asset(
        'images/chachatte-team-banner.png',
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.4),
      ),*/
            Text(
          "Chachatte team",
          style: TextStyle(color: Colors.white),
          textScaleFactor: 2,
        ),
        padding: EdgeInsets.fromLTRB(16, 36, 16, 0));

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
                "Identification",
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
          hintText: 'Adresse e-mail',
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
          hintText: 'Mot de passe',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
      ),
    );

    final loginButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            'Se connecter',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 8.0),
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.blue[700],
          child: Text(
            'S\'inscrire',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Mot de passe oublié?',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {},
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 8.0),
                Column(
                  children: <Widget>[logo, SizedBox(height: 32.0), email, SizedBox(height: 8.0), password, SizedBox(height: 24.0), loginButton],
                ),
                forgotLabel
              ],
            ),
          ),
        ),
      ),
    );
  }
}
