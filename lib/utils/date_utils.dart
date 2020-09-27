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

import 'package:intl/intl.dart';

/// class that holds date utility functions
class DateUtils {
  /// convert the specified [input] string to a DateTime object according to the specified [format]
  /// return null if the specified input string is not a valid date
  static DateTime convertToDate(String input, String format) {
    try {
      return DateFormat(format, 'fr').parseStrict(input);
    } catch (e) {
      return null;
    }
  }

  /// convert the specified [input] DateTime object to a String according to the specified [format]
  /// return null if the specified input is not a valid date
  static String convertToString(DateTime input, String format) {
    try {
      return DateFormat(format, 'fr').format(input);
    } catch (e) {
      return null;
    }
  }

  /// check if the specified [date] (as string according to the specified [format]) is before the current date
  /// also return true if the specified date string is null or empty
  static bool isBeforeNow(String date, String format) {
    if (date.isEmpty) return true;
    final DateTime d = convertToDate(date, format);
    return d != null && d.isBefore(DateTime.now());
  }

  /// check if the specified [date] (as string according to the specified [format]) is after the current date
  /// also return true if the specified date string is null or empty
  static bool isAfterNow(String date, String format) {
    if (date.isEmpty) return true;
    final DateTime d = convertToDate(date, format);
    return d != null && d.isAfter(DateTime.now());
  }

  /// format the specified [duration] (integer representing a number of milliseconds) as string
  static String toLapTimeString(int duration) {
    if (duration == null) return null;
    return "${Duration(milliseconds: duration).inMinutes.remainder(60).toString().padLeft(2, '0')}'${Duration(milliseconds: duration).inSeconds.remainder(60).toString().padLeft(2, '0')}\"${Duration(milliseconds: duration).inMilliseconds.remainder(1000)}";
  }

  /// format the specified [lapTime] string to an integer representing the number of milliseconds
  static int toLapTimeDuration(String lapTime) {
    if (lapTime == null || lapTime.length == 0) return null;
    final int minutes = int.parse(lapTime.substring(0, lapTime.indexOf('\'')));
    final int seconds = int.parse(lapTime.substring(lapTime.indexOf('\'')+1, lapTime.indexOf('"')));
    final int milliseconds = int.parse(lapTime.substring(lapTime.indexOf('"')+1));
    return minutes*60000 + seconds*100 + milliseconds;
  }
}
