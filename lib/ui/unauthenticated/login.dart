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
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/timer_provider.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Logger _log = new Logger('Login');

  final GlobalKey<FormState> _emailFormKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _preRegisterFormKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey = new GlobalKey<FormState>();

  // the user to log in or create
  final Member _newMember = new Member();

  // OTP digits
  String _otpDigit0;
  String _otpDigit1;
  String _otpDigit2;
  String _otpDigit3;

  // each OTP digit will be attributed a focus node so we can focus next field automatically when typing
  var _otpFocusNodes = List.generate(4, (index) => FocusNode());

  /// Method that check the account associated to the e-mail address specified in the related form.
  /// It updates the login step status according to the result.
  _doCheckAccount(BuildContext context) async {
    final FormState _form = _emailFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // check account
      Provider.of<LoginProvider>(context, listen: false).checkAccount(_newMember).then((value) {}, onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Method that pre-register the user according to information specified in the related form.
  /// It updates the login step status according to the result.
  _doPreRegisterUser(BuildContext context) async {
    final FormState _form = _preRegisterFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      _form.save();

      // register user
      Provider.of<LoginProvider>(context, listen: false).preRegisterMember(_newMember).then((value) {
        Provider.of<TimerProvider>(context, listen: false).startCountDown(600);
      }, onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Method that resend the OTP to the user according to information specified in the related form.
  /// The old OTP will be invalidated and the timer reset.
  _doResendOtp(BuildContext context) async {
    Provider.of<LoginProvider>(context, listen: false).resendOtp(_newMember).then((value) {
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
      Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      _form.save();

      // build and set OTP from collected digits
      _newMember.otp = "$_otpDigit0$_otpDigit1$_otpDigit2$_otpDigit3";

      _log.info("OTP to be sent ${_newMember.otp}");

      // check OTP
      Provider.of<LoginProvider>(context, listen: false).confirmEmail(_newMember).then((value) {}, onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Complete user registration according to the password specified in the related form.
  /// It updates the login step status according to the result.
  _doCompleteRegistration(BuildContext context) async {
    // check that the 2 passcodes match
    if (Provider.of<LoginProvider>(context, listen: false).firstPassCode !=
        Provider.of<LoginProvider>(context, listen: false).secondPassCode) {
      _log.severe("Passcodes do not match");
    } else {
      // set password
      _newMember.password = Provider.of<LoginProvider>(context, listen: false).secondPassCode;
      // complete registration
      Provider.of<LoginProvider>(context, listen: false).completeRegistration(_newMember).then((value) {},
          onError: (error) {
        _log.severe(error.toString());
      });
    }
  }

  /// Method that log in the user according to the information specified in the related form.
  /// It updates the login step status and the authentication status according to the result.
  _doLogin(BuildContext context) async {
    _newMember.password = Provider.of<LoginProvider>(context, listen: false).loginPassCode;
    Provider.of<LoginProvider>(context, listen: false).loginMember(_newMember).then((value) {}, onError: (error) {
      _log.severe(error.toString());
    });
  }

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  /// Method that update the current login status to go to the confirm passcode step
  _goToConfirmPasscode() {
    _log.info("passcode is ${Provider.of<LoginProvider>(context, listen: false).firstPassCode}");
    Provider.of<LoginProvider>(context, listen: false).setLoginStatus(LoginStatus.ConfirmPasscodeStep);
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
            : digitId == 1 ? _otpDigit1 : digitId == 2 ? _otpDigit2 : digitId == 3 ? _otpDigit3 : null,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[700], width: 2.0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// A widget representing a digit of the passcode
  Widget _passcodeDigit(int digitId, LoginProvider loginProvider) {
    return FlatButton(
      onPressed: () {
        if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
          if (loginProvider.loginPassCode != null && loginProvider.loginPassCode.length >= 6) {
            return;
          }
          loginProvider
              .setLoginPassCode((loginProvider.loginPassCode != null ? loginProvider.loginPassCode : "") + "$digitId");
        }

        if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
          if (loginProvider.firstPassCode != null && loginProvider.firstPassCode.length >= 6) {
            return;
          }
          loginProvider
              .setFirstPassCode((loginProvider.firstPassCode != null ? loginProvider.firstPassCode : "") + "$digitId");
        }

        if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
          if (loginProvider.secondPassCode != null && loginProvider.secondPassCode.length >= 6) {
            return;
          }
          loginProvider.setSecondPassCode(
              (loginProvider.secondPassCode != null ? loginProvider.secondPassCode : "") + "$digitId");
        }
      },
      child: Text("$digitId"),
      shape: CircleBorder(side: BorderSide(color: Colors.blue[900])),
      padding: EdgeInsets.all(20.0),
      splashColor: Colors.blue[700],
      disabledColor: Colors.grey[500].withOpacity(0.4),
    );
  }

  /// A widget representing a digit of the passcode
  Widget _passcodeBack(LoginProvider loginProvider) {
    return FlatButton(
      onPressed: () {
        if (loginProvider.loginStatus == LoginStatus.PasscodeStep) {
          if (loginProvider.loginPassCode != null && loginProvider.loginPassCode.length >= 1) {
            loginProvider
                .setLoginPassCode(loginProvider.loginPassCode.substring(0, loginProvider.loginPassCode.length - 1));
          } else {
            loginProvider.setLoginPassCode(null);
          }
        }

        if (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep) {
          if (loginProvider.firstPassCode != null && loginProvider.firstPassCode.length >= 1) {
            loginProvider
                .setFirstPassCode(loginProvider.firstPassCode.substring(0, loginProvider.firstPassCode.length - 1));
          } else {
            loginProvider.setFirstPassCode(null);
          }
        }

        if (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep) {
          if (loginProvider.secondPassCode != null && loginProvider.secondPassCode.length >= 1) {
            loginProvider
                .setSecondPassCode(loginProvider.secondPassCode.substring(0, loginProvider.secondPassCode.length - 1));
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
      digits.add(Container(
        margin: EdgeInsets.only(left: 4.0, right: 4.0),
        width: 16.0,
        height: 16.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue[900]),
          color: ((loginProvider.loginStatus == LoginStatus.PasscodeStep &&
                      (loginProvider.loginPassCode == null || loginProvider.loginPassCode.length <= i)) ||
                  (loginProvider.loginStatus == LoginStatus.CreatePasscodeStep &&
                      (loginProvider.firstPassCode == null || loginProvider.firstPassCode.length <= i)) ||
                  (loginProvider.loginStatus == LoginStatus.ConfirmPasscodeStep &&
                      (loginProvider.secondPassCode == null || loginProvider.secondPassCode.length <= i)))
              ? Colors.transparent
              : Colors.blue[700],
        ),
      ));
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
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building Login...");

    final _firstNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberFirstNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _newMember.firstName = val,
      initialValue: _newMember.firstName,
    );

    final _lastNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberLastNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _newMember.lastName = val,
      initialValue: _newMember.lastName,
    );

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

    final _otpField = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpDigitBox(0),
        _otpDigitBox(1),
        _otpDigitBox(2),
        _otpDigitBox(3),
      ],
    );

    final _forgotPasswordButton = FlatButton(
      child: Text(
        AppString.forgotPassword,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/forgotPassword');
      },
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

    final _passcodeValidateButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _goToConfirmPasscode();
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
                  AppString.validate,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _passcodeLoginButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _doLogin(context);
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
                  AppString.connect,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _passcodeCreateButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _doCompleteRegistration(context);
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
                  AppString.validate,
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

    final _emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700])),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.mail, color: Colors.black87),
        hintText: AppString.loginEmailHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => val.isEmpty
          ? AppString.memberEmailMandatory
          : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _newMember.email = val,
      initialValue: _newMember.email,
    );

    final _emailContinueButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: () {
            _doCheckAccount(context);
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
                  AppString.continue1,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _emailForm = Form(
      key: _emailFormKey,
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
              "Identification",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            _emailField,
            SizedBox(height: 16.0),
            Text(
              AppString.infoLoginEmail,
              style: TextStyle(fontSize: 15.0, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 32.0),
            _emailContinueButton,
          ],
        ),
      ),
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
                  TextSpan(text: " ${_newMember.email}".toLowerCase(), style: TextStyle(fontWeight: FontWeight.bold)),
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
                  TextSpan(text: " ${_newMember.email}".toLowerCase(), style: TextStyle(fontWeight: FontWeight.bold)),
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
                CountDownTimer(textStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
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

    final _createPasscodeForm = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _logo,
          SizedBox(height: 36.0),
          Text(
            "Création de votre passcode",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            AppString.passcodeInfo,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.0),
          _passcodeIndicator(_loginProvider),
          SizedBox(height: 24.0),
          _passcodeField,
          SizedBox(height: 32.0),
          _passcodeValidateButton,
          _backButton,
        ],
      ),
    );

    final _confirmPasscodeForm = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _logo,
          SizedBox(height: 36.0),
          Text(
            "Confirmation de votre passcode",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            AppString.confirmPasscodeInfo,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.0),
          _passcodeIndicator(_loginProvider),
          SizedBox(height: 24.0),
          _passcodeField,
          SizedBox(height: 32.0),
          _passcodeCreateButton,
          _backButton,
        ],
      ),
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
          SizedBox(height: 32.0),
          _passcodeLoginButton,
          _backButton,
        ],
      ),
    );

    /// Display the right form depending on the current login status
    Widget _displayForm() {
      switch (Provider.of<LoginProvider>(context, listen: false).loginStatus) {
        case LoginStatus.NotInitiated:
          return _emailForm;
          break;
        case LoginStatus.EmailStep:
          return _emailForm;
          break;
        case LoginStatus.EmailAndInfoStep:
          return _preRegisterForm;
          break;
        case LoginStatus.OtpStep:
          return _otpForm;
          break;
        case LoginStatus.CreatePasscodeStep:
          return _createPasscodeForm;
          break;
        case LoginStatus.ConfirmPasscodeStep:
          return _confirmPasscodeForm;
          break;
        case LoginStatus.PasscodeStep:
          return _passcodeForm;
          break;
        default:
          return _emailForm;
      }
    }

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
              Color.fromRGBO(255, 255, 255, 0.0),
              BlendMode.modulate,
            ),
          ),
          gradient: LinearGradient(
            colors: [Colors.blue[200], Colors.deepPurple[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            tileMode: TileMode.clamp,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            reverse: true,
            child: _displayForm(),
          ),
        ),
      ),
    );
  }
}
