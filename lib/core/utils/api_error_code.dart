/// Reads the machine readable error code (`data.code`) from an API error body.
///
/// Returns null when the body has no non-empty string code.
String? extractApiErrorCode(dynamic body) {
  if (body is! Map) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final code = data['code'];
  if (code is String && code.isNotEmpty) return code;
  return null;
}
