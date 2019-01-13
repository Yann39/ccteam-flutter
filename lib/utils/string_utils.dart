/// class that holds string utility functions
class StringUtils {
  /// Check that the specified string is a valid E.164 formatted phone number
  static bool isValidPhoneNumber(String input) {
    final RegExp regex = new RegExp(r'^\+\d\d \d\d\d\d\d\d\d\d\d$');
    return regex.hasMatch(input);
  }

  /// Check if the specified string is a valid e-mail address
  static bool isValidEmail(String input) {
    final RegExp regex = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }

  /// Check if the specified string is a valid price
  /// Maximum 4 digits before decimal(.) point
  /// Maximum 2 digits after decimal point
  static bool isValidPrice(String input) {
    final RegExp regex = new RegExp(r'^\d{0,4}(\.\d{1,2})?$');
    return regex.hasMatch(input);
  }

}
