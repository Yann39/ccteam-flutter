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
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/passcode.dart';
import 'package:ccteam/widgets/unauthenticated_layout.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PasscodeForm extends StatefulWidget {
  @override
  _PasscodeFormState createState() => _PasscodeFormState();
}

class _PasscodeFormState extends State<PasscodeForm> {
  final Logger _log = new Logger('PasscodeForm');

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final PasscodeProvider _passcodeProvider = Provider.of<PasscodeProvider>(context, listen: true);

    _log.info("Building PasscodeForm...");

    return UnauthenticatedLayout(
      title: AppString.enterPasscode,
      body: PasscodeWidget(),
      actions: <Widget>[
        TextButton(
          key: Key('useAnotherEmailAddressButton'),
          onPressed: () {
            _passcodeProvider.loginPassCode = null;
            // logout so that the shared preferences are cleared
            _loginProvider.logoutMember();
            _loginProvider.goToPreviousLoginStep();
          },
          child: Text(
            AppString.useAnotherEmailAddress,
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
