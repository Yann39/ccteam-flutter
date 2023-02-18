import 'package:chachatte_team/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountDownTimer extends StatelessWidget {
  final TextStyle textStyle;

  const CountDownTimer({
    Key key,
    this.textStyle,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final TimerProvider _timerProvider =
        Provider.of<TimerProvider>(context, listen: true);
    return Text(
      "${Duration(seconds: _timerProvider.currentValue).inMinutes.remainder(60).toString().padLeft(2, '0')}:${Duration(seconds: _timerProvider.currentValue).inSeconds.remainder(60).toString().padLeft(2, '0')}",
      style: textStyle,
    );
  }
}
