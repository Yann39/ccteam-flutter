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
import 'package:chachatte_team/providers/timer_provider.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final Logger _log = new Logger('RegisterForm');

  final GlobalKey<FormState> _preRegisterFormKey = new GlobalKey<FormState>();

  /// Method that pre-register the user according to information specified in the related form.
  /// It updates the login step status according to the result.
  _doPreRegisterUser(BuildContext context) async {
    final FormState _form = _preRegisterFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      _form.save();

      // register user
      Provider.of<LoginProvider>(context, listen: false)
          .preRegisterMember()
          .then((value) {
        Provider.of<TimerProvider>(context, listen: false).startCountDown(600);
      }, onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  final _logo = Container(
    padding: EdgeInsets.only(top: 36),
    child: Image.asset(
      'images/chachatte-team-banner.png',
      fit: BoxFit.fitWidth,
    ),
  );

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building Login...");

    final _firstNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberFirstNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) =>
          val.isEmpty ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _loginProvider.firstName = val,
      initialValue: _loginProvider.firstName,
    );

    final _lastNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberLastNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) =>
          val.isEmpty ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _loginProvider.lastName = val,
      initialValue: _loginProvider.lastName,
    );

    final _emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.mail, color: Colors.black87),
        hintText: AppString.loginEmailHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => val.isEmpty
          ? AppString.memberEmailMandatory
          : (StringUtils.isValidEmail(val)
              ? null
              : AppString.memberEmailNotValid),
      onSaved: (val) => _loginProvider.email = val,
      initialValue: _loginProvider.email,
    );

    final _preRegisterButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _doPreRegisterUser(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.blue[700],
          child: _loginProvider.loginStatus == LoginStatus.Loading
              ? SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.0,
                  ),
                  height: 14.0,
                  width: 14.0,
                )
              : Text(
                  AppString.register,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _backButton = Builder(
      builder: (BuildContext context) {
        return FlatButton(
          onPressed: () {
            _goToPreviousStep();
          },
          child: Text(
            AppString.back,
            style: TextStyle(color: Colors.blue[900]),
          ),
        );
      },
    );

    final _preRegisterForm = Form(
      key: _preRegisterFormKey,
      autovalidate: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _logo,
            SizedBox(height: 36.0),
            Text(
              "Inscription",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15.0, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: AppString.noAccountWithEmail),
                  TextSpan(
                      text: " ${_loginProvider.email}".toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ". ${AppString.infoRegister}"),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            _firstNameField,
            SizedBox(height: 8.0),
            _lastNameField,
            SizedBox(height: 8.0),
            _emailField,
            SizedBox(height: 16.0),
            _preRegisterButton,
            _backButton,
          ],
        ),
      ),
    );

    return _preRegisterForm;
  }
}
