class PaymentCardValidationResult {
  final bool isValid;
  final String? field;

  const PaymentCardValidationResult.valid()
      : isValid = true,
        field = null;

  const PaymentCardValidationResult.invalid(this.field) : isValid = false;
}

class PaymentCardValidator {
  static PaymentCardValidationResult validate({
    required String number,
    required String expiry,
    required String cvv,
    DateTime? now,
  }) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19 || !_passesLuhn(digits)) {
      return const PaymentCardValidationResult.invalid('number');
    }
    if (!_validExpiry(expiry, now ?? DateTime.now())) {
      return const PaymentCardValidationResult.invalid('expiry');
    }
    final cvvDigits = cvv.replaceAll(RegExp(r'\D'), '');
    if (cvvDigits.length < 3 || cvvDigits.length > 4) {
      return const PaymentCardValidationResult.invalid('cvv');
    }
    return const PaymentCardValidationResult.valid();
  }

  static bool _passesLuhn(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static bool _validExpiry(String raw, DateTime now) {
    final match = RegExp(r'^\s*(\d{2})\s*/\s*(\d{2})\s*$').firstMatch(raw);
    if (match == null) return false;
    final month = int.tryParse(match.group(1)!);
    final year = int.tryParse(match.group(2)!);
    if (month == null || year == null || month < 1 || month > 12) {
      return false;
    }
    final fullYear = 2000 + year;
    final expiresAtEndOfMonth = DateTime(fullYear, month + 1, 1);
    return expiresAtEndOfMonth.isAfter(DateTime(now.year, now.month, 1));
  }
}
