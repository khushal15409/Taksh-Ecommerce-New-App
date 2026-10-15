/// Rupee amounts as the customer sees them: whole amounts without decimals
/// ("₹199"), anything with paise with two decimals ("₹199.50"). Amounts come from
/// the server as exact decimals and are kept as `double` in the app; they are only
/// rounded here, for display.
String formatRupees(num amount) {
  final value = amount.toDouble();
  return value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

/// Parses a money value from JSON (a number, or a numeric string such as "199.50")
/// without losing the paise. Returns null for null / non-numeric input.
double? parseMoney(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
