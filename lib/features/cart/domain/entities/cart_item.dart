import 'package:equatable/equatable.dart';

/// Cart item entity representing a product in the cart
class CartItem extends Equatable {
  final int id;
  final int productVariantId;
  final String productName;
  final String sku;
  final String price;
  final int qty;
  final double total;
  final String? image;

  /// Human-readable variant label (e.g. "1kg • Blue"). May be null when the
  /// variant attributes are not available from the cart API.
  final String? variantName;

  /// The product ID (not variant ID) – used for delivery availability checks.
  /// May be null when not enriched from product details.
  final int? productId;

  /// Whether this item supports express 30-min delivery.
  /// Null means unknown (not yet enriched). False / true are explicit values.
  final bool? isExpress30;

  /// The shop this line is bought from. Lines of different shops become separate
  /// orders at checkout. Null when the server did not say.
  final int? vendorId;
  final String? vendorName;

  const CartItem({
    required this.id,
    required this.productVariantId,
    required this.productName,
    required this.sku,
    required this.price,
    required this.qty,
    required this.total,
    this.image,
    this.variantName,
    this.productId,
    this.isExpress30,
    this.vendorId,
    this.vendorName,
  });

  /// Return a copy with updated delivery metadata
  CartItem withDeliveryInfo(
      {required int productId, required bool isExpress30}) {
    return CartItem(
      id: id,
      productVariantId: productVariantId,
      productName: productName,
      sku: sku,
      price: price,
      qty: qty,
      total: total,
      image: image,
      variantName: variantName,
      productId: productId,
      isExpress30: isExpress30,
      vendorId: vendorId,
      vendorName: vendorName,
    );
  }

  /// Return a copy with the variant label resolved.
  CartItem withVariantName(String? variantName) {
    return CartItem(
      id: id,
      productVariantId: productVariantId,
      productName: productName,
      sku: sku,
      price: price,
      qty: qty,
      total: total,
      image: image,
      variantName: variantName,
      productId: productId,
      isExpress30: isExpress30,
      vendorId: vendorId,
      vendorName: vendorName,
    );
  }

  /// Create an empty cart item
  factory CartItem.empty() {
    return const CartItem(
      id: 0,
      productVariantId: 0,
      productName: '',
      sku: '',
      price: '0',
      qty: 0,
      total: 0,
    );
  }

  /// Check if cart item is empty
  bool get isEmpty => id == 0;

  /// Check if cart item is not empty
  bool get isNotEmpty => id != 0;

  /// Get price as double
  double get priceAsDouble => double.tryParse(price) ?? 0.0;

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        productName,
        sku,
        price,
        qty,
        total,
        image,
        variantName,
        productId,
        isExpress30,
        vendorId,
        vendorName,
      ];

  @override
  String toString() {
    return 'CartItem(id: $id, productName: $productName, qty: $qty, total: $total)';
  }
}
