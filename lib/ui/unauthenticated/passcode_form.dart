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
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PasscodeForm extends StatefulWidget {
  @override
  _PasscodeFormState createState() => _PasscodeFormState();
}

class _PasscodeFormState extends State<PasscodeForm> {
  final Logger _log = new Logger('PasscodeForm');

  /// Method that log in the user according to the information specified in the related form.
  /// It updates the login step status and the authentication status according to the result.
  _doLogin(BuildContext context) async {
    Provider.of<LoginProvider>(context, listen: false)
        .loginMember()
        .then((value) {}, onError: (error) {
      _log.severe(error.toString());
    });
  }

  /// A widget representing a digit of the passcode
  Widget _passcodeDigit(int digitId, LoginProvider loginProvider) {
    return FlatButton(
      onPressed: () {
        // passcode for logging in
        if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
          // if 6 digits have already been entered, ignore any tap
          if (loginProvider.loginPassCode != null &&
              loginProvider.loginPassCode.length >= 6) {
            return;
          }
          // update the provider, so we can update the digits indicator
          loginProvider.setLoginPassCode((loginProvider.loginPassCode != null
                  ? loginProvider.loginPassCode
                  : "") +
              "$digitId");
          // auto submit form when last digit is entered
          if (loginProvider.loginPassCode != null &&
              loginProvider.loginPassCode.length >= 6) {
            _doLogin(context);
          }
        }
        // passcode creation 1st step
        else if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
          // if 6 digits have already been entered, ignore any tap
          if (loginProvider.firstPassCode != null &&
              loginProvider.firstPassCode.length >= 6) {
            return;
          }
          // update the provider, so we can update the digits indicator
          loginProvider.setFirstPassCode((loginProvider.firstPassCode != null
                  ? loginProvider.firstPassCode
                  : "") +
              "$digitId");
        }
        // passcode creation 2nd step (confirmation)
        else if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
          // if 6 digits have already been entered, ignore any tap
          if (loginProvider.secondPassCode != null &&
              loginProvider.secondPassCode.length >= 6) {
            return;
          }
          // update the provider, so we can update the digits indicator
          loginProvider.setSecondPassCode((loginProvider.secondPassCode != null
                  ? loginProvider.secondPassCode
                  : "") +
              "$digitId");
        }
      },
      child: Text("$digitId"),
      shape: CircleBorder(side: BorderSide(color: Colors.blue[900])),
      padding: EdgeInsets.all(20.0),
      splashColor: Colors.blue[700],
      disabledColor: Colors.grey[500].withOpacity(0.4),
    );
  }

  /// A widget representing the back button of the passcode
  Widget _passcodeBack(LoginProvider loginProvider) {
    return FlatButton(
      onPressed: () {
        // passcode for logging in
        if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (loginProvider.loginPassCode != null &&
              loginProvider.loginPassCode.length >= 1) {
            loginProvider.setLoginPassCode(loginProvider.loginPassCode
                .substring(0, loginProvider.loginPassCode.length - 1));
          } else {
            loginProvider.setLoginPassCode(null);
          }
        }
        // passcode creation 1st step
        else if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (loginProvider.firstPassCode != null &&
              loginProvider.firstPassCode.length >= 1) {
            loginProvider.setFirstPassCode(loginProvider.firstPassCode
                .substring(0, loginProvider.firstPassCode.length - 1));
          } else {
            loginProvider.setFirstPassCode(null);
          }
        }
        // passcode creation 2nd step (confirmation)
        else if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (loginProvider.secondPassCode != null &&
              loginProvider.secondPassCode.length >= 1) {
            loginProvider.setSecondPassCode(loginProvider.secondPassCode
                .substring(0, loginProvider.secondPassCode.length - 1));
          } else {
            loginProvider.setSecondPassCode(null);
          }
        }
      },
      child: Icon(
        Icons.arrow_back,
        size: 16.0,
      ),
      shape: CircleBorder(side: BorderSide(color: Colors.blue[900])),
      padding: EdgeInsets.all(20.0),
      splashColor: Colors.blue[700],
    );
  }

  /// A widget representing the passcode indicator (number of digits entered)
  Widget _passcodeIndicator(LoginProvider loginProvider) {
    final List<Widget> digits = new List<Widget>();
    for (var i = 0; i < 6; i++) {
      digits.add(
        Container(
          margin: EdgeInsets.only(left: 4.0, right: 4.0),
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[900]),
            color: ((loginProvider.loginStatus == LoginStatus.PasscodeStep &&
                        (loginProvider.loginPassCode == null ||
                            loginProvider.loginPassCode.length <= i)) ||
                    (loginProvider.loginStatus ==
                            LoginStatus.CreatePasscodeStep &&
                        (loginProvider.firstPassCode == null ||
                            loginProvider.firstPassCode.length <= i)) ||
                    (loginProvider.loginStatus ==
                            LoginStatus.ConfirmPasscodeStep &&
                        (loginProvider.secondPassCode == null ||
                            loginProvider.secondPassCode.length <= i)))
                ? Colors.transparent
                : Colors.blue[700],
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits,
    );
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

    final _passcodeField = Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(1, _loginProvider),
            _passcodeDigit(2, _loginProvider),
            _passcodeDigit(3, _loginProvider),
          ],
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(4, _loginProvider),
            _passcodeDigit(5, _loginProvider),
            _passcodeDigit(6, _loginProvider),
          ],
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(7, _loginProvider),
            _passcodeDigit(8, _loginProvider),
            _passcodeDigit(9, _loginProvider),
          ],
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(onPressed: () {}, child: null),
            _passcodeDigit(0, _loginProvider),
            _passcodeBack(_loginProvider),
          ],
        )
      ],
    );

    final _passcodeForm = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _logo,
          SizedBox(height: 36.0),
          Text(
            "Saisissez votre passcode",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.0),
          _passcodeIndicator(_loginProvider),
          SizedBox(height: 24.0),
          _passcodeField,
        ],
      ),
    );

    return _passcodeForm;
  }
}
