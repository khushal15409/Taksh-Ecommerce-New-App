import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/cart/presentation/widgets/product_add_to_cart_button.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/product_variant_info.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/wishlist_heart_button.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product.dart';

/// Product card used in the categories / express product grids.
///
/// Visually mirrors the dashboard `ProductCard` (white card, contained image
/// with discount badge, wishlist heart and round add button overlay, name,
/// rating and price) so listings look identical across the app.
class CategoryProductCard extends StatefulWidget {
  final Product product;
  final bool showDeliveryTime;

  const CategoryProductCard({
    super.key,
    required this.product,
    this.showDeliveryTime = true,
  });

  @override
  State<CategoryProductCard> createState() => _CategoryProductCardState();
}

class _CategoryProductCardState extends State<CategoryProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Get the first variant ID for cart functionality
  int? get _firstVariantId {
    if (product.variants == null || product.variants!.isEmpty) return null;
    return product.variants!.first.id;
  }

  int? get _discountPercentage {
    if (!product.hasDiscount) return null;
    final discount =
        ((product.originalPrice! - product.salePrice!) /
                product.originalPrice! *
                100)
            .round();
    return discount > 0 ? discount : null;
  }

  void _openDetails() {
    context.push(
      AppRoutes.productDetails(product.id),
      extra: ProductDetailsExtra(
        inStock: product.inStock,
        outOfStockMessage: product.outOfStockMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.primaryImageUrl;
    final displayPrice = product.salePrice ?? product.originalPrice;
    final discount = _discountPercentage;
    final hasRating = (product.ratingSummary?.averageRating ?? 0) > 0;

    return GestureDetector(
      onTap: _openDetails,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVisualCard(imageUrl, discount),
              const SizedBox(height: 7),
              if (widget.showDeliveryTime) ...[
                _buildDeliveryChip(),
                const SizedBox(height: 4),
              ],
              _buildName(),
              if (hasRating) ...[
                const SizedBox(height: 3),
                _buildRatingRow(),
              ],
              const SizedBox(height: 3),
              _buildPriceRow(displayPrice, discount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualCard(String? imageUrl, int? discount) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 30,
                                color: AppColors.grey400,
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 30,
                              color: AppColors.grey400,
                            ),
                    ),
                    if (!product.inStock)
                      Container(
                        color: Colors.white.withOpacity(0.72),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.62),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Out of\nStock',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              height: 1.2,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (discount != null)
            Positioned(top: 6, left: 6, child: _buildDiscountBadge(discount)),
          Positioned(
            top: 2,
            right: 2,
            child: WishlistHeartButton(productId: product.id, size: 16),
          ),
          Positioned(right: 0, bottom: 0, child: _buildAddButton(imageUrl)),
        ],
      ),
    );
  }

  Widget _buildAddButton(String? imageUrl) {
    return ProductAddToCartButton(
      productId: product.id,
      productVariantId: _firstVariantId,
      style: ProductAddToCartButtonStyle.outlinedGreen,
      inStock: product.inStock,
      isQuickDelivery: widget.showDeliveryTime,
      variants: ProductVariantInfo.fromProductVariants(product.variants),
      productName: product.name,
      productImageUrl: imageUrl,
      compactCircle: true,
    );
  }

  Widget _buildDiscountBadge(int discount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE5242B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$discount% OFF',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildDeliveryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        // No guaranteed delivery time exists: never promise "30 minutes".
        AppLocalizations.of(context)!.quickDelivery,
        style: const TextStyle(
          color: Color(0xFF0B6B38),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      product.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.2,
      ),
    );
  }

  Widget _buildRatingRow() {
    final summary = product.ratingSummary!;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF7B500)),
          const SizedBox(width: 2),
          Text(
            summary.averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          if (summary.totalReviews > 0)
            Text(
              ' (${summary.totalReviews})',
              style: const TextStyle(fontSize: 11, color: AppColors.grey500),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(double? displayPrice, int? discount) {
    if (displayPrice == null) {
      return const Text(
        'View details',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.grey900,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '₹${_formatPrice(displayPrice)}',
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (discount != null && product.originalPrice != null) ...[
            const SizedBox(width: 5),
            Text(
              '₹${_formatPrice(product.originalPrice!)}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey500,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(num value) {
    final roundedValue = value.truncateToDouble();
    if (value.toDouble() == roundedValue) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}
