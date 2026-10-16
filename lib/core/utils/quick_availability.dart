import 'package:equatable/equatable.dart';

/// Per-product Quick availability verdict from the server (never computed here).
///
/// Fails closed: anything the app cannot read as `available` is NOT orderable.
enum QuickAvailabilityStatus {
  available,
  outOfStock,
  areaUnserviceable,
  locationRequired,
  vendorUnavailable,
  variantUnavailable,
  productUnavailable,

  /// Not sent, unreadable or unknown: treated as not orderable.
  unknown;

  static QuickAvailabilityStatus parse(Object? value) {
    switch (value is String ? value.trim().toLowerCase() : null) {
      case 'available':
        return available;
      case 'out_of_stock':
        return outOfStock;
      case 'area_unserviceable':
        return areaUnserviceable;
      case 'location_required':
        return locationRequired;
      case 'vendor_unavailable':
        return vendorUnavailable;
      case 'variant_unavailable':
        return variantUnavailable;
      case 'product_unavailable':
        return productUnavailable;
      default:
        return unknown;
    }
  }

  /// True when the product cannot be bought because of WHERE the customer is
  /// (as opposed to a product-level reason such as stock).
  bool get isLocationLevel =>
      this == areaUnserviceable || this == locationRequired;
}

/// The `availability` object attached to Quick products and returned by
/// `GET /express-30/products/{id}/availability`.
class QuickProductAvailability extends Equatable {
  final QuickAvailabilityStatus status;
  final String? message;

  const QuickProductAvailability({required this.status, this.message});

  /// Only an explicit `available` status can order. A payload that is missing,
  /// malformed or says `can_order: true` next to another status is not orderable.
  bool get canOrder => status == QuickAvailabilityStatus.available;

  /// Null when the server sent no usable availability object.
  static QuickProductAvailability? fromJson(Object? json) {
    if (json is! Map) return null;
    final message = json['message'];
    return QuickProductAvailability(
      status: QuickAvailabilityStatus.parse(json['status']),
      message: message is String && message.trim().isNotEmpty
          ? message.trim()
          : null,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
