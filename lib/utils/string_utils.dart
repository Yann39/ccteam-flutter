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

/// class that holds string utility functions
class StringUtils {
  /// Check that the specified [input] string is a valid E.164 formatted phone number
  static bool isValidPhoneNumber(String input) {
    final RegExp regex = new RegExp(r'^\+\d\d \d\d\d\d\d\d\d\d\d$');
    return regex.hasMatch(input);
  }

  /// Check if the specified [input] string is a valid e-mail address
  /// It uses standard HTML5 validation spec, see https://stackoverflow.com/a/16888554/1274485
  static bool isValidEmail(String input) {
    return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(input);
  }

  /// Check if the specified [input] string is a valid price
  /// Maximum 4 digits before decimal(.) point
  /// Maximum 2 digits after decimal point
  static bool isValidPrice(String input) {
    final RegExp regex = new RegExp(r'^\d{0,4}(\.\d{1,2})?$');
    return regex.hasMatch(input);
  }

  /// Capitalize the given [text]
  static String capitalize(String text) => (text != null && text.length > 1)
      ? text[0].toUpperCase() + text.substring(1)
      : text != null ? text.toUpperCase() : null;

}
