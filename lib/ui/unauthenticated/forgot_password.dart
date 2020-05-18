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
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPassword();
  }
}

class _ForgotPassword extends State<ForgotPassword> {
  final GlobalKey<FormState> _forgotPasswordFormKey = new GlobalKey<FormState>();
  final Logger _log = new Logger('ForgotPassword');

  String _email;

  /// Method that validates the form then process the login in a loading screen and awaits the result from Navigator.pop
  _doResetPassword(BuildContext context) async {
    final FormState _form = _forgotPasswordFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // submit data to backend then display a message
      Provider.of<LoginProvider>(context, listen: false).askPassword(_email).then((value) {
        Navigator.pop(context, "");
      }, onError: (error) {
        Navigator.pop(context, "");
      });
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building ForgotPassword");

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
            AppString.askNewPassword,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    final _forgotPasswordInfo = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Text(
        AppString.forgotPasswordInfo,
        style: TextStyle(color: Colors.white),
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
        onSaved: (val) => _email = val,
        initialValue: _email,
      ),
    );

    final _cancelButton = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      color: Colors.grey[700],
      child: Text(
        AppString.cancel,
        style: TextStyle(color: Colors.white),
      ),
    );

    final _sendButton = Builder(
      builder: (BuildContext context) {
        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            _doResetPassword(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            AppString.send,
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
                        _logo,
                        SizedBox(height: 44.0),
                        _forgotPasswordInfo,
                        SizedBox(height: 32.0),
                        _emailField,
                        SizedBox(height: 24.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _cancelButton,
                            SizedBox(width: 24.0),
                            _sendButton,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
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
