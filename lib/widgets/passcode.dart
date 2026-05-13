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
import 'package:ccteam/providers/passcode_provider.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/widgets/passcode_keypad.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// Login-flow passcode widget.
///
/// Thin wrapper around the generic [PasscodeKeypad] that wires the
/// keypad to the [LoginProvider]/[PasscodeProvider]'s buffers, one
/// of three depending on the current [LoginStatus] (login, create,
/// confirm). For an in-app passcode change, use [PasscodeKeypad]
/// directly with your own state.
class PasscodeWidget extends StatefulWidget {
  @override
  _PasscodeWidgetState createState() => _PasscodeWidgetState();
}

class _PasscodeWidgetState extends State<PasscodeWidget> {
  final Logger _log = new Logger('PasscodeWidget');

  /// Log in the user according to the information specified in the related form.
  /// It updates the login step status and the authentication status according to the result.
  _doLogin(BuildContext context, PasscodeProvider passcodeProvider) async {
    Provider.of<LoginProvider>(context, listen: false).loginMember(passcodeProvider.loginPassCode!).then((value) {
      passcodeProvider.loginPassCode = null;
    });
    // clear passcode (either logged successfully or not)
    passcodeProvider.loginPassCode = null;
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final PasscodeProvider _passcodeProvider = Provider.of<PasscodeProvider>(context, listen: true);

    _log.info("Building PasscodeForm...");

    // pick the buffer matching the current login step
    final String currentValue = () {
      switch (_loginProvider.loginStatus) {
        case LoginStatus.PasscodeStep:
          return _passcodeProvider.loginPassCode ?? '';
        case LoginStatus.CreatePasscodeStep:
          return _passcodeProvider.firstPassCode ?? '';
        case LoginStatus.ConfirmPasscodeStep:
          return _passcodeProvider.secondPassCode ?? '';
        default:
          return '';
      }
    }();

    return PasscodeKeypad(
      value: currentValue,
      onChanged: (String newValue) {
        switch (_loginProvider.loginStatus) {
          case LoginStatus.PasscodeStep:
            _passcodeProvider.loginPassCode = newValue.isEmpty ? null : newValue;
            break;
          case LoginStatus.CreatePasscodeStep:
            _passcodeProvider.firstPassCode = newValue.isEmpty ? null : newValue;
            break;
          case LoginStatus.ConfirmPasscodeStep:
            _passcodeProvider.secondPassCode = newValue.isEmpty ? null : newValue;
            break;
          default:
            break;
        }
      },
      autoSubmit: _loginProvider.loginStatus == LoginStatus.PasscodeStep
          ? (String _) => _doLogin(context, _passcodeProvider)
          : null,
    );
  }
}
