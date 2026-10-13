import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/widgets/app_error_toast.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:taksh_e_commerce/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:taksh_e_commerce/features/cart/presentation/services/variant_cache_service.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/selected_checkout_items.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product_image.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product_variant.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/delivery_check_cubit.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/delivery_check_state.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_cubit.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_state.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/similar_products_cubit.dart';
import 'package:taksh_e_commerce/features/product/presentation/widgets/similar_products_section.dart';
import 'package:taksh_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:taksh_e_commerce/features/wishlist/presentation/cubit/wishlist_state.dart';

/// Product details page for ecommerce products
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  /// Selected variant for add to cart
  ProductVariant? _selectedVariant;

  bool _isBuyNowLoading = false;

  /// Cubit for managing similar products
  late final SimilarProductsCubit _similarProductsCubit;

  /// Cubit for checking delivery availability
  late final DeliveryCheckCubit _deliveryCheckCubit;

  final TextEditingController _pincodeController = TextEditingController();

  final PageController _imagePageController = PageController();
  int _imageIndex = 0;
  bool _descriptionExpanded = false;

  static const Color _accent = Color(0xFFFF8A2B);
  static const Color _greenTint = Color(0xFFEAF7EC);

  @override
  void initState() {
    super.initState();
    _similarProductsCubit = getIt<SimilarProductsCubit>();
    _deliveryCheckCubit = getIt<DeliveryCheckCubit>();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _imagePageController.dispose();
    _similarProductsCubit.close();
    _deliveryCheckCubit.close();
    super.dispose();
  }

  static final ButtonStyle _appBarButtonStyle = IconButton.styleFrom(
    backgroundColor: Colors.white,
    elevation: 2,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimilarProductsCubit>.value(
      value: _similarProductsCubit,
      child: BlocProvider<DeliveryCheckCubit>.value(
        value: _deliveryCheckCubit,
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.productDetails,
              style: const TextStyle(
                color: AppColors.grey900,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: _appBarButtonStyle,
                color: AppColors.grey900,
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
            actions: [
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, wishlistState) {
                  // Extract current product ID from ProductCubit state
                  final productState = context.watch<ProductCubit>().state;
                  int? productId;
                  if (productState is ProductDetailsLoaded) {
                    productId = productState.product.id;
                  }

                  final isWishlisted =
                      productId != null &&
                      context.read<WishlistCubit>().isWishlisted(productId);
                  final isLoading =
                      (wishlistState is AddingToWishlist &&
                          wishlistState.productId == productId) ||
                      (wishlistState is RemovingFromWishlist &&
                          wishlistState.productId == productId);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: productId == null || isLoading
                          ? null
                          : () {
                              context.read<WishlistCubit>().toggleWishlist(
                                productId: productId!,
                              );
                            },
                      style: _appBarButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isWishlisted
                                  ? Colors.red
                                  : AppColors.grey900,
                            ),
                    ),
                  );
                },
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, _) {
                  final cartCubit = context.read<CartCubit>();
                  final count =
                      cartCubit.quickCart.totalItems +
                      cartCubit.standardCart.totalItems;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: IconButton(
                        onPressed: () => context.go(AppRoutes.cart),
                        style: _appBarButtonStyle,
                        color: AppColors.grey900,
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildFestiveFrame(
            context,
            BlocConsumer<ProductCubit, ProductState>(
            listener: (context, state) {
              // Fetch similar products when product details are loaded
              if (state is ProductDetailsLoaded) {
                _similarProductsCubit.fetchSimilarProducts(
                  categoryId: state.product.categoryId,
                  currentProductId: state.product.id,
                  limit: 10,
                );
              }
            },
            builder: (context, state) {
              if (state is ProductDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductError) {
                return _buildErrorState(context, state.message);
              }

              if (state is ProductDetailsLoaded) {
                _cacheVariantLabels(state.product);
                // Auto-select first variant if available
                if (_selectedVariant == null &&
                    state.product.variants != null &&
                    state.product.variants!.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedVariant =
                            _preferredVariant(state.product) ??
                            state.product.variants!.first;
                      });
                    }
                  });
                }
                return _buildProductContent(context, state.product);
              }

              return const SizedBox.shrink();
            },
            ),
          ),
        ),
      ),
    );
  }

  /// Soft peach gradient behind the app bar and the page content.
  Widget _buildFestiveFrame(BuildContext context, Widget content) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE9D6), Color(0xFFFFF6EE), Colors.white],
          stops: [0, 0.28, 0.55],
        ),
      ),
      padding: EdgeInsets.only(top: topInset),
      child: content,
    );
  }

  Widget _buildProductContent(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(product),
                const SizedBox(height: 14),
                _buildTopMetaRow(product),
                const SizedBox(height: 14),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedWeightLabel(product),
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildBrandSkuLine(product),
                const SizedBox(height: 14),
                _buildPriceRow(context, product),
                const SizedBox(height: 16),
                _buildDeliveryAvailabilitySection(product.id),
                if (product.variants != null &&
                    product.variants!.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildVariantsSection(product),
                ],
                const SizedBox(height: 18),
                _buildDescriptionSection(context, product),
                ..._buildSpecificationsSection(product),
                if (product.ratingSummary != null) ...[
                  const SizedBox(height: 16),
                  _buildRatingSection(context, product),
                ],
                const SizedBox(height: 22),
                SimilarProductsSection(
                  title: l10n.similarProducts,
                  cardWidth: 150,
                  cardHeight: 210,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomBar(product),
      ],
    );
  }

  /// "Brand: X | SKU: Y" line under the name.
  Widget _buildBrandSkuLine(Product product) {
    final brand = product.brand?.name.trim() ?? '';
    final sku = _selectedOrPreferredVariant(product)?.sku ?? '';
    if (brand.isEmpty && sku.isEmpty) return const SizedBox.shrink();
    const style = TextStyle(
      color: AppColors.grey600,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (brand.isNotEmpty) Text('Brand: $brand', style: style),
          if (brand.isNotEmpty && sku.isNotEmpty)
            const Text('|', style: style),
          if (sku.isNotEmpty)
            Text(AppLocalizations.of(context)!.sku(sku), style: style),
        ],
      ),
    );
  }

  /// Fixed bottom bar: price summary + Add to Cart / Buy Now.
  Widget _buildBottomBar(Product product) {
    final selectedVariant = _selectedOrPreferredVariant(product);
    final variantId = selectedVariant?.id;
    final isInStock = _effectiveInStock(product);

    // Without a purchasable variant (and in stock) there is nothing to act on.
    if (isInStock && variantId == null) return const SizedBox.shrink();

    final salePrice = _displaySalePrice(product);
    final originalPrice = _displayOriginalPrice(product);
    final hasDiscount =
        salePrice != null &&
        originalPrice != null &&
        salePrice < originalPrice;

    final priceBlock = salePrice == null
        ? const SizedBox.shrink()
        : ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 118),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${_formatPrice(salePrice)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${_formatPrice(originalPrice)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasDiscount)
                    Text(
                      'You save ₹${_formatPrice(originalPrice - salePrice)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                ],
              ),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: isInStock
              ? Row(
                  children: [
                    priceBlock,
                    const SizedBox(width: 10),
                    Expanded(
                      child: AddToCartButton(
                        productVariantId: variantId!,
                        productId: product.id,
                        size: 'large',
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildBuyNowButton(product)),
                  ],
                )
              : _buildOutOfStockActions(product),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton(Product product) {
    return ElevatedButton(
      onPressed: _isBuyNowLoading
          ? null
          : () {
              // Guest users must log in before buying.
              final authState = context.read<AuthBloc>().state;
              if (authState is! Authenticated) {
                final redirectTarget = AppRoutes.productDetails(product.id);
                context.push(
                  '${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(redirectTarget)}',
                );
                return;
              }
              _handleBuyNow(product);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _accent.withOpacity(0.6),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _isBuyNowLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Buy Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    );
  }

  Widget _buildOutOfStockActions(Product product) {
    final outOfStockMessage = _effectiveOutOfStockMessage(product);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF9A9A), width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFE53935),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  outOfStockMessage,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: const Color(0xFFBDBDBD),
                  side: const BorderSide(color: Color(0xFFBDBDBD), width: 1.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleBuyNow(Product product) async {
    if (!_effectiveInStock(product)) {
      _showOutOfStockSnackBar(
        _effectiveOutOfStockMessage(product),
      );
      return;
    }

    final variantId = _selectedOrPreferredVariant(product)?.id;
    if (variantId == null) return;

    final cartCubit = context.read<CartCubit>();
    final cart = _getCartFromState(cartCubit.state);
    final existingItem = cart?.items
        .where(
          (item) =>
              item.productVariantId == variantId &&
              CartCubit.matchesDeliveryType(
                item,
                CartCubit.deliveryTypeStandard,
              ),
        )
        .firstOrNull;

    setState(() {
      _isBuyNowLoading = true;
    });

    if (existingItem == null) {
      await cartCubit.addItemToCart(
        productVariantId: variantId,
        qty: 1,
        deliveryType: CartCubit.deliveryTypeStandard,
      );
    }

    if (!mounted) return;

    final cartState = cartCubit.state;

    setState(() {
      _isBuyNowLoading = false;
    });

    if (cartState is CartError) {
      _showCalmErrorToast(context);
      return;
    }

    if (cartState is CartLoaded ||
        cartState is CartOperationSuccess ||
        existingItem != null) {
      final updatedCart = existingItem != null
          ? cart
          : _getCartFromState(cartState);
      if (updatedCart == null || updatedCart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart is empty. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Buy now should proceed with the currently selected variant only.
      final selectedItem = updatedCart.items
          .where(
            (item) =>
                item.productVariantId == variantId &&
                CartCubit.matchesDeliveryType(
                  item,
                  CartCubit.deliveryTypeStandard,
                ),
          )
          .firstOrNull;

      final checkoutItems = selectedItem != null
          ? <CartItem>[selectedItem]
          : updatedCart.items;

      final subtotal = checkoutItems.fold<int>(
        0,
        (sum, item) => sum + item.total,
      );
      final totalQuantity = checkoutItems.fold<int>(
        0,
        (sum, item) => sum + item.qty,
      );

      context.push(
        AppRoutes.checkout,
        extra: SelectedCheckoutItems(
          items: checkoutItems,
          itemIds: checkoutItems.map((item) => item.id).toList(),
          subtotal: subtotal,
          totalQuantity: totalQuantity,
          extraCharges: updatedCart.extraCharges,
        ),
      );
    } else {
      _showCalmErrorToast(context);
    }
  }

  void _showCalmErrorToast(BuildContext context) {
    AppErrorToast.show(context);
  }

  void _showOutOfStockSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE53935),
        ),
      );
  }

  Cart? _getCartFromState(CartState state) {
    if (state is CartLoaded) return state.cart;
    if (state is CartOperationSuccess) return state.cart;
    if (state is AddingToCart) return state.currentCart;
    if (state is UpdatingCartItem) return state.currentCart;
    if (state is RemovingFromCart) return state.currentCart;
    if (state is CartLoading) return state.previousCart;
    return null;
  }

  Widget _buildImageGallery(Product product) {
    final urls = <String>[
      for (final ProductImage image in product.images ?? const <ProductImage>[])
        if (image.imageUrl != null && image.imageUrl!.isNotEmpty)
          image.imageUrl!,
    ];
    final primaryUrl = product.primaryImageUrl;
    if (urls.isEmpty && primaryUrl != null) urls.add(primaryUrl);

    if (urls.isEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
      );
    }

    final current = _imageIndex.clamp(0, urls.length - 1);
    final discountLabel = _displayDiscountLabel(product);

    Widget networkImage(String url) => CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.grey100,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.grey100,
        child: const Icon(Icons.broken_image, size: 48),
      ),
    );

    final mainImage = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _imagePageController,
              itemCount: urls.length,
              onPageChanged: (index) => setState(() => _imageIndex = index),
              itemBuilder: (context, index) => networkImage(urls[index]),
            ),
            if (discountLabel != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discountLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            if (urls.length > 1)
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${current + 1}/${urls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(child: mainImage),
          if (urls.length > 1) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final selected = index == current;
                  return GestureDetector(
                    onTap: () => _imagePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? _accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: networkImage(urls[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, Product product) {
    final salePrice = _displaySalePrice(product);
    final originalPrice = _displayOriginalPrice(product);
    final hasDiscount =
        salePrice != null &&
        originalPrice != null &&
        salePrice < originalPrice;
    final discountLabel = _displayDiscountLabel(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (salePrice != null)
              Text(
                '₹${_formatPrice(salePrice)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  height: 0.95,
                ),
              ),
            if (hasDiscount)
              Text(
                '₹${_formatPrice(originalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.grey600,
                  decoration: TextDecoration.lineThrough,
                  height: 1.3,
                ),
              ),
            if (discountLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7EEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  discountLabel,
                  style: const TextStyle(
                    color: Color(0xFF1685D1),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
          ],
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 4),
          Text(
            'You save ₹${_formatPrice(originalPrice - salePrice)}',
            style: const TextStyle(
              color: AppColors.secondaryGreen,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopMetaRow(Product product) {
    final inStock = _effectiveInStock(product);
    final rating = product.ratingSummary;
    const titleStyle = TextStyle(
      color: AppColors.grey900,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
    const subStyle = TextStyle(color: AppColors.grey500, fontSize: 13);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _greenTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFE4B800), size: 28),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('25 MINS', style: titleStyle),
              Text('Delivery Time', style: subStyle),
            ],
          ),
          if (rating != null) ...[
            const SizedBox(width: 18),
            const Icon(Icons.star_rounded, color: Color(0xFFFFB400), size: 30),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rating.averageRating} (${rating.totalReviews} reviews)',
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.ratings,
                    style: subStyle,
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          // In Stock / Out of Stock badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: inStock ? Colors.white : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: inStock
                    ? AppColors.secondaryGreen
                    : const Color(0xFFE53935),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                  color: inStock
                      ? AppColors.secondaryGreen
                      : const Color(0xFFE53935),
                ),
                const SizedBox(width: 5),
                Text(
                  inStock
                      ? AppLocalizations.of(context)!.inStock
                      : AppLocalizations.of(context)!.outOfStock,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: inStock
                        ? AppColors.secondaryGreen
                        : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAvailabilitySection(int productId) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF7EC), Color(0xFFF6FBF7)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.secondaryGreen,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.checkDeliveryAvailability,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const Text(
                    'Enter your pincode to see delivery options',
                    style: TextStyle(color: AppColors.grey600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  // Reset result when the user edits the pincode
                  if (_deliveryCheckCubit.state is! DeliveryCheckInitial) {
                    _deliveryCheckCubit.reset();
                  }
                },
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.location_on_rounded,
                    color: _accent,
                  ),
                  hintText: AppLocalizations.of(context)!.enterPincode,
                  hintStyle: const TextStyle(color: AppColors.grey500),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<DeliveryCheckCubit, DeliveryCheckState>(
              builder: (context, state) {
                final isLoading = state is DeliveryCheckLoading;
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final pincode = _pincodeController.text.trim();
                            if (pincode.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.invalidPincode,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            context.read<DeliveryCheckCubit>().check(
                              productId: productId,
                              pincode: pincode,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.secondaryGreen
                          .withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.check,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        // Result card
        BlocBuilder<DeliveryCheckCubit, DeliveryCheckState>(
          builder: (context, state) {
            if (state is DeliveryCheckInitial ||
                state is DeliveryCheckLoading) {
              return const SizedBox.shrink();
            }

            if (state is DeliveryCheckError) {
              return _buildDeliveryResultCard(
                icon: Icons.error_outline_rounded,
                iconColor: const Color(0xFFE53935),
                backgroundColor: const Color(0xFFFFEBEE),
                borderColor: const Color(0xFFEF9A9A),
                message: AppLocalizations.of(context)!.couldNotCheckDelivery,
                subMessage: null,
                isDeliverable: false,
              );
            }

            if (state is DeliveryCheckLoaded) {
              final r = state.result;
              return _buildDeliveryResultCard(
                icon: r.isDeliverable
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                iconColor: r.isDeliverable
                    ? AppColors.secondaryGreen
                    : const Color(0xFFE53935),
                backgroundColor: r.isDeliverable
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderColor: r.isDeliverable
                    ? AppColors.secondaryGreen
                    : const Color(0xFFEF9A9A),
                message: r.message,
                subMessage: r.vendor != null
                    ? AppLocalizations.of(
                        context,
                      )!.fulfilledBy(r.vendor!.shopName)
                    : null,
                isDeliverable: r.isDeliverable,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
      ),
    );
  }

  Widget _buildDeliveryResultCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String message,
    required String? subMessage,
    required bool isDeliverable,
  }) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isDeliverable
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFB71C1C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subMessage != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subMessage,
                        style: TextStyle(
                          color: isDeliverable
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFE53935),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.grey900),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Product product) {
    final text =
        product.description ??
        product.shortDescription ??
        'No product details available.';
    final isLong = text.length > 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.description_outlined,
          AppLocalizations.of(context)!.description,
          trailing: isLong
              ? GestureDetector(
                  onTap: () => setState(
                    () => _descriptionExpanded = !_descriptionExpanded,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _descriptionExpanded
                            ? 'Show less'
                            : AppLocalizations.of(context)!.readMore,
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        _descriptionExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_right_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            text,
            maxLines: _descriptionExpanded ? null : 3,
            overflow: _descriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  /// Specifications built only from data the product already carries.
  List<Widget> _buildSpecificationsSection(Product product) {
    final variant = _selectedOrPreferredVariant(product);
    final rows = <MapEntry<String, String>>[];

    void add(String label, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        rows.add(MapEntry(label, value.trim()));
      }
    }

    add('Brand', product.brand?.name);
    add('Category', product.category?.name);
    add('SKU', variant?.sku);
    add('Weight', variant?.weight);
    final dims = [variant?.length, variant?.width, variant?.height];
    if (dims.every((d) => d != null && d.trim().isNotEmpty)) {
      add('Dimensions', dims.map((d) => d!.trim()).join(' x '));
    }

    if (rows.isEmpty) return const [];

    Widget card(List<MapEntry<String, String>> items) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: i == items.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.grey200),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        items[i].key,
                        style: const TextStyle(
                          color: AppColors.grey500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        items[i].value,
                        style: const TextStyle(
                          color: AppColors.grey900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    final split = rows.length > 3;
    final half = (rows.length / 2).ceil();

    return [
      const SizedBox(height: 18),
      _buildSectionHeader(Icons.list_rounded, 'Specifications'),
      const SizedBox(height: 10),
      if (split)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: card(rows.sublist(0, half))),
            const SizedBox(width: 10),
            Expanded(child: card(rows.sublist(half))),
          ],
        )
      else
        card(rows),
    ];
  }

  Widget _buildVariantsSection(Product product) {
    final variants = product.variants ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.inventory_2_outlined,
          AppLocalizations.of(context)!.selectVariant,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: variants.map((variant) {
            final attributes =
                variant.variantAttributes
                    ?.map((attr) => attr.attributeValue?.value)
                    .whereType<String>()
                    .toList() ??
                [];
            final label = attributes.isNotEmpty
                ? attributes.join(' • ')
                : variant.sku;
            final isSelected = _selectedVariant?.id == variant.id;
            final isInStock = variant.isAvailableForSale;
            final canSelectVariant =
                !variant.hasStockInfo || variant.isAvailableForSale;

            final Color background;
            final Color border;
            final Color textColor;
            if (!isInStock) {
              background = isSelected
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFFFF5F5);
              border = isSelected
                  ? const Color(0xFFE53935)
                  : const Color(0xFFEF9A9A);
              textColor = const Color(0xFFB71C1C);
            } else if (isSelected) {
              background = _accent;
              border = _accent;
              textColor = Colors.white;
            } else {
              background = Colors.white;
              border = AppColors.grey300;
              textColor = AppColors.grey900;
            }

            return GestureDetector(
              onTap: canSelectVariant
                  ? () {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border, width: 1.4),
                  boxShadow: isSelected && isInStock
                      ? [
                          BoxShadow(
                            color: _accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (!isInStock)
                      Text(
                        AppLocalizations.of(context)!.outOfStock,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  ProductVariant? _selectedOrPreferredVariant(Product product) {
    final variants = product.variants;
    if (variants == null || variants.isEmpty) return null;

    if (_selectedVariant != null) {
      for (final variant in variants) {
        if (variant.id == _selectedVariant!.id) {
          return variant;
        }
      }
    }

    return _preferredVariant(product);
  }

  ProductVariant? _preferredVariant(Product product) {
    final variants = product.variants;
    if (variants == null || variants.isEmpty) return null;

    for (final variant in variants) {
      if (variant.hasStockInfo && variant.isAvailableForSale) {
        return variant;
      }
    }

    if (product.inStock) {
      for (final variant in variants) {
        if (variant.isActive) {
          return variant;
        }
      }
    }

    return variants.first;
  }

  /// Cache each variant's human-readable label so cart/checkout/orders can
  /// display the selected variant without refetching product details.
  void _cacheVariantLabels(Product product) {
    for (final variant in product.variants ?? <ProductVariant>[]) {
      VariantCacheService.instance.cacheVariantLabel(
        variant.id,
        variant.variantLabel,
      );
    }
  }

  bool _effectiveInStock(Product product) {
    final selectedVariant = _selectedOrPreferredVariant(product);
    if (selectedVariant != null && selectedVariant.hasStockInfo) {
      return selectedVariant.isAvailableForSale;
    }

    return product.inStock;
  }

  String _effectiveOutOfStockMessage(Product product) {
    final selectedVariant = _selectedOrPreferredVariant(product);
    return (selectedVariant?.hasStockInfo == true
            ? selectedVariant?.outOfStockMessage
            : null) ??
        product.outOfStockMessage ??
        'This product is currently out of stock.';
  }

  num? _parsePriceValue(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  num? _displaySalePrice(Product product) {
    final selectedVariant = _selectedOrPreferredVariant(product);
    final variantSalePrice = _parsePriceValue(selectedVariant?.salePrice);
    if (variantSalePrice != null && variantSalePrice > 0) {
      return variantSalePrice;
    }

    final variantPrice = _parsePriceValue(selectedVariant?.price);
    if (variantPrice != null && variantPrice > 0) {
      return variantPrice;
    }

    return product.salePrice;
  }

  Widget _buildRatingSection(BuildContext context, Product product) {
    final rating = product.ratingSummary!;
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.ratings,
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '${rating.averageRating} (${rating.totalReviews} reviews)',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  num? _displayOriginalPrice(Product product) {
    final selectedVariant = _selectedOrPreferredVariant(product);
    final variantPrice = _parsePriceValue(selectedVariant?.price);
    if (variantPrice != null && variantPrice > 0) {
      return variantPrice;
    }

    return product.originalPrice;
  }

  String? _displayDiscountLabel(Product product) {
    final salePrice = _displaySalePrice(product);
    final originalPrice = _displayOriginalPrice(product);
    if (salePrice == null || originalPrice == null || salePrice >= originalPrice) {
      return null;
    }

    final discountPercentage =
        ((originalPrice - salePrice) / originalPrice * 100).round();
    if (discountPercentage <= 0) {
      return product.discountLabel;
    }

    return '$discountPercentage% OFF';
  }

  String _formatPrice(num value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _selectedWeightLabel(Product product) {
    final selectedWeight = _selectedVariant?.weight;
    if (selectedWeight != null && selectedWeight.trim().isNotEmpty) {
      return selectedWeight;
    }

    for (final variant in product.variants ?? <ProductVariant>[]) {
      if (variant.weight != null && variant.weight!.trim().isNotEmpty) {
        return variant.weight!;
      }
    }

    return '1 unit';
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToLoadProduct,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductCubit>().fetchEcommerceProductDetails(1);
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
