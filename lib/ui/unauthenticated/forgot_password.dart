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
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/unauthenticated_layout.dart';
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

  late String _email;

  /// Method that validates the form then process the login in a loading screen and awaits the result from Navigator.pop
  _doResetPassword(BuildContext context) async {
    final FormState _form = _forgotPasswordFormKey.currentState!;

    // validate the form
    if (!_form.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
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
    _log.info("Building ForgotPassword...");

    final _emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!),
        ),
        focusedErrorBorder: OutlineInputBorder(),
        prefixIcon: Icon(Icons.mail, color: Colors.black87),
        hintText: AppString.loginEmailHint,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => (val == null || val.isEmpty)
          ? AppString.memberEmailMandatory
          : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _email = val!,
    );

    final _sendButton = Builder(
      builder: (BuildContext context) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            backgroundColor: Colors.blue[700],
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          ),
          onPressed: () {
            _doResetPassword(context);
          },
          child: Text(
            AppString.send,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    final _cancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        AppString.cancel,
        style: TextStyle(color: Colors.blue[900]),
      ),
    );

    return GestureDetector(
      onTap: () {
        // allow to dismiss the keyboard when clicking outside
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: CustomDecorations.bluePurpleGradient,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _forgotPasswordFormKey,
              child: UnauthenticatedLayout(
                title: AppString.askNewPassword,
                description: Text(
                  AppString.forgotPasswordInfo,
                  textAlign: TextAlign.center,
                ),
                body: _emailField,
                actions: <Widget>[
                  _sendButton,
                  _cancelButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
