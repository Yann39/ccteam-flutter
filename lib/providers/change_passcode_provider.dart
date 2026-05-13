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

import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/custom_graphql_exception.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Steps of the in-app "change passcode" flow.
enum ChangePasscodeStep { enterCurrent, enterNew, confirmNew }

/// Drives the 3-step "change my passcode" flow. Kept separate from
/// [PasscodeProvider] (which is used by the unauthenticated login
/// flow) so the two never collide if a user opens the change screen
/// right after logging in.
class ChangePasscodeProvider extends ChangeNotifier {
  final Logger _log = new Logger('ChangePasscodeProvider');
  final MembersService _membersService = new MembersService();

  ChangePasscodeStep _step = ChangePasscodeStep.enterCurrent;
  String _currentBuffer = '';
  String _newBuffer = '';
  String _confirmBuffer = '';
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  /// Error key displayed inline under the keypad. We use stable keys
  /// (rather than raw text) so the screen can localise them and so we
  /// can test them. `null` means no error is shown.
  ///
  /// Known values:
  ///   - "current_wrong" : current passcode does not match
  ///   - "new_mismatch"  : new passcode and confirmation differ
  ///   - "same_passcode" : new passcode equals current one
  ///   - "network"       : generic failure
  String? _errorKey;

  ChangePasscodeStep get step => _step;

  String get currentBuffer => _currentBuffer;

  String get newBuffer => _newBuffer;

  String get confirmBuffer => _confirmBuffer;

  LoadingStatus get loadingStatus => _loadingStatus;

  String? get errorKey => _errorKey;

  /// Whether the user can hit "Validate", i.e. all three buffers are
  /// filled with 6 digits each. The mismatch / equality checks happen
  /// on submission so the user still sees an inline error message.
  bool get canSubmit =>
      _currentBuffer.length == 6 &&
      _newBuffer.length == 6 &&
      _confirmBuffer.length == 6 &&
      _loadingStatus != LoadingStatus.loading;

  /// Set the value of the buffer corresponding to [step]. The screen
  /// auto-advances to the next step once a buffer reaches 6 digits.
  void setBuffer(ChangePasscodeStep step, String value) {
    switch (step) {
      case ChangePasscodeStep.enterCurrent:
        _currentBuffer = value;
        break;
      case ChangePasscodeStep.enterNew:
        _newBuffer = value;
        break;
      case ChangePasscodeStep.confirmNew:
        _confirmBuffer = value;
        break;
    }
    // any edit clears the error, the user is fixing the problem
    if (_errorKey != null) _errorKey = null;
    // auto-advance when the active buffer is full
    if (value.length == 6 && step == _step) {
      _autoAdvance();
    }
    notifyListeners();
  }

  /// Move to a specific step (used by the screen when the user taps
  /// a step header to go back).
  void goToStep(ChangePasscodeStep step) {
    _step = step;
    _errorKey = null;
    notifyListeners();
  }

  void _autoAdvance() {
    switch (_step) {
      case ChangePasscodeStep.enterCurrent:
        _step = ChangePasscodeStep.enterNew;
        break;
      case ChangePasscodeStep.enterNew:
        _step = ChangePasscodeStep.confirmNew;
        break;
      case ChangePasscodeStep.confirmNew:
        // last step, stay here, the validate button takes over
        break;
    }
  }

  /// Submit the change to the backend. Returns true on success so
  /// the caller (UI) can pop back to the previous screen and show a
  /// snackbar. On failure, [errorKey] is populated and the relevant
  /// buffer is reset for re-entry.
  Future<bool> submit() async {
    // client-side checks first, cheaper than a round trip
    if (_newBuffer != _confirmBuffer) {
      _errorKey = "new_mismatch";
      // clear both new + confirm so the user re-types the new passcode from scratch (typical UX for confirm-mismatch flows)
      _newBuffer = '';
      _confirmBuffer = '';
      _step = ChangePasscodeStep.enterNew;
      notifyListeners();
      return false;
    }
    if (_currentBuffer == _newBuffer) {
      _errorKey = "same_passcode";
      _newBuffer = '';
      _confirmBuffer = '';
      _step = ChangePasscodeStep.enterNew;
      notifyListeners();
      return false;
    }

    _loadingStatus = LoadingStatus.loading;
    _errorKey = null;
    notifyListeners();

    try {
      await _membersService.changePasscode(_currentBuffer, _newBuffer);
      _loadingStatus = LoadingStatus.loaded;
      notifyListeners();
      return true;
    } catch (error) {
      _log.warning("changePasscode failed: $error");
      _loadingStatus = LoadingStatus.notLoaded;

      if (error is CustomGraphQlException && error.code == "bad_credentials") {
        // current passcode wrong, bring user back to step 1
        _errorKey = "current_wrong";
        _currentBuffer = '';
        _step = ChangePasscodeStep.enterCurrent;
      } else if (error is CustomGraphQlException && error.code == "same_passcode") {
        // server-side equality check kicked in (shouldn't happen given the client check above, but keep the branch for defence-in-depth)
        _errorKey = "same_passcode";
        _newBuffer = '';
        _confirmBuffer = '';
        _step = ChangePasscodeStep.enterNew;
      } else {
        _errorKey = "network";
      }
      notifyListeners();
      return false;
    }
  }

  /// Reset all state, called from the screen's `initState` so a
  /// previous (cancelled) attempt doesn't leak into a new one.
  void reset() {
    _step = ChangePasscodeStep.enterCurrent;
    _currentBuffer = '';
    _newBuffer = '';
    _confirmBuffer = '';
    _errorKey = null;
    _loadingStatus = LoadingStatus.notLoaded;
    notifyListeners();
  }
}
