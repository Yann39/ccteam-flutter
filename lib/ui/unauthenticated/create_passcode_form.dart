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

import '../../widgets/ccteam_logo.dart';
import '../../widgets/passcode.dart';

class CreatePasscodeForm extends StatefulWidget {
  @override
  _CreatePasscodeFormState createState() => _CreatePasscodeFormState();
}

class _CreatePasscodeFormState extends State<CreatePasscodeForm> {
  final Logger _log = new Logger('CreatePasscodeForm');

  /// Method that update the current login status to go to the previous step of the identification process.
  _goToPreviousStep() {
    Provider.of<LoginProvider>(context, listen: false).goToPreviousLoginStep();
  }

  /// Method that update the current login status to go to the confirm passcode step
  _goToConfirmPasscode() {
    Provider.of<LoginProvider>(context, listen: false).goToConfirmPassword();
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    _log.info("Building CreatePasscodeForm...");

    final _passcodeValidateButton = Builder(
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
            _goToConfirmPasscode();
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

    final _createPasscodeForm = Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CCTeamLogo(),
          SizedBox(height: 36.0),
          Text(
            AppString.createYourPasscode,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            AppString.passcodeInfo,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.0),
          PasscodeWidget(),
          SizedBox(height: 32.0),
          _passcodeValidateButton,
          _backButton,
        ],
      ),
    );

    return _createPasscodeForm;
  }
}
