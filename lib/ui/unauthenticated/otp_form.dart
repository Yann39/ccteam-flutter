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
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class OtpForm extends StatefulWidget {
  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final Logger _log = new Logger('OtpForm');

  final GlobalKey<FormState> _otpFormKey = new GlobalKey<FormState>();

  // OTP digits
  String _otpDigit0;
  String _otpDigit1;
  String _otpDigit2;
  String _otpDigit3;

  // each OTP digit will be attributed a focus node so we can focus next field automatically when typing
  var _otpFocusNodes = List.generate(4, (index) => FocusNode());

  /// Method that resend the OTP to the user according to information specified in the related form.
  /// The old OTP will be invalidated and the timer reset.
  _doResendOtp(BuildContext context) async {
    Provider.of<LoginProvider>(context, listen: false).resendOtp().then(
        (value) {
      Provider.of<TimerProvider>(context, listen: false).startCountDown(600);
    }, onError: (error) {
      _log.severe(error.toString());
    });
  }

  /// Method that check the OTP specified in the related form.
  /// It updates the login step status according to the result.
  _doCheckOtp(BuildContext context) async {
    final FormState _form = _otpFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      _form.save();

      // build and set OTP from collected digits
      Provider.of<LoginProvider>(context, listen: false).loggedMember.otp =
          "$_otpDigit0$_otpDigit1$_otpDigit2$_otpDigit3";

      _log.info(
          "OTP to be sent ${Provider.of<LoginProvider>(context, listen: false).loggedMember.otp}");

      // check OTP
      Provider.of<LoginProvider>(context, listen: false)
          .confirmEmail()
          .then((value) {}, onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  /// A widget representing a digit of the OTP
  Widget _otpDigitBox(int digitId) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      alignment: Alignment.center,
      height: 50,
      width: 50,
      child: TextFormField(
        autofocus: digitId == 0 ? true : false,
        focusNode: _otpFocusNodes[digitId],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(border: InputBorder.none, counterText: ''),
        onChanged: (value) => {
          if (value.isEmpty && digitId > 0)
            _otpFocusNodes[digitId - 1].requestFocus()
          else if (value.isNotEmpty && digitId < 3)
            _otpFocusNodes[digitId + 1].requestFocus()
        },
        maxLines: 1,
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        onSaved: (val) => {
          if (digitId == 0)
            _otpDigit0 = val
          else if (digitId == 1)
            _otpDigit1 = val
          else if (digitId == 2)
            _otpDigit2 = val
          else if (digitId == 3)
            _otpDigit3 = val
        },
        initialValue: digitId == 0
            ? _otpDigit0
            : digitId == 1
                ? _otpDigit1
                : digitId == 2 ? _otpDigit2 : digitId == 3 ? _otpDigit3 : null,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[700], width: 2.0),
        borderRadius: BorderRadius.circular(4),
      ),
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

    final _otpField = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpDigitBox(0),
        _otpDigitBox(1),
        _otpDigitBox(2),
        _otpDigitBox(3),
      ],
    );

    final _otpVerifyButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _doCheckOtp(context);
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
                  AppString.verify,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _resendOtpButton = Builder(
      builder: (BuildContext context) {
        return FlatButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _doResendOtp(context);
          },
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
                  AppString.resendOtp.toUpperCase(),
                  style: TextStyle(color: Colors.blue[900]),
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

    final _otpForm = Form(
      key: _otpFormKey,
      autovalidate: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _logo,
            SizedBox(height: 36.0),
            Text(
              "Vérification de l'adresse e-mail",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: AppString.infoLoginOtp),
                  TextSpan(
                      text:
                          " ${_loginProvider.loggedMember.email}".toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            _otpField,
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${AppString.timeLeft} : ",
                  style: TextStyle(fontSize: 14.0),
                ),
                CountDownTimer(
                    textStyle:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Code non reçu ?"),
                _resendOtpButton,
              ],
            ),
            _otpVerifyButton,
            _backButton,
          ],
        ),
      ),
    );

    return _otpForm;
  }
}
