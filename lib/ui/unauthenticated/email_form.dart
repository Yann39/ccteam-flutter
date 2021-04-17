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
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class EmailForm extends StatefulWidget {
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final Logger _log = new Logger('EmailForm');

  final GlobalKey<FormState> _emailFormKey = new GlobalKey<FormState>();

  String _email;

  /// Method that check the account associated to the e-mail address specified in the related form.
  /// It updates the login step status according to the result.
  _doCheckAccount(BuildContext context) async {
    final FormState _form = _emailFormKey.currentState;

    // validate the form
    if (!_form.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // check account
      Provider.of<LoginProvider>(context, listen: false)
          .checkAccount(_email)
          .then((value) {}, onError: (error) {
        _log.severe(error.toString());
      });
    }
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

    _log.info("Building EmailForm...");

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
      onSaved: (val) => _email = val,
      initialValue: _email,
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

    return _emailForm;
  }
}
