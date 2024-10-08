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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  final Logger _log = new Logger('TimerProvider');

  // current timer value in seconds
  int _currentValue = 0;

  int get currentValue => _currentValue;

  /// Start the countdown timer from the specified start value (in seconds)
  void startNewCountDown(int nbSeconds) async {
    // cancel any running timer
    if (_timer != null) {
      _timer!.cancel();
    }

    // restart from the provided start value
    _currentValue = nbSeconds;
    notifyListeners();

    // store start time in the shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('otp_timer', DateTime.now().millisecondsSinceEpoch);

    // start the timer
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_currentValue == 0) {
          timer.cancel();
        } else {
          _currentValue--;
          notifyListeners();
        }
      },
    );
  }

  /// Resume the countdown timer according to specified remaining time (in seconds)
  void resumeCountDown(int nbSeconds) async {
    // cancel any running timer
    if (_timer != null) {
      _timer!.cancel();
    }

    // restart from the provided start value
    _currentValue = nbSeconds;
    notifyListeners();

    // start the timer
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_currentValue == 0) {
          timer.cancel();
        } else {
          _currentValue--;
          notifyListeners();
        }
      },
    );
  }

  /// Resume any existing countdown timer, or start a new one from the specified start value (in seconds)
  void resumeOrStartCountDown(int startValue) async {
    // to read any timer value from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // if a timer is stored, check if it has run out
    if (prefs.containsKey('otp_timer')) {
      final int elapsedTime = DateTime.now().millisecondsSinceEpoch - prefs.getInt('otp_timer')!;
      _log.info("Got back timer value from preferences, elapsed time : $elapsedTime ms");

      // if elapsed time is greater than start value, set it to zero
      if (elapsedTime > startValue * 1000) {
        _log.info("Last timer has run out, user has to resend a new code");
        // todo display message to user
        _currentValue = 0;
        notifyListeners();
      }
      // else start the timer with the remaining time
      else {
        resumeCountDown(startValue - (elapsedTime ~/ 1000));
      }
    }
    // no timer stored, start a new one
    else {
      startNewCountDown(startValue);
    }
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}
