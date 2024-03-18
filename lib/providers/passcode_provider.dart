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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class PasscodeProvider extends ChangeNotifier {
  final Logger _log = new Logger('PasscodeProvider');

  // current passCode being entered for login
  String _loginPassCode;

  // current passCode being created
  String _firstPassCode;

  // current passCode being confirmed
  String _secondPassCode;

  // current error message
  String _errorMessage;

  String get loginPassCode => _loginPassCode;

  String get firstPassCode => _firstPassCode;

  String get secondPassCode => _secondPassCode;

  String get errorMessage => _errorMessage;

  /// Set the current [passcode] used for logging in.
  set loginPassCode(String passcode) {
    _loginPassCode = passcode;
    _log.info("Notifying listeners of PasscodeProvider");
    notifyListeners();
  }

  /// Set the current [passcode] used in registration process.
  set firstPassCode(String passcode) {
    _firstPassCode = passcode;
    _log.info("Notifying listeners of PasscodeProvider");
    notifyListeners();
  }

  /// Set the current [passcode] used in registration process (confirmation).
  set secondPassCode(String passcode) {
    _secondPassCode = passcode;
    _log.info("Notifying listeners of PasscodeProvider");
    notifyListeners();
  }
}
