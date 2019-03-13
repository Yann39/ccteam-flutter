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

import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPassword();
  }
}

class _ForgotPassword extends State<ForgotPassword> {
  final GlobalKey<FormState> _forgotPasswordFormKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _forgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>();

  String _email;

  /// Allow to dismiss the keyboard when clicking outside
  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  /// Method that validates the form then process the login in a loading screen and awaits the result from Navigator.pop
  _doResetPassword() async {
    final FormState form = _forgotPasswordFormKey.currentState;
    final Logger log = new Logger('ForgotPassword');

    if (!form.validate()) {
      _forgotPasswordScaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      final MembersService membersService = new MembersService();

      // submit data to backend then display a message
      membersService.askPassword(_email).then((value) {
        log.fine("Forgot password requested for e-mail : $_email");
        Navigator.pop(context, AppString.memberCreated);
      }, onError: (error) {
        log.fine("Failed to request forgot password", error);
        Navigator.pop(context, AppString.memberCreationFailed);
      });
    }
  }

  Widget build(BuildContext context) {
    final logo = Container(
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
            AppString.askNewPassword,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    final forgotPasswordInfo = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Text(
        AppString.forgotPasswordInfo,
        style: TextStyle(color: Colors.white),
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
          prefixIcon: Icon(Icons.mail, color: Colors.white),
          hintText: AppString.loginEmailHint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        ),
        maxLines: 1,
        inputFormatters: [new LengthLimitingTextInputFormatter(128)],
        validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
        onSaved: (val) => _email = val,
        initialValue: _email,
      ),
    );

    final sendButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            _doResetPassword();
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            AppString.send,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
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
          key: _forgotPasswordScaffoldKey,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _forgotPasswordFormKey,
                    autovalidate: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        logo,
                        SizedBox(height: 44.0),
                        forgotPasswordInfo,
                        SizedBox(height: 32.0),
                        email,
                        SizedBox(height: 24.0),
                        sendButton,
                      ],
                    ),
                  ),
                ),
              ),
              new Positioned(
                //Place it at the top, and not use the entire screen
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent, //No more green
                  elevation: 0.0, //Shadow gone
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
