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
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/ui/forgot_password.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _loginScaffoldKey = new GlobalKey<ScaffoldState>();
  final Logger _log = new Logger('Login');

  // the member to be logged
  final Member _newMember = new Member();

  /// Method that navigates to the Register screen and awaits the result from Navigator.pop
  _navigateToRegisterScreen(BuildContext context) async {
    _log.info("Going to Register page");
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/register');

    // after the target screen returns a result, show a bottom sheet to display the result
    if (_result != null) {
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

  /// Method that validates the form then process to the login
  _doLogin(BuildContext context) async {
    final FormState _form = _loginFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      _log.warning("Login form is not valid");
      _loginScaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // do the login
      Provider.of<MemberProvider>(context, listen: false).loginMember(_newMember).then((value) {}, onError: (error) {
        _loginScaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.loginFailed)));
      });
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building Login");

    final _logo = Container(
      padding: EdgeInsets.only(top: 36),
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
        onSaved: (val) => _newMember.email = val,
        initialValue: _newMember.email,
      ),
    );

    final _passwordField = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        autofocus: false,
        style: TextStyle(color: Colors.white),
        obscureText: true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          prefixIcon: Icon(Icons.lock, color: Colors.white),
          hintText: AppString.loginPasswordHint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
        maxLines: 1,
        inputFormatters: [LengthLimitingTextInputFormatter(32)],
        validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
        onSaved: (val) => _newMember.password = val,
        initialValue: _newMember.password,
      ),
    );

    final _loginButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            _doLogin(context);
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

    final _forgotLabel = FlatButton(
      child: Text(
        AppString.forgotPassword,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
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
              child: Form(
                key: _loginFormKey,
                autovalidate: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Provider.of<MemberProvider>(context).status == Status.Authenticating ? CircularProgressIndicator() : _logo,
                    SizedBox(height: 32.0),
                    _emailField,
                    SizedBox(height: 8.0),
                    _passwordField,
                    SizedBox(height: 24.0),
                    _loginButton,
                    _forgotLabel,
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
