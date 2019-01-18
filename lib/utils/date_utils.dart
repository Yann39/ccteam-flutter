import 'package:intl/intl.dart';

/// class that holds date utility functions
class DateUtils {
  /// convert the specified [input] string to a DateTime object according to the specified [format]
  /// return null if the specified input string is not a valid date
  static DateTime convertToDate(String input, String format) {
    try {
      var d = new DateFormat(format).parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  /// convert the specified [input] DateTime object to a String according to the specified [format]
  /// return null if the specified input is not a valid date
  static String convertToString(DateTime input, String format) {
    try {
      var formatter = new DateFormat(format);
      String formatted = formatter.format(input);
      return formatted;
    } catch (e) {
      return null;
    }
  }

  /// check if the specified [date] (as string according to the specified [format]) is before the current date
  /// also return true if the specified date string is null or empty
  static bool isBeforeNow(String date, String format) {
    if (date.isEmpty) return true;
    var d = convertToDate(date, format);
    return d != null && d.isBefore(new DateTime.now());
  }

  /// check if the specified [date] (as string according to the specified [format]) is after the current date
  /// also return true if the specified date string is null or empty
  static bool isAfterNow(String date, String format) {
    if (date.isEmpty) return true;
    var d = convertToDate(date, format);
    return d != null && d.isAfter(new DateTime.now());
  }

}
