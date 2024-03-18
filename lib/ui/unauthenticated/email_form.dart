/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/ccteam_logo.dart';
import 'package:ccteam/widgets/loading_button_text.dart';
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
    if (_form.validate()) {
      // this invokes each onSaved event
      _form.save();

      // check account, this will update login status and change page
      Provider.of<LoginProvider>(context, listen: false).checkAccountEmail(_email);
    }
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building EmailForm...");

    final _emailField = TextFormField(
      key: Key('loginEmailField'),
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]),
        ),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        prefixIcon: Icon(Icons.mail, color: Colors.black87),
        hintText: AppString.loginEmailHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) {
        if (val.isEmpty) {
          return AppString.memberEmailMandatory;
        } else if (!StringUtils.isValidEmail(val)) {
          return AppString.memberEmailNotValid;
        }
        return null;
      },
      onSaved: (val) => _email = val,
      initialValue: _email,
    );

    final _emailContinueButton = ElevatedButton(
      key: Key('emailContinueButton'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        backgroundColor: Colors.blue[700],
      ),
      onPressed: () {
        _doCheckAccount(context);
      },
      child: LoadingButtonText(
        loaderCondition: _loginProvider.loginStatus == LoginStatus.Loading,
        text: Text(
          AppString.continue1,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      key: _emailFormKey,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CCTeamLogo(),
            SizedBox(height: 36.0),
            Text(
              AppString.identification,
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
            TextButton(
              key: Key('createAccountButton'),
              onPressed: () {
                _loginProvider.goToRegister();
              },
              child: Text(
                AppString.createAccount,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
