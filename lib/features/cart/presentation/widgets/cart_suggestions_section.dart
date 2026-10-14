import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_products.dart';

/// Horizontal "You may also like" strip shown on the cart page.
///
/// Products are fetched once. Items already in the cart when the strip loads
/// are skipped; quick delivery only suggests express-30 products.
class CartSuggestionsSection extends StatefulWidget {
  final bool isQuickDelivery;
  final Set<int> excludeProductIds;

  const CartSuggestionsSection({
    super.key,
    required this.isQuickDelivery,
    this.excludeProductIds = const {},
  });

  @override
  State<CartSuggestionsSection> createState() => _CartSuggestionsSectionState();
}

class _CartSuggestionsSectionState extends State<CartSuggestionsSection> {
  final _log = loggerWithContext({
    'feature': 'cart',
    'widget': 'CartSuggestionsSection',
  });

  List<Product> _products = const [];
  late final Set<int> _initialExcluded = {...widget.excludeProductIds};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await getIt<GetProducts>()(
        const GetProductsParams(page: 1, limit: 20),
      );
      if (!mounted) return;
      result.fold(
        (failure) => _log.warnWithContext('Failed to load suggestions', {
          'message': failure.message,
        }),
        (paginated) => setState(() => _products = paginated.products),
      );
    } catch (e) {
      _log.warnWithContext('Failed to load suggestions', {
        'error': e.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _products.where((p) {
      if (_initialExcluded.contains(p.id)) return false;
      if (widget.isQuickDelivery && !p.isExpress30) return false;
      final variants = p.variants;
      return p.inStock && variants != null && variants.isNotEmpty;
    }).toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'You may also like',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.categories),
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 206,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _SuggestionCard(
              product: visible[index],
              isQuickDelivery: widget.isQuickDelivery,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Product product;
  final bool isQuickDelivery;

  const _SuggestionCard({required this.product, required this.isQuickDelivery});

  @override
  Widget build(BuildContext context) {
    final variant = product.variants!.firstWhere(
      (v) => !v.hasStockInfo || v.isAvailableForSale,
      orElse: () => product.variants!.first,
    );
    final imageUrl = product.primaryImageUrl;
    final price = product.salePrice ?? product.originalPrice;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productDetails(product.id),
        extra: ProductDetailsExtra(
          inStock: product.inStock,
          outOfStockMessage: product.outOfStockMessage,
        ),
      ),
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE6CC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Container(
                          color: AppColors.grey100,
                          child: const Icon(Icons.image_not_supported),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.grey100,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    price == null ? '' : '₹$price',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                AddToCartButton(
                  productVariantId: variant.id,
                  productId: product.id,
                  size: 'icon',
                  isQuickDelivery: isQuickDelivery,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
