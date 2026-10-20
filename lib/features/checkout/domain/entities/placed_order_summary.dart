import 'package:equatable/equatable.dart';

/// One order created by a checkout. A cart with items from several shops becomes
/// one order per shop, and all of them are shown together after the checkout.
class PlacedOrderSummary extends Equatable {
  final int id;
  final String? orderNumber;
  final String? shopName;
  final String? grandTotal;
  final int itemsCount;

  const PlacedOrderSummary({
    required this.id,
    this.orderNumber,
    this.shopName,
    this.grandTotal,
    this.itemsCount = 0,
  });

  /// Reads one entry of the server's `placed_orders` list. Returns null for an
  /// entry without a usable id, so a malformed entry is skipped, never thrown on.
  static PlacedOrderSummary? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final id = int.tryParse(json['id']?.toString() ?? '');
    if (id == null || id <= 0) return null;
    return PlacedOrderSummary(
      id: id,
      orderNumber: json['order_number']?.toString(),
      shopName: json['shop_name']?.toString(),
      grandTotal: json['grand_total']?.toString(),
      itemsCount: int.tryParse(json['items_count']?.toString() ?? '') ?? 0,
    );
  }

  /// The same shape the server sends, so a list survives a trip through a route.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (orderNumber != null) 'order_number': orderNumber,
    if (shopName != null) 'shop_name': shopName,
    if (grandTotal != null) 'grand_total': grandTotal,
    'items_count': itemsCount,
  };

  /// Parses a whole list (null or malformed gives an empty list).
  static List<PlacedOrderSummary> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(PlacedOrderSummary.tryFromJson)
        .whereType<PlacedOrderSummary>()
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [id, orderNumber, shopName, grandTotal, itemsCount];
}
