import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/search_product.dart';

/// Model for search product item
class SearchProductModel extends SearchProduct {
  const SearchProductModel({
    required super.id,
    required super.name,
    super.brand,
    required super.price,
    super.mrp,
    super.imageUrl,
    required super.inStock,
    super.isExpress30,
  });

  factory SearchProductModel.fromJson(DataMap json) {
    return SearchProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      mrp: (json['mrp'] as num?)?.toDouble(),
      imageUrl: json['image'] as String?,
      inStock: json['in_stock'] as bool? ?? false,
      isExpress30: _asFlag(json['is_express_30']),
    );
  }
}

bool _asFlag(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    return v == '1' || v == 'true';
  }
  return false;
}
