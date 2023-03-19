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

import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/providers/passcode_provider.dart';
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/chachatte_logo.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PasscodeForm extends StatefulWidget {
  @override
  _PasscodeFormState createState() => _PasscodeFormState();
}

class _PasscodeFormState extends State<PasscodeForm> {
  final Logger _log = new Logger('PasscodeForm');

  /// Log in the user according to the information specified in the related form.
  /// It updates the login step status and the authentication status according to the result.
  _doLogin(BuildContext context, PasscodeProvider passcodeProvider) async {
    final MessageProvider _messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _loginProvider.loginMember(passcodeProvider.loginPassCode).then((value) {
      // clear passcode once logged
      passcodeProvider.loginPassCode = null;
    }, onError: (error) {
      _log.severe(error.toString());
      // display error message
      _messageProvider.setMessage(AppUtils.extractExceptionMessage(error), MessageType.ERROR);
      // clear passcode so user can try again with a new one
      passcodeProvider.loginPassCode = null;
    });
  }

  /// A widget representing a digit of the passcode
  Widget _passcodeDigit(int digitId, LoginProvider loginProvider, PasscodeProvider passcodeProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () {
          // passcode for logging in
          if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
            // if 6 digits have already been entered, ignore any tap
            if (passcodeProvider.loginPassCode != null && passcodeProvider.loginPassCode.length >= 6) {
              return;
            }
            // update the provider, so we can update the digits indicator
            passcodeProvider.loginPassCode =
                (passcodeProvider.loginPassCode != null ? passcodeProvider.loginPassCode : "") + "$digitId";
            // auto submit form when last digit is entered
            if (passcodeProvider.loginPassCode != null && passcodeProvider.loginPassCode.length >= 6) {
              _doLogin(context, passcodeProvider);
            }
          }
          // passcode creation 1st step
          else if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
            // if 6 digits have already been entered, ignore any tap
            if (passcodeProvider.firstPassCode != null && passcodeProvider.firstPassCode.length >= 6) {
              return;
            }
            // update the provider, so we can update the digits indicator
            loginProvider.firstPassCode =
                ((passcodeProvider.firstPassCode != null ? passcodeProvider.firstPassCode : "") + "$digitId");
          }
          // passcode creation 2nd step (confirmation)
          else if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
            // if 6 digits have already been entered, ignore any tap
            if (passcodeProvider.secondPassCode != null && passcodeProvider.secondPassCode.length >= 6) {
              return;
            }
            // update the provider, so we can update the digits indicator
            passcodeProvider.secondPassCode =
                (passcodeProvider.secondPassCode != null ? passcodeProvider.secondPassCode : "") + "$digitId";
          }
        },
        style: TextButton.styleFrom(
          shape: CircleBorder(side: BorderSide(color: Colors.blue[900])),
          foregroundColor: Colors.black,
          padding: EdgeInsets.all(20.0),
          disabledForegroundColor: Colors.blue[700],
        ),
        child: Text("$digitId"),
      ),
    );
  }

  /// A widget representing the back button of the passcode
  Widget _passcodeBack(LoginProvider loginProvider, PasscodeProvider passcodeProvider) {
    return TextButton(
      onPressed: () {
        // passcode for logging in
        if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (passcodeProvider.loginPassCode != null && passcodeProvider.loginPassCode.length >= 1) {
            passcodeProvider.loginPassCode =
                passcodeProvider.loginPassCode.substring(0, passcodeProvider.loginPassCode.length - 1);
          } else {
            passcodeProvider.loginPassCode = null;
          }
        }
        // passcode creation 1st step
        else if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (passcodeProvider.firstPassCode != null && passcodeProvider.firstPassCode.length >= 1) {
            passcodeProvider.firstPassCode =
                passcodeProvider.firstPassCode.substring(0, passcodeProvider.firstPassCode.length - 1);
          } else {
            passcodeProvider.firstPassCode = null;
          }
        }
        // passcode creation 2nd step (confirmation)
        else if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
          // remove last digit or set it to null if it was the last one
          if (passcodeProvider.secondPassCode != null && passcodeProvider.secondPassCode.length >= 1) {
            passcodeProvider.secondPassCode =
                passcodeProvider.secondPassCode.substring(0, passcodeProvider.secondPassCode.length - 1);
          } else {
            passcodeProvider.secondPassCode = null;
          }
        }
      },
      child: Icon(
        Icons.arrow_back,
        size: 16.0,
      ),
      style: TextButton.styleFrom(
        shape: CircleBorder(side: BorderSide(color: Colors.blue[900])),
        primary: Colors.black,
        padding: EdgeInsets.all(20.0),
        onSurface: Colors.blue[700],
      ),
    );
  }

  /// A widget representing the passcode indicator (number of digits entered)
  Widget _passcodeIndicator(LoginProvider loginProvider, PasscodeProvider passcodeProvider) {
    final List<Widget> digits = [];
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
                        (passcodeProvider.loginPassCode == null || passcodeProvider.loginPassCode.length <= i)) ||
                    (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep &&
                        (passcodeProvider.firstPassCode == null || passcodeProvider.firstPassCode.length <= i)) ||
                    (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep &&
                        (passcodeProvider.secondPassCode == null || passcodeProvider.secondPassCode.length <= i)))
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

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final PasscodeProvider _passcodeProvider = Provider.of<PasscodeProvider>(context, listen: true);

    _log.info("Building PasscodeForm...");

    final _passcodeField = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(1, _loginProvider, _passcodeProvider),
            _passcodeDigit(2, _loginProvider, _passcodeProvider),
            _passcodeDigit(3, _loginProvider, _passcodeProvider),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(4, _loginProvider, _passcodeProvider),
            _passcodeDigit(5, _loginProvider, _passcodeProvider),
            _passcodeDigit(6, _loginProvider, _passcodeProvider),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _passcodeDigit(7, _loginProvider, _passcodeProvider),
            _passcodeDigit(8, _loginProvider, _passcodeProvider),
            _passcodeDigit(9, _loginProvider, _passcodeProvider),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: () {}, child: null),
            _passcodeDigit(0, _loginProvider, _passcodeProvider),
            _passcodeBack(_loginProvider, _passcodeProvider),
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
          ChachatteLogo(),
          SizedBox(height: 36.0),
          Text(
            AppString.enterPasscode,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.0),
          _passcodeIndicator(_loginProvider, _passcodeProvider),
          SizedBox(height: 24.0),
          _passcodeField,
          SizedBox(height: 24.0),
          TextButton(
            key: Key('useAnotherEmailAddressButton'),
            onPressed: () {
              _passcodeProvider.loginPassCode = null;
              _loginProvider.goToPreviousLoginStep();
            },
            child: Text(
              AppString.useAnotherEmailAddress,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );

    return _passcodeForm;
  }
}
