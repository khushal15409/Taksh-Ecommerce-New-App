/// Masks values that must never reach a log: auth tokens, OTPs, passwords, payment
/// and gateway fields, bank details and personal data (phone, email, address,
/// location). Everything else is kept so a log line stays useful for debugging.
///
/// Use it on any request/response body before it is printed or logged.
const List<String> _sensitiveKeyParts = <String>[
  'token',
  'otp',
  'password',
  'secret',
  'authorization',
  'signature',
  'razorpay',
  'card',
  'cvv',
  'account',
  'ifsc',
  'pan',
  'aadhaar',
  'mobile',
  'phone',
  'contact',
  'email',
  'address',
  'pincode',
  'landmark',
  'latitude',
  'longitude',
  'upi',
  'vpa',
];

const String _mask = '***';
const int _maxStringLength = 200;
const int _maxListItems = 20;
const int _maxDepth = 6;

Object? redactForLog(Object? value, {int depth = 0}) {
  if (depth > _maxDepth) return '…';

  if (value is Map) {
    final redacted = <String, Object?>{};
    value.forEach((key, entry) {
      final name = key.toString();
      final lower = name.toLowerCase();
      final sensitive = _sensitiveKeyParts.any(lower.contains);
      redacted[name] = sensitive ? _mask : redactForLog(entry, depth: depth + 1);
    });
    return redacted;
  }

  if (value is List) {
    return value
        .take(_maxListItems)
        .map((entry) => redactForLog(entry, depth: depth + 1))
        .toList();
  }

  if (value is String && value.length > _maxStringLength) {
    return '${value.substring(0, _maxStringLength)}…';
  }

  return value;
}
