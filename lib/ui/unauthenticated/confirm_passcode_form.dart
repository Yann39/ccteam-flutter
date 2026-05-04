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
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../providers/passcode_provider.dart';
import '../../widgets/passcode.dart';
import '../../widgets/unauthenticated_layout.dart';

class ConfirmPasscodeForm extends StatefulWidget {
  @override
  _ConfirmPasscodeFormState createState() => _ConfirmPasscodeFormState();
}

class _ConfirmPasscodeFormState extends State<ConfirmPasscodeForm> {
  final Logger _log = new Logger('ConfirmPasscodeForm');

  /// Complete user registration according to the password specified in the related form.
  /// It updates the login step status according to the result.
  _doCompleteRegistration(BuildContext context) async {
    // check that the 2 passcodes match
    if (Provider.of<PasscodeProvider>(context, listen: false).firstPassCode !=
        Provider.of<PasscodeProvider>(context, listen: false).secondPassCode) {
      _log.severe("Passcodes do not match");
    } else {
      // set password
      //Provider.of<LoginProvider>(context, listen: false).loggedMember!.password = Provider.of<PasscodeProvider>(context, listen: false).secondPassCode;
      // complete registration
      Provider.of<LoginProvider>(context, listen: false).completeRegistration(Provider.of<PasscodeProvider>(context, listen: false).secondPassCode!);
    }
  }

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building ConfirmPasscodeForm...");

    final _passcodeCreateButton = Builder(
      builder: (BuildContext context) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            backgroundColor: Colors.blue[700],
          ),
          onPressed: () {
            _doCompleteRegistration(context);
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
                  AppString.validate,
                  style: TextStyle(color: Colors.white),
                ),
        );
      },
    );

    final _backButton = Builder(
      builder: (BuildContext context) {
        return TextButton(
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

    return UnauthenticatedLayout(
      title: "Confirmation de votre passcode",
      description: Text(
        AppString.confirmPasscodeInfo,
        textAlign: TextAlign.center,
      ),
      body: PasscodeWidget(),
      actions: <Widget>[
        _passcodeCreateButton,
        _backButton,
      ],
    );
  }
}
