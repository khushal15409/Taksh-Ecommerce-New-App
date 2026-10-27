import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_event.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_state.dart';
import 'package:taksh_e_commerce/features/address/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:taksh_e_commerce/features/quick_delivery/presentation/cubit/quick_product_availability_cubit.dart';
import 'package:taksh_e_commerce/features/splash/presentation/cubit/splash_cubit.dart';
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

  /// Quick only: the server's verdict for the selected address. Add to Cart and
  /// Buy Now stay disabled until it says `available` for the current variant.
  late final QuickProductAvailabilityCubit _availabilityCubit;

  /// Last key handed to the cubit, so a rebuild can never re-request in a loop.
  String? _lastAvailabilityKey;

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
    _availabilityCubit = getIt<QuickProductAvailabilityCubit>();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _imagePageController.dispose();
    _similarProductsCubit.close();
    _deliveryCheckCubit.close();
    _availabilityCubit.close();
    super.dispose();
  }

  static final ButtonStyle _appBarButtonStyle = IconButton.styleFrom(
    backgroundColor: Colors.white,
    elevation: 2,
    shadowColor: Colors.black26,
    padding: EdgeInsets.zero,
    iconSize: 18,
    minimumSize: const Size(32, 30),
    fixedSize: const Size(32, 30),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimilarProductsCubit>.value(
      value: _similarProductsCubit,
      child: BlocProvider<DeliveryCheckCubit>.value(
        value: _deliveryCheckCubit,
        child: BlocProvider<QuickProductAvailabilityCubit>.value(
          value: _availabilityCubit,
          child: BlocListener<AddressBloc, AddressState>(
          // A different selected address means a different verdict.
          listenWhen: (previous, current) =>
              _selectedAddressOf(previous)?.id !=
              _selectedAddressOf(current)?.id,
          listener: (context, _) {
            // The pincode box is never filled in for the customer: the
            // verdict shown is always for a pincode they typed and checked.
            final productState = context.read<ProductCubit>().state;
            if (productState is ProductDetailsLoaded) {
              _syncAvailability(productState.product);
            }
          },
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: _appBarButtonStyle,
                color: AppColors.grey900,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
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
                          size: 18,
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _syncAvailability(state.product);
                });
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
                // Rebuilt when the availability verdict changes, so stock badge and
                // the Add to Cart / Buy Now buttons always follow the latest verdict.
                return BlocBuilder<QuickProductAvailabilityCubit,
                    QuickProductAvailabilityState>(
                  builder: (context, _) =>
                      _buildProductContent(context, state.product),
                );
              }

              return const SizedBox.shrink();
            },
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }

  /// Selected delivery address of an AddressBloc state (null while unknown).
  Address? _selectedAddressOf(AddressState state) {
    if (state is AddressesLoaded) return state.selectedAddress;
    if (state is AddressOperationSuccess) return state.selectedAddress;
    if (state is AddressOperationError) return state.selectedAddress;
    return null;
  }

  /// Location the Quick verdict is asked for: the same precedence the Quick
  /// dashboard uses (selected address, saved address, device). Null while the
  /// addresses are still loading.
  ({QuickLocation? location, bool ready}) _quickLocation() {
    final state = context.read<AddressBloc>().state;
    List<Address>? saved;
    Address? selected;
    if (state is AddressesLoaded) {
      saved = state.addresses;
      selected = state.selectedAddress;
    } else if (state is AddressOperationSuccess) {
      saved = state.addresses;
      selected = state.selectedAddress;
    } else if (state is AddressOperationError) {
      saved = state.addresses;
      selected = state.selectedAddress;
    } else if (state is AddressError) {
      saved = const <Address>[];
    }
    if (saved == null) return (location: null, ready: false);

    final splash = context.read<SplashCubit>();
    final device = splash.currentLocation;
    return (
      location: resolveQuickLocation(
        selected: selected,
        saved: saved,
        deviceLatitude: device?.latitude,
        deviceLongitude: device?.longitude,
        deviceAllowed: splash.hasLocationPermission,
      ),
      ready: true,
    );
  }

  /// Asks the server for this product's availability at the selected address.
  /// Standard products are never gated. Repeats for an unchanged
  /// product / variant / address are ignored here and in the cubit.
  void _syncAvailability(Product product, {bool force = false}) {
    if (!mounted) return;
    if (!product.isExpress30) {
      _lastAvailabilityKey = null;
      _availabilityCubit.reset();
      return;
    }
    final resolved = _quickLocation();
    if (!resolved.ready) return; // addresses still loading: stays not orderable

    final variantId = _selectedOrPreferredVariant(product)?.id;
    final key = QuickProductAvailabilityCubit.keyFor(
      product.id,
      variantId,
      resolved.location,
    );
    if (!force && key == _lastAvailabilityKey) return;
    _lastAvailabilityKey = key;
    _availabilityCubit.check(
      productId: product.id,
      variantId: variantId,
      location: resolved.location,
      force: force,
    );
  }

  /// A Quick product can be ordered only after the server said `available`
  /// for the current variant and address; any other state keeps it disabled.
  bool _quickOrderable(Product product) =>
      !product.isExpress30 || _availabilityCubit.state.canOrder;

  Future<void> _changeAddress(Product product) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      context.push(
        '${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.productDetails(product.id))}',
      );
      return;
    }
    final addressBloc = context.read<AddressBloc>();
    final picked = await AddressSelectionBottomSheet.show(
      context,
      currentAddress: _selectedAddressOf(addressBloc.state),
    );
    if (picked != null && mounted) {
      // The AddressBloc listener above re-checks availability for the new address.
      addressBloc.add(SelectAddressForDeliveryEvent(picked));
    }
  }

  /// Availability panel of a Quick product at the selected address.
  Widget _buildQuickAvailabilityPanel(Product product) {
    if (!product.isExpress30) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<QuickProductAvailabilityCubit,
        QuickProductAvailabilityState>(
      builder: (context, state) {
        late final Color tone;
        late final Color background;
        late final IconData icon;
        late final String text;
        var showChangeAddress = false;
        var showRetry = false;
        var loading = false;

        if (state.phase == QuickAvailabilityPhase.failed) {
          tone = const Color(0xFFB45309);
          background = const Color(0xFFFFF4E5);
          icon = Icons.error_outline_rounded;
          text = l10n.quickAvailabilityFailed;
          showRetry = true;
        } else if (state.phase == QuickAvailabilityPhase.checked &&
            state.availability != null) {
          final availability = state.availability!;
          if (availability.canOrder) {
            tone = AppColors.secondaryGreen;
            background = _greenTint;
            icon = Icons.check_circle_rounded;
            text = l10n.quickAvailabilityAvailable;
          } else {
            tone = const Color(0xFFB71C1C);
            background = const Color(0xFFFFEBEE);
            icon = availability.status.isLocationLevel
                ? Icons.location_off_outlined
                : Icons.remove_shopping_cart_outlined;
            text = _unavailableText(availability, l10n);
            showChangeAddress = availability.status.isLocationLevel;
          }
        } else {
          // idle / checking: not orderable yet
          tone = AppColors.grey600;
          background = const Color(0xFFF5F5F5);
          icon = Icons.hourglass_empty_rounded;
          text = l10n.quickAvailabilityChecking;
          loading = true;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tone.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tone,
                          ),
                        )
                      : Icon(icon, size: 18, color: tone),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.quickAvailabilityTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tone,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showChangeAddress || showRetry)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: showRetry
                        ? () => _syncAvailability(product, force: true)
                        : () => _changeAddress(product),
                    icon: Icon(
                      showRetry
                          ? Icons.refresh_rounded
                          : Icons.edit_location_alt_outlined,
                      size: 16,
                    ),
                    label: Text(
                      showRetry ? l10n.retry : l10n.changeAddress,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Customer text of an unavailable verdict. The server message is in the
  /// customer's language; the ARB text is the fallback.
  String _unavailableText(
    QuickProductAvailability availability,
    AppLocalizations l10n,
  ) {
    final fromServer = availability.message;
    if (fromServer != null) return fromServer;
    switch (availability.status) {
      case QuickAvailabilityStatus.areaUnserviceable:
        return l10n.quickAvailabilityNotInArea;
      case QuickAvailabilityStatus.outOfStock:
        return l10n.quickAvailabilityOutOfStock;
      case QuickAvailabilityStatus.locationRequired:
        return l10n.quickAvailabilityLocationRequired;
      default:
        return l10n.quickAvailabilityUnavailable;
    }
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
                const SizedBox(height: 7),
                _buildTopMetaRow(product),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.hasFoodType) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 3, right: 8),
                        child: _FoodTypeMark(isVeg: product.foodType == 'veg'),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey900,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedWeightLabel(product),
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildBrandSkuLine(product),
                const SizedBox(height: 10),
                _buildPriceRow(context, product),
                _buildReturnWindow(product),
                const SizedBox(height: 14),
                if (product.isExpress30) ...[
                  _buildQuickAvailabilityPanel(product),
                  const SizedBox(height: 10),
                ],
                _buildDeliveryAvailabilitySection(
                  product.id,
                  variantId: _selectedOrPreferredVariant(product)?.id,
                  isQuick: product.isExpress30,
                ),
                if (product.variants != null &&
                    product.variants!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildVariantsSection(product),
                ],
                const SizedBox(height: 14),
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

  /// "7 days return" / "No returns" under the price (hidden when the server
  /// did not send the window).
  Widget _buildReturnWindow(Product product) {
    final days = product.returnDays;
    if (days == null) return const SizedBox.shrink();
    final returnable = days > 0;
    final color = returnable ? AppColors.secondaryGreen : AppColors.grey600;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: returnable ? _greenTint : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              returnable
                  ? Icons.assignment_return_outlined
                  : Icons.block_rounded,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              returnable
                  ? (days == 1 ? '1 day return' : '$days days return')
                  : 'No returns',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Brand: X | SKU: Y" line under the name.
  Widget _buildBrandSkuLine(Product product) {
    final brand = product.brand?.name.trim() ?? '';
    final sku = _selectedOrPreferredVariant(product)?.sku ?? '';
    if (brand.isEmpty && sku.isEmpty) return const SizedBox.shrink();
    const style = TextStyle(
      color: AppColors.grey600,
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 3),
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
    // Quick: in stock somewhere is not enough, this address must be able to order it.
    final quickBlocked = isInStock && !_quickOrderable(product);

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
            constraints: const BoxConstraints(maxWidth: 100),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${_formatPrice(originalPrice)}',
                          style: const TextStyle(
                            fontSize: 11,
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
                        fontSize: 11,
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
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
          child: isInStock && !quickBlocked
              ? Row(
                  children: [
                    priceBlock,
                    const SizedBox(width: 10),
                    Expanded(
                      // Once this variant is in the cart, offer "View Cart"
                      // instead of "Add to Cart".
                      child: BlocBuilder<CartCubit, CartState>(
                        builder: (context, _) {
                          final cartCubit = context.read<CartCubit>();
                          final inCart =
                              (product.isExpress30
                                      ? cartCubit.quickCart
                                      : cartCubit.standardCart)
                              .items
                              .any(
                                (item) =>
                                    item.productVariantId == variantId &&
                                    CartCubit.matchesDeliveryType(
                                      item,
                                      _deliveryTypeFor(product),
                                    ),
                              );
                          if (inCart) return _buildViewCartButton();
                          return AddToCartButton(
                            productVariantId: variantId!,
                            productId: product.id,
                            size: 'large',
                            outlined: true,
                            isQuickDelivery: product.isExpress30,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildBuyNowButton(product)),
                  ],
                )
              : _buildOutOfStockActions(
                  product,
                  messageOverride: quickBlocked ? _quickBlockedMessage() : null,
                ),
        ),
      ),
    );
  }

  Widget _buildViewCartButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.go(AppRoutes.cart),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accent,
          side: const BorderSide(color: _accent, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 9),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_checkout_rounded, size: 14),
              SizedBox(width: 6),
              Text(
                'View Cart',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 9),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
    );
  }

  /// Why a Quick product in stock somewhere still cannot be ordered here.
  String _quickBlockedMessage() {
    final l10n = AppLocalizations.of(context)!;
    final state = _availabilityCubit.state;
    if (state.phase == QuickAvailabilityPhase.failed) {
      return l10n.quickAvailabilityFailed;
    }
    final availability = state.availability;
    if (state.phase == QuickAvailabilityPhase.checked && availability != null) {
      return _unavailableText(availability, l10n);
    }
    return l10n.quickAvailabilityChecking;
  }

  Widget _buildOutOfStockActions(Product product, {String? messageOverride}) {
    final outOfStockMessage =
        messageOverride ?? _effectiveOutOfStockMessage(product);
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
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleBuyNow(Product product) async {
    // Never rely on the button being disabled: no verdict, no purchase.
    if (!_quickOrderable(product)) {
      _showOutOfStockSnackBar(_quickBlockedMessage());
      return;
    }
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
                _deliveryTypeFor(product),
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
        deliveryType: _deliveryTypeFor(product),
      );
    }

    if (!mounted) return;

    final cartState = cartCubit.state;

    setState(() {
      _isBuyNowLoading = false;
    });

    if (cartState is CartError) {
      // The server refused the line (stock or area changed since the check): ask
      // again, so the page shows the current verdict instead of a stale "available".
      if (product.isExpress30) _syncAvailability(product, force: true);
      // Server rules (delivery bucket / vendor conflicts) come with their own
      // message: show it as is, never convert the product silently.
      if (cartState.message.trim().isNotEmpty) {
        _showOutOfStockSnackBar(cartState.message);
      } else {
        _showCalmErrorToast(context);
      }
      return;
    }

    if (cartState is CartLoaded ||
        cartState is CartOperationSuccess ||
        existingItem != null) {
      final updatedCart = existingItem != null
          ? cart
          : _getCartFromState(cartState);
      if (updatedCart == null || updatedCart.items.isEmpty) {
        AppToastMessenger.of(context).showSnackBar(
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
                  _deliveryTypeFor(product),
                ),
          )
          .firstOrNull;

      final checkoutItems = selectedItem != null
          ? <CartItem>[selectedItem]
          : updatedCart.items;

      final subtotal = checkoutItems.fold<double>(
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
          deliveryType: _deliveryTypeFor(product),
        ),
      );
    } else {
      _showCalmErrorToast(context);
    }
  }

  /// Delivery bucket of the product: Quick ('30_min') for express products,
  /// Standard otherwise.
  String _deliveryTypeFor(Product product) => product.isExpress30
      ? CartCubit.deliveryTypeExpress
      : CartCubit.deliveryTypeStandard;

  void _showCalmErrorToast(BuildContext context) {
    AppErrorToast.show(context);
  }

  void _showOutOfStockSnackBar(String message) {
    AppToastMessenger.of(context)
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
        height: 177,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(11),
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
        borderRadius: BorderRadius.circular(11),
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
        borderRadius: BorderRadius.circular(10),
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
                top: 7,
                left: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    discountLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            if (urls.length > 1)
              Positioned(
                right: 7,
                bottom: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${current + 1}/${urls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return SizedBox(
      height: 177,
      child: Row(
        children: [
          Expanded(child: mainImage),
          if (urls.length > 1) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 63,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
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
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selected ? _accent : Colors.transparent,
                          width: 1.3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
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
          spacing: 9,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (salePrice != null)
              Text(
                '₹${_formatPrice(salePrice)}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  height: 0.95,
                ),
              ),
            if (hasDiscount)
              Text(
                '₹${_formatPrice(originalPrice)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey600,
                  decoration: TextDecoration.lineThrough,
                  height: 1.3,
                ),
              ),
            if (discountLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7EEFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  discountLabel,
                  style: const TextStyle(
                    color: Color(0xFF1685D1),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
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
              fontSize: 12,
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
      fontSize: 10.5,
    );
    const subStyle = TextStyle(color: AppColors.grey500, fontSize: 9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _greenTint,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          // Only Quick products are delivered in minutes; Standard ones say so.
          Icon(
            product.isExpress30
                ? Icons.timer_outlined
                : Icons.local_shipping_outlined,
            color: const Color(0xFFE4B800),
            size: 14,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.isExpress30 ? '30 MINS' : 'STANDARD',
                style: titleStyle,
              ),
              const Text('Delivery Time', style: subStyle),
            ],
          ),
          if (rating != null) ...[
            const SizedBox(width: 18),
            const Icon(Icons.star_rounded, color: Color(0xFFFFB400), size: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: inStock ? Colors.white : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: inStock
                    ? AppColors.secondaryGreen
                    : const Color(0xFFE53935),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 12,
                  color: inStock
                      ? AppColors.secondaryGreen
                      : const Color(0xFFE53935),
                ),
                const SizedBox(width: 4),
                Text(
                  inStock
                      ? AppLocalizations.of(context)!.inStock
                      : AppLocalizations.of(context)!.outOfStock,
                  style: TextStyle(
                    fontSize: 11.5,
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

  Widget _buildDeliveryAvailabilitySection(
    int productId, {
    int? variantId,
    bool isQuick = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 8, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF7EC), Color(0xFFF6FBF7)],
        ),
        borderRadius: BorderRadius.circular(10),
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
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.checkDeliveryAvailability,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const Text(
                    'Enter your pincode to see delivery options',
                    style: TextStyle(color: AppColors.grey600, fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(
              isQuick
                  ? Icons.delivery_dining_rounded
                  : Icons.local_shipping_outlined,
              size: 26,
              color: const Color(0xFFFF8A1F),
            ),
            if (isQuick) ...[
            const SizedBox(width: 4),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.secondaryGreen, width: 1.5),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '30',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                  Text(
                    'min',
                    style: TextStyle(
                      fontSize: 7,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ],
        ),
        const SizedBox(height: 6),
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
                  hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 11.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                ),
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<DeliveryCheckCubit, DeliveryCheckState>(
              builder: (context, state) {
                final isLoading = state is DeliveryCheckLoading;
                return SizedBox(
                  height: 29,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final pincode = _pincodeController.text.trim();
                            if (pincode.length != 6) {
                              AppToastMessenger.of(context).showSnackBar(
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
                              productVariantId: variantId,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.secondaryGreen
                          .withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.check,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
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
        padding: const EdgeInsets.only(top: 7),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
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
                        fontSize: 11.5,
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
                          fontSize: 10,
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
        Icon(icon, size: 15, color: AppColors.grey900),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
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
                          fontSize: 11,
                        ),
                      ),
                      Icon(
                        _descriptionExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_right_rounded,
                        color: _accent,
                        size: 15,
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 5),
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
              fontSize: 10.5,
              height: 1.3,
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
    add('Origin', product.origin);
    final dims = [variant?.length, variant?.width, variant?.height];
    if (dims.every((d) => d != null && d.trim().isNotEmpty)) {
      add('Dimensions', dims.map((d) => d!.trim()).join(' x '));
    }

    // Long text goes in a full-width card so it is not squeezed into half the screen.
    final wideRows = <MapEntry<String, String>>[];
    void addWide(String label, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        wideRows.add(MapEntry(label, value.trim()));
      }
    }

    addWide('Packaging', product.packaging);
    addWide('Sold by', product.vendorName);
    addWide('Seller address', product.vendorAddress);

    if (rows.isEmpty && wideRows.isEmpty) return const [];

    Widget card(List<MapEntry<String, String>> items) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4.5,
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
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        items[i].value,
                        style: const TextStyle(
                          color: AppColors.grey900,
                          fontSize: 10.5,
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
      const SizedBox(height: 14),
      _buildSectionHeader(Icons.list_rounded, 'Specifications'),
      const SizedBox(height: 7),
      if (rows.isNotEmpty && split)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: card(rows.sublist(0, half))),
            const SizedBox(width: 7),
            Expanded(child: card(rows.sublist(half))),
          ],
        )
      else if (rows.isNotEmpty)
        card(rows),
      if (rows.isNotEmpty && wideRows.isNotEmpty) const SizedBox(height: 7),
      if (wideRows.isNotEmpty) card(wideRows),
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
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
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
                      // The delivery check was for the previous variant's stock.
                      if (_deliveryCheckCubit.state is! DeliveryCheckInitial) {
                        _deliveryCheckCubit.reset();
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border, width: 1.2),
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
                        fontSize: 12.5,
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
                          fontSize: 9,
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
    // Quick: a fresh server verdict outranks the stock flag carried over from the
    // listing the customer came from (which may belong to another address).
    if (product.isExpress30) {
      final verdict = _availabilityCubit.state;
      if (verdict.phase == QuickAvailabilityPhase.checked) {
        if (verdict.canOrder) return true;
        if (verdict.availability?.status == QuickAvailabilityStatus.outOfStock) {
          return false;
        }
      }
    }
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

/// The Indian food mark: a green dot in a green box for veg, a red triangle in
/// a red box for non-veg.
class _FoodTypeMark extends StatelessWidget {
  final bool isVeg;

  const _FoodTypeMark({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF1E9E4A) : const Color(0xFFD32F2F);
    return Tooltip(
      message: isVeg ? 'Veg' : 'Non-veg',
      child: Container(
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: isVeg
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            : Transform.rotate(
                angle: -1.5708,
                child: Icon(Icons.play_arrow_rounded, size: 11, color: color),
              ),
      ),
    );
  }
}
