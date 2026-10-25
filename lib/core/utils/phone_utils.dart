class PhoneUtils {
  const PhoneUtils._();

  // Kenyan phone formats:
  // 07XXXXXXXX, 01XXXXXXXX (10 digits)
  // 7XXXXXXXX, 1XXXXXXXX (9 digits)
  // +2547XXXXXXXX, +2541XXXXXXXX, 2547XXXXXXXX, 2541XXXXXXXX (with country code)
  static final RegExp _kenyanPhoneRegex =
      RegExp(r'^(?:(?:\+?254)|0)?([17]\d{8})$');

  /// Checks if the input represents a valid Kenyan mobile number.
  static bool isValidKenyanPhone(String input) {
    final clean = input.replaceAll(RegExp(r'[\s\-]'), '');
    return _kenyanPhoneRegex.hasMatch(clean);
  }

  /// Normalizes any valid Kenyan phone number to standard E.164 format: +254XXXXXXXXX.
  /// Returns `null` if invalid.
  static String? normalizeKenyanPhone(String input) {
    final clean = input.replaceAll(RegExp(r'[\s\-]'), '');
    final match = _kenyanPhoneRegex.firstMatch(clean);
    if (match != null && match.groupCount >= 1) {
      final nineDigits = match.group(1);
      return '+254$nineDigits';
    }
    return null;
  }
}
