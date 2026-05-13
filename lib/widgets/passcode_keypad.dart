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

import 'package:flutter/material.dart';

/// A generic 6-digit numeric keypad with a row of dot indicators.
///
/// This widget is intentionally provider-agnostic: callers pass the
/// current [value] string (0–6 chars) and receive change notifications
/// via [onChanged]. It is reused by:
///  - the login [PasscodeWidget] flow (3 sub-buffers driven by
///    `LoginProvider`/`PasscodeProvider`);
///  - the in-app "Change passcode" screen (3 local buffers).
///
/// When [autoSubmit] is set, the callback is fired with the complete
/// value once the 6th digit is entered, handy for auto-validating the
/// login screen.
class PasscodeKeypad extends StatelessWidget {
  const PasscodeKeypad({Key? key, required this.value, required this.onChanged, this.autoSubmit, this.enabled = true})
    : super(key: key);

  /// Current passcode value (0 to 6 digits).
  final String value;

  /// Called whenever the value changes (digit appended or backspace).
  /// Receives the new full value (may be empty).
  final ValueChanged<String> onChanged;

  /// Optional callback fired once the value reaches 6 digits.
  /// Useful for the login screen which auto-submits on completion.
  final ValueChanged<String>? autoSubmit;

  /// When false, the keypad is shown but does not respond to taps,
  /// useful while a server call is in flight.
  final bool enabled;

  void _append(int digit) {
    if (!enabled) return;
    if (value.length >= 6) return;
    final String next = value + '$digit';
    onChanged(next);
    if (next.length == 6 && autoSubmit != null) {
      autoSubmit!(next);
    }
  }

  void _backspace() {
    if (!enabled) return;
    if (value.isEmpty) return;
    onChanged(value.substring(0, value.length - 1));
  }

  Widget _digitButton(int digit) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 80.0,
        height: 64.0,
        child: TextButton(
          onPressed: () => _append(digit),
          style: TextButton.styleFrom(
            shape: CircleBorder(side: BorderSide(color: Colors.blue[900]!)),
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
            disabledForegroundColor: Colors.blue[700],
          ),
          child: Text('$digit', style: const TextStyle(fontSize: 18.0)),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 80.0,
        height: 64.0,
        child: TextButton(
          onPressed: _backspace,
          style: TextButton.styleFrom(
            shape: CircleBorder(side: BorderSide(color: Colors.blue[900]!)),
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
            disabledForegroundColor: Colors.blue[700],
          ),
          child: const Icon(Icons.arrow_back, size: 22.0),
        ),
      ),
    );
  }

  /// Row of 6 dots — filled for each digit entered.
  Widget _indicator() {
    final List<Widget> dots = [];
    for (int i = 0; i < 6; i++) {
      dots.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[900]!),
            color: value.length > i ? Colors.blue[700] : Colors.transparent,
          ),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _indicator(),
        const SizedBox(height: 12.0),
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_digitButton(1), _digitButton(2), _digitButton(3)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_digitButton(4), _digitButton(5), _digitButton(6)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_digitButton(7), _digitButton(8), _digitButton(9)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // empty placeholder on the left so the "0" stays centred
                const Padding(padding: EdgeInsets.all(6.0), child: SizedBox(width: 80.0, height: 64.0)),
                _digitButton(0),
                _backspaceButton(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
