/// Delivery types the backend uses for Quick orders.
const Set<String> quickDeliveryTypes = {'30_min', 'express_30', 'quick'};

bool? _flag(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
  }
  return null;
}

/// Single rule for "is this a Quick order": the server `is_quick` flag wins;
/// without it, `delivery_type` in [quickDeliveryTypes] or the legacy
/// `is_express` flag. Anything unknown is Standard.
bool resolveIsQuickOrder({
  Object? isQuick,
  String? deliveryType,
  Object? isExpress,
}) {
  final server = _flag(isQuick);
  if (server != null) return server;
  final type = deliveryType?.trim().toLowerCase();
  if (type != null && quickDeliveryTypes.contains(type)) return true;
  return _flag(isExpress) ?? false;
}

/// Maps a UI filter key ('30_min' / 'normal') to the `delivery_mode` query
/// value of GET /order/orders; null means "no filter".
String? deliveryModeParam(String? filterKey) {
  switch (filterKey?.trim().toLowerCase()) {
    case '30_min':
    case 'quick':
    case 'express_30':
      return 'quick';
    case 'normal':
    case 'standard':
    case '1_day':
      return 'standard';
    default:
      return null;
  }
}
