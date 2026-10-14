/// Lenient JSON readers shared by the courier models.
int cInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

int? cNullInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double cDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

double? cNullDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String cStr(dynamic v) => v == null ? '' : v.toString().trim();

String? cNullStr(dynamic v) {
  final s = cStr(v);
  return s.isEmpty ? null : s;
}

DateTime? cDate(dynamic v) {
  final s = cNullStr(v);
  return s == null ? null : DateTime.tryParse(s.replaceFirst(' ', 'T'));
}

Map<String, dynamic> cMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
