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

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_button_text.dart';
import 'package:ccteam/widgets/unauthenticated_layout.dart';
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
    final FormState _form = _preRegisterFormKey.currentState!;

    // validate the form
    if (_form.validate()) {
      _form.save();

      final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

      // pre-register user
      _loginProvider.preRegisterMember();
    }
  }

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building RegisterForm...");

    final _firstNameField = TextFormField(
      key: Key('registerFormFirstNameField'),
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      // add extra padding to ensure the field is not hidden by the keyboard when it appears, especially on smaller screens
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 4 * 80),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700]!)),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberFirstNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _loginProvider.firstName = val,
      initialValue: _loginProvider.firstName,
    );

    final _lastNameField = TextFormField(
      key: Key('registerFormLastNameField'),
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      // add extra padding to ensure the field is not hidden by the keyboard when it appears, especially on smaller screens
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 3 * 80),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700]!)),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.person, color: Colors.black87),
        hintText: AppString.memberLastNameHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _loginProvider.lastName = val,
      initialValue: _loginProvider.lastName,
    );

    final _emailField = TextFormField(
      key: Key('registerFormEmailField'),
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      // add extra padding to ensure the field is not hidden by the keyboard when it appears, especially on smaller screens
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 2 * 80),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red[700]!)),
        focusedErrorBorder: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        prefixIcon: Icon(Icons.mail, color: Colors.black87),
        hintText: AppString.loginEmailHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) {
        if (val == null || val.isEmpty) {
          return AppString.memberEmailMandatory;
        } else if (!StringUtils.isValidEmail(val)) {
          return AppString.memberEmailNotValid;
        }
        return null;
      },
      onSaved: (val) => _loginProvider.email = val,
      initialValue: _loginProvider.email,
    );

    final _preRegisterButton = ElevatedButton(
      key: Key('registerFormRegisterButton'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        backgroundColor: Colors.blue[700],
      ),
      onPressed: () {
        _doPreRegisterUser(context);
      },
      child: LoadingButtonText(
        loaderCondition: _loginProvider.loginStatus == LoginStatus.Loading,
        text: Text(AppString.register, style: TextStyle(color: Colors.white)),
      ),
    );

    final _backButton = TextButton(
      onPressed: () {
        _goToPreviousStep();
      },
      child: Text(AppString.back, style: TextStyle(color: Colors.blue[900])),
    );

    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      key: _preRegisterFormKey,
      child: UnauthenticatedLayout(
        title: AppString.registration,
        description: Text(
          AppString.infoRegister,
          style: TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _firstNameField,
            SizedBox(height: 8.0),
            _lastNameField,
            SizedBox(height: 8.0),
            _emailField,
          ],
        ),
        actions: <Widget>[_preRegisterButton, _backButton],
      ),
    );
  }
}
