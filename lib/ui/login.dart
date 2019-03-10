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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/ui/login_loading_screen.dart';
import 'package:chachatte_team/ui/register.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _loginScaffoldKey = new GlobalKey<ScaffoldState>();

  // the member to be created
  final Member _newMember = new Member();

  /// Allow to dismiss the keyboard when clicking outside
  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  /// Method that navigates to the Register screen and awaits the result from Navigator.pop
  _navigateToRegisterScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));

    // after the target screen returns a result, show a bottom sheet to display the result
    if (result != null) {
      _loginScaffoldKey.currentState.showBottomSheet<String>(
        (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.red),
              ),
              color: Colors.black,
            ),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: Text(
                    AppString.memberCreated,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppString.accountWaitingAdmin,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ButtonTheme.bar(
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: const Text(
                          AppString.understood,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }

  /// Method that validates the form then process the login in a loading screen and awaits the result from Navigator.pop
  _doLogin(Member member) async {
    final FormState form = _loginFormKey.currentState;

    if (!form.validate()) {
      _loginScaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      // do the login and wait for the result
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginLoadingScreen(member: member)));

      // after the target screen returns a result, hide any previous snack bars and show the new result (if we come here it means an error occurred)
      if (result != null) {
        _loginScaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("$result")));
      }
    }
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
              ),
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
        padding: EdgeInsets.fromLTRB(16, 36, 16, 0),
      ),
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
          icon: Icon(Icons.mail, color: Colors.white),
          hintText: AppString.loginEmailHint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
        maxLines: 1,
        inputFormatters: [new LengthLimitingTextInputFormatter(128)],
        validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
        onSaved: (val) => _newMember.email = val,
        initialValue: _newMember.email,
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
          hintText: AppString.loginPasswordHint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
        maxLines: 1,
        inputFormatters: [new LengthLimitingTextInputFormatter(32)],
        validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
        onSaved: (val) => _newMember.password = val,
        initialValue: _newMember.password,
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
            _doLogin(_newMember);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            AppString.connect,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 8.0),
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            _navigateToRegisterScreen(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.blue[700],
          child: Text(
            AppString.register,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    final forgotLabel = FlatButton(
      child: Text(
        AppString.forgotPassword,
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
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.4),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Scaffold(
          key: _loginScaffoldKey,
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 8.0),
                  Form(
                    key: _loginFormKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        logo,
                        SizedBox(height: 32.0),
                        email,
                        SizedBox(height: 8.0),
                        password,
                        SizedBox(height: 24.0),
                        loginButton,
                      ],
                    ),
                  ),
                  forgotLabel
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
