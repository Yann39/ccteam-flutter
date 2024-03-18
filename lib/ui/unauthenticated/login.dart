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
import 'package:ccteam/ui/unauthenticated/confirm_passcode_form.dart';
import 'package:ccteam/ui/unauthenticated/create_passcode_form.dart';
import 'package:ccteam/ui/unauthenticated/email_form.dart';
import 'package:ccteam/ui/unauthenticated/otp_form.dart';
import 'package:ccteam/ui/unauthenticated/passcode_form.dart';
import 'package:ccteam/ui/unauthenticated/register_form.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Logger _log = new Logger('Login');

  Widget build(BuildContext context) {
    _log.info("Building Login...");

    /// Display the right form depending on the current login status
    Widget _displayForm() {
      switch (Provider.of<LoginProvider>(context, listen: false).loginStatus) {
        case LoginStatus.EmailStep:
          return EmailForm();
          break;
        case LoginStatus.EmailAndInfoStep:
          return RegisterForm();
          break;
        case LoginStatus.OtpStep:
          return OtpForm();
          break;
        case LoginStatus.CreatePasscodeStep:
          return CreatePasscodeForm();
          break;
        case LoginStatus.ConfirmPasscodeStep:
          return ConfirmPasscodeForm();
          break;
        case LoginStatus.PasscodeStep:
          return PasscodeForm();
          break;
        default:
          return EmailForm();
      }
    }

    return GestureDetector(
      onTap: () {
        // allow to dismiss the keyboard when clicking outside
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: CustomDecorations.bluePurpleGradient,
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
