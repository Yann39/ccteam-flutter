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

import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:cotter/cotter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LoginCotter extends StatefulWidget {
  @override
  _LoginCotterState createState() => _LoginCotterState();
}

class _LoginCotterState extends State<LoginCotter> {
  final Logger _log = new Logger('LoginCotter');
  final inputController = TextEditingController();

  Cotter cotter = new Cotter(apiKeyID: "b8d3123d-5c5a-4419-a11d-b54ae44152f3");

  _showResponse(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
      ),
    );
  }

  void signUp(BuildContext context) async {
    try {
      // 🚀 One-line Sign Up
      var user = await cotter.signUpWithDevice(identifier: inputController.text);
      // This will create a new user in Cotter and trust the current device

      // Show the response
      _showResponse(context, "User Created", "id: ${user.id}\nidentifier: ${user.identifier}");
      print(user);
    } catch (e) {
      _showResponse(context, "Error", e.toString());
    }
  }

  void login(BuildContext context) async {
    try {
      // 🚀 One-line Login
      var event = await cotter.signInWithDevice(identifier: inputController.text, context: context);

      // Show the response
      _showResponse(context, event.approved ? "Login Success" : "Login Failed", "User id: ${event.userID}");
      print(event);
    } catch (e) {
      _showResponse(context, "Error", e.toString());
    }
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building Login...");

    final _logo = Container(
      padding: EdgeInsets.only(top: 36),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 26.0,
            child: Icon(CustomIcons.pilot, color: Colors.white, size: 52),
          ),
          SizedBox(height: 6.0),
          Text(
            AppString.applicationTitle,
            style: TextStyle(color: Colors.white),
            textScaleFactor: 1.3,
          ),
          SizedBox(height: 6.0),
          Text(
            AppString.identification,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    final _emailField = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        keyboardAppearance: Brightness.dark,
        autofocus: false,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          prefixIcon: Icon(Icons.mail, color: Colors.white),
          hintText: AppString.loginEmailHint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
        maxLines: 1,
        inputFormatters: [LengthLimitingTextInputFormatter(128)],
        validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
        controller: inputController,
      ),
    );

    final _loginButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            login(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            AppString.connect,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    final _registerButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            signUp(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.blue[700],
          child: Text(
            AppString.register,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    return GestureDetector(
      onTap: () {
        // allow to dismiss the keyboard when clicking outside
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/motos.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.3),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                autovalidate: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _loginProvider.authStatus == AuthStatus.Authenticating ? CircularProgressIndicator() : _logo,
                    SizedBox(height: 32.0),
                    _emailField,
                    SizedBox(height: 8.0),
                    _loginButton,
                    _registerButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
