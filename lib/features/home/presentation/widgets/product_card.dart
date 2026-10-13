import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/cart/presentation/widgets/product_add_to_cart_button.dart';
import 'package:taksh_e_commerce/features/home/data/models/product_model.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/wishlist_heart_button.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_ecommerce_product_details.dart';

/// Enum to define different product card layouts
enum ProductCardVariant {
  /// Standard layout for 3-column grids (more spacious)
  standard,

  /// Compact layout for 4+ column grids (more condensed)
  compact,
}

/// Product card widget for displaying product in lists/grids
/// Clean Blinkit/Zepto inspired design
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showDeliveryTime;

  /// Layout variant - use [ProductCardVariant.compact] for 4+ column grids
  final ProductCardVariant variant;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.variant = ProductCardVariant.standard,
    this.showDeliveryTime = true,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  static final Map<int, String?> _resolvedImageCache = <int, String?>{};
  static final Map<int, Future<String?>> _pendingImageRequests =
      <int, Future<String?>>{};

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  String? _resolvedImageUrl;
  bool _isResolvingImage = false;

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
    _initializeImageResolution();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.product.id != widget.product.id ||
        oldWidget.product.imageUrl != widget.product.imageUrl) {
      _initializeImageResolution();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _scaleController.forward();
  void _onTapUp(TapUpDetails details) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  String? _normalizeImageUrl(String? imageUrl) {
    final normalized = imageUrl?.trim();
    if (normalized == null ||
        normalized.isEmpty ||
        normalized.toLowerCase() == 'null') {
      return null;
    }

    return normalized;
  }

  void _initializeImageResolution() {
    final directImageUrl = _normalizeImageUrl(widget.product.imageUrl);
    if (directImageUrl != null) {
      _resolvedImageCache[widget.product.id] = directImageUrl;
      _resolvedImageUrl = directImageUrl;
      _isResolvingImage = false;
      return;
    }

    if (_resolvedImageCache.containsKey(widget.product.id)) {
      _resolvedImageUrl = _resolvedImageCache[widget.product.id];
      _isResolvingImage = false;
      return;
    }

    _resolvedImageUrl = null;
    _isResolvingImage = true;
    _resolveMissingImageUrl(widget.product.id);
  }

  Future<void> _resolveMissingImageUrl(int productId) async {
    final imageFuture = _pendingImageRequests.putIfAbsent(productId, () async {
      final result = await getIt<GetEcommerceProductDetails>()(
        GetEcommerceProductDetailsParams(productId: productId),
      );

      return result.fold(
        (_) => null,
        (product) => _normalizeImageUrl(product.primaryImageUrl),
      );
    });

    final imageUrl = await imageFuture;
    _pendingImageRequests.remove(productId);
    _resolvedImageCache[productId] = imageUrl;

    if (!mounted || widget.product.id != productId) {
      return;
    }

    setState(() {
      _resolvedImageUrl = imageUrl;
      _isResolvingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isCompact = widget.variant == ProductCardVariant.compact;
    final discount = _discountPercentage(product);
    final hasRating = (product.averageRating ?? 0) > 0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 6 : 7),
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
              _buildVisualCard(product, isCompact, discount),
              SizedBox(height: isCompact ? 6 : 7),
              if (widget.showDeliveryTime) ...[
                _buildDeliveryChip(isCompact),
                const SizedBox(height: 4),
              ],
              _buildName(product, isCompact),
              if (hasRating) ...[
                const SizedBox(height: 3),
                _buildRatingRow(product, isCompact),
              ],
              const SizedBox(height: 3),
              _buildPriceRow(product, isCompact, discount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualCard(ProductModel product, bool isCompact, int? discount) {
    final imageUrl = _resolvedImageUrl;

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
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_outlined,
                                size: isCompact ? 26 : 30,
                                color: AppColors.grey400,
                              ),
                            )
                          : _isResolvingImage
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: isCompact ? 26 : 30,
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
                          child: Text(
                            'Out of\nStock',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: isCompact ? 11 : 12,
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
          // Badge only when the backend price data yields a real discount.
          if (discount != null)
            Positioned(top: 6, left: 6, child: _buildDiscountBadge(discount)),
          Positioned(
            top: 2,
            right: 2,
            child: WishlistHeartButton(productId: product.id, size: 16),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ProductAddToCartButton(
              productId: product.id,
              productVariantId: product.productVariantId,
              style: ProductAddToCartButtonStyle.outlinedGreen,
              inStock: product.inStock,
              isQuickDelivery: widget.showDeliveryTime,
              variants: product.variants,
              productName: product.name,
              productImageUrl: imageUrl,
              compactCircle: true,
            ),
          ),
        ],
      ),
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

  Widget _buildDeliveryChip(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 1.5 : 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '30 minutes',
        style: TextStyle(
          color: const Color(0xFF0B6B38),
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildName(ProductModel product, bool isCompact) {
    return Text(
      product.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: isCompact ? 11 : 11.5,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
        height: 1.2,
      ),
    );
  }

  /// Rating row — only rendered when the API supplied a rating.
  Widget _buildRatingRow(ProductModel product, bool isCompact) {
    final reviews = product.totalReviews;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF7B500)),
          const SizedBox(width: 2),
          Text(
            product.averageRating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          if (reviews != null && reviews > 0)
            Text(
              ' ($reviews)',
              style: const TextStyle(fontSize: 11, color: AppColors.grey500),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ProductModel product, bool isCompact, int? discount) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '₹${_formatPrice(product.salePrice)}',
            style: TextStyle(
              color: AppColors.grey900,
              fontSize: isCompact ? 13 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (discount != null) ...[
            const SizedBox(width: 5),
            Text(
              '₹${_formatPrice(product.originalPrice)}',
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

  String _formatPrice(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  int? _discountPercentage(ProductModel product) {
    if (product.originalPrice <= 0 ||
        product.salePrice >= product.originalPrice) {
      return null;
    }
    final value =
        ((product.originalPrice - product.salePrice) /
                product.originalPrice *
                100)
            .round();
    return value > 0 ? value : null;
  }
}
