import 'package:flutter/material.dart';

/// Field validators shared by the service and courier booking forms.
///
/// Every validator returns the message shown right under the field.
class ServiceFormValidators {
  ServiceFormValidators._();

  static String? requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? value, {String label = 'name'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter $label';
    if (v.length < 2) return 'Enter a valid $label';
    return null;
  }

  /// Indian mobile number: 10 digits starting with 6-9 (same rule as the API).
  static String? mobile(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter mobile number';
    if (!RegExp(r'^\d+$').hasMatch(v))
      return 'Mobile number must contain digits only';
    if (v.length != 10) return 'Enter a valid 10-digit mobile number';
    if (!RegExp(r'^[6-9]').hasMatch(v)) {
      return 'Mobile number must start with 6, 7, 8 or 9';
    }
    return null;
  }

  static String? pincode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter pincode';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'Enter a valid 6-digit pincode';
    if (v.startsWith('0')) return 'Enter a valid 6-digit pincode';
    return null;
  }

  static String? address(String? value, {String label = 'address'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter $label';
    if (v.length < 5) return 'Please enter a more complete $label';
    return null;
  }

  /// A number greater than zero (weight, dimensions).
  static String? positiveNumber(String? value, String label) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter $label';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid $label';
    if (n <= 0) return '$label must be greater than 0';
    return null;
  }
}

/// Validates [keys] one by one so each shows its own message, and scrolls to
/// the first invalid one. Returns true when all are valid.
bool validateFields(List<GlobalKey<FormFieldState<dynamic>>> keys) {
  GlobalKey<FormFieldState<dynamic>>? firstInvalid;
  for (final key in keys) {
    final valid = key.currentState?.validate() ?? true;
    if (!valid) firstInvalid ??= key;
  }
  final ctx = firstInvalid?.currentContext;
  if (ctx != null) {
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.2,
      duration: const Duration(milliseconds: 250),
    );
  }
  return firstInvalid == null;
}
