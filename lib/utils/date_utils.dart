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

import 'package:intl/intl.dart';

/// class that holds date utility functions
class AppDateUtils {
  /// convert the specified [input] string to a DateTime object according to the specified [format]
  /// return null if the specified input string is not a valid date
  static DateTime? convertToDate(String input, String format) {
    try {
      return DateFormat(format, 'fr').parseStrict(input);
    } catch (e) {
      return null;
    }
  }

  /// convert the specified [input] DateTime object to a String according to the specified [format]
  /// return null if the specified input is not a valid date
  static String? convertToString(DateTime input, String format) {
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
    final DateTime? d = convertToDate(date, format);
    return d != null && d.isBefore(DateTime.now());
  }

  /// check if the specified [date] (as string according to the specified [format]) is after the current date
  /// also return true if the specified date string is null or empty
  static bool isAfterNow(String date, String format) {
    if (date.isEmpty) return true;
    final DateTime? d = convertToDate(date, format);
    return d != null && d.isAfter(DateTime.now());
  }

  /// Format the specified [duration] (an integer count of milliseconds)
  /// as a lap-time string in the canonical `MM'SS"mmm` form. Minutes
  /// and seconds are zero-padded to 2 digits and milliseconds to 3 —
  /// matches what timing transponders display and what the input mask
  /// in [LapTimeTextInputFormatter] produces.
  static String? toLapTimeString(int? duration) {
    if (duration == null) return null;
    final Duration d = Duration(milliseconds: duration);
    final String mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final String mmm = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return "$mm'$ss\"$mmm";
  }

  /// Parse a `MM'SS"mmm` lap-time string back into a count of
  /// milliseconds. Returns null on a malformed input rather than
  /// throwing — the caller should rely on the form validator to reject
  /// bad values before persisting.
  static int? toLapTimeDuration(String? lapTime) {
    if (lapTime == null || lapTime.isEmpty) return null;
    final int apos = lapTime.indexOf('\'');
    final int quote = lapTime.indexOf('"');
    if (apos < 0 || quote < 0 || quote <= apos) return null;
    try {
      final int minutes = int.parse(lapTime.substring(0, apos));
      final int seconds = int.parse(lapTime.substring(apos + 1, quote));
      final int milliseconds = int.parse(lapTime.substring(quote + 1));
      return minutes * 60000 + seconds * 1000 + milliseconds;
    } catch (_) {
      return null;
    }
  }
}
