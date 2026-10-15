import 'package:equatable/equatable.dart';

/// Backend codes meaning "Quick delivery cannot serve this location".
const String quickNotServiceableCode = 'quick_not_serviceable';
const String quickLocationRequiredCode = 'quick_location_required';

/// Cart errors raised by the server for the delivery bucket rules.
const String deliveryBucketMismatchCode = 'delivery_bucket_mismatch';
const String cartVendorConflictCode = 'cart_vendor_conflict';

/// True for the two Quick serviceability error codes.
bool isQuickServiceabilityCode(String? code) =>
    code == quickNotServiceableCode || code == quickLocationRequiredCode;

bool _asBool(Object? value, {required bool fallback}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
  }
  return fallback;
}

/// Serviceability verdict returned by the server (never computed client side).
class QuickServiceability extends Equatable {
  final bool serviceable;
  final String? code;
  final String? message;

  const QuickServiceability({
    required this.serviceable,
    this.code,
    this.message,
  });

  /// Parses a response `data` map. A payload without a `serviceable` key is a
  /// normal (serviceable) response.
  factory QuickServiceability.fromData(Map<dynamic, dynamic>? data) {
    if (data == null) return const QuickServiceability(serviceable: true);
    final code = data['code'];
    final message = data['message'];
    return QuickServiceability(
      serviceable: _asBool(data['serviceable'], fallback: true),
      code: code is String && code.isNotEmpty ? code : null,
      message: message is String && message.isNotEmpty ? message : null,
    );
  }

  @override
  List<Object?> get props => [serviceable, code, message];
}
