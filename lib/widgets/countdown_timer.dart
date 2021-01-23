import 'dart:async';

import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  final int startValue; // the locale to use to render dates as strings
  final TextStyle textStyle;

  CountDownTimer({
    this.startValue = 600, this.textStyle,
  });

  @override
  State<StatefulWidget> createState() {
    return _CountDownTimerState(startValue);
  }
}

class _CountDownTimerState extends State<CountDownTimer> {
  Timer _timer;
  int _currentValue;

  _CountDownTimerState(int startValue) {
    this._currentValue = startValue;
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_currentValue == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _currentValue--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Text(
      "${Duration(milliseconds: _currentValue).inMinutes.remainder(60).toString().padLeft(2, '0')}:${Duration(milliseconds: _currentValue).inSeconds.remainder(60).toString().padLeft(2, '0')}",
      style: widget.textStyle,
    );
  }
}
