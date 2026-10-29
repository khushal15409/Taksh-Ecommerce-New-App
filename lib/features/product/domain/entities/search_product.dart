import 'package:equatable/equatable.dart';

/// Lightweight product entity for search results
class SearchProduct extends Equatable {
  final int id;
  final String name;
  final String? brand;
  final double price;
  final double? mrp;
  final String? imageUrl;
  final bool inStock;

  /// Server flag: the product is sold in the Quick (30_min) bucket.
  final bool isExpress30;

  /// Average of the approved ratings (0 when nobody has rated it yet).
  final double averageRating;
  final int totalReviews;

  const SearchProduct({
    required this.id,
    required this.name,
    this.brand,
    required this.price,
    this.mrp,
    this.imageUrl,
    required this.inStock,
    this.isExpress30 = false,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  bool get hasDiscount => mrp != null && mrp! > price;

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        price,
        mrp,
        imageUrl,
        inStock,
        isExpress30,
        averageRating,
        totalReviews,
      ];
}
