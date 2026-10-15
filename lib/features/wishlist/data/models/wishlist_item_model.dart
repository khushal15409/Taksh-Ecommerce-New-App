import 'package:taksh_e_commerce/core/utils/money_format.dart';
import 'package:taksh_e_commerce/features/wishlist/domain/entities/wishlist_item.dart';

/// Model for wishlist item – extends the domain entity with JSON serialization.
///
/// Handles nested product data from the API response, falling back to
/// flat keys when the nested `product` object is not present.
class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productSlug,
    super.productImage,
    super.originalPrice,
    super.salePrice,
    super.inStock,
    super.createdAt,
  });

  /// Parse from JSON – handles both nested and flat product data.
  ///
  /// Nested format (common):
  /// ```json
  /// {
  ///   "id": 1,
  ///   "product_id": 5,
  ///   "product": { "id": 5, "name": "...", "images": [...], ... }
  /// }
  /// ```
  ///
  /// Flat format (fallback):
  /// ```json
  /// {
  ///   "id": 1,
  ///   "product_id": 5,
  ///   "product_name": "...",
  ///   "product_image": "..."
  /// }
  /// ```
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final Map<String, dynamic>? product = rawProduct is Map
        ? Map<String, dynamic>.from(rawProduct)
        : null;

    // ── Extract product ID ─────────────────────────────────────────────
    // Check multiple possible key names (snake_case, camelCase, nested)
    final int parsedProductId = _parseInt(json['product_id']) ??
        _parseInt(json['productId']) ??
        _parseInt(product?['id']) ??
        _parseInt(json['id']) ??
        0;

    // ── Extract product name ───────────────────────────────────────────
    final String parsedName = _asString(product?['name']) ??
        _asString(json['product_name']) ??
        _asString(json['productName']) ??
        _asString(json['name']) ??
        '';

    // ── Extract primary image URL ──────────────────────────────────────
    // Follows the same proven pattern as home ProductModel.fromJson:
    //   1. Direct image_url on the product object
    //   2. Walk the images array, prefer is_primary == true
    //   3. Fall back to first image in the array
    //   4. Flat fallback keys
    String? imageUrl;
    if (product != null) {
      // 1️⃣ Direct image_url on product (common in list responses)
      imageUrl = _asString(product['image_url']);

      // 2️⃣ Walk images array – prefer is_primary, else first image
      if (imageUrl == null || imageUrl.isEmpty) {
        final imagesData = product['images'];
        if (imagesData is List && imagesData.isNotEmpty) {
          for (final img in imagesData) {
            if (img is Map && img['is_primary'] == true) {
              imageUrl = _asString(img['image_url']);
              break;
            }
          }
          // 3️⃣ Fall back to first image
          if ((imageUrl == null || imageUrl.isEmpty) &&
              imagesData.first is Map) {
            imageUrl = _asString((imagesData.first as Map)['image_url']);
          }
        }
      }

      imageUrl ??= _asString(product['primary_image_url']);
      imageUrl ??= _asString(product['image']);
      imageUrl ??= _asString(product['thumbnail']);
      imageUrl ??= _asString(product['thumbnail_url']);
    }

    // Flat fallback keys on the wishlist item itself
    imageUrl ??= _asString(json['thumbnail']);
    imageUrl ??= _asString(json['thumbnail_url']);
    imageUrl ??= _asString(json['product_image']);
    imageUrl ??= _asString(json['image']);
    imageUrl ??= _asString(json['image_url']);

    // ── Extract slug ───────────────────────────────────────────────────
    final String? parsedSlug = _asString(product?['slug']) ??
        _asString(json['product_slug']) ??
        _asString(json['slug']);

    // ── Extract prices ─────────────────────────────────────────────────
    // Prices keep their paise (parseMoney does not truncate).
    final double? parsedOriginalPrice = parseMoney(product?['original_price']) ??
        parseMoney(json['original_price']) ??
        parseMoney(product?['price']) ??
        parseMoney(json['price']);

    final double? parsedSalePrice = parseMoney(product?['sale_price']) ??
        parseMoney(json['sale_price']);

    // ── Extract stock status ───────────────────────────────────────────
    final bool parsedInStock = _parseBool(product?['in_stock']) ??
        _parseBool(json['in_stock']) ??
        true;

    return WishlistItemModel(
      id: _parseInt(json['wishlist_id']) ?? _parseInt(json['id']) ?? 0,
      productId: parsedProductId,
      productName: parsedName,
      productSlug: parsedSlug,
      productImage: imageUrl,
      originalPrice: parsedOriginalPrice,
      salePrice: parsedSalePrice,
      inStock: parsedInStock,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_slug': productSlug,
      'product_image': productImage,
      'original_price': originalPrice,
      'sale_price': salePrice,
      'in_stock': inStock,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    return value is String ? value : value.toString();
  }

  /// Handles bool, 1/0 and "true"/"false"/"1"/"0".
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase().trim();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return null;
  }

  /// Safely parse an int from dynamic (handles String, int, double, null)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }
}
