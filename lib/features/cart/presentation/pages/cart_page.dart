import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/core/widgets/guest_auth_wall.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:taksh_e_commerce/features/cart/presentation/widgets/cart_suggestions_section.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/selected_checkout_items.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// Cart page - displays quick and standard delivery carts in separate tabs.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color _accent = Color(0xFFFF8A1F);

  String get _selectedDeliveryType => _tabController.index == 0
      ? CartCubit.deliveryTypeExpress
      : CartCubit.deliveryTypeStandard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final currentState = context.read<CartCubit>().state;
      if (currentState is CartInitial || currentState is CartError) {
        context.read<CartCubit>().fetchAllCarts();
      }
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!mounted || _tabController.indexIsChanging) {
      return;
    }
    setState(() {});
  }

  void _syncSelectedTabWithCartAvailability(Cart quickCart, Cart standardCart) {
    if (_tabController.indexIsChanging) {
      return;
    }

    if (_tabController.index == 0 &&
        quickCart.isEmpty &&
        standardCart.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index == 0) {
          _tabController.animateTo(1);
        }
      });
      return;
    }

    if (_tabController.index == 1 &&
        standardCart.isEmpty &&
        quickCart.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index == 1) {
          _tabController.animateTo(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const GuestAuthWall(
            redirectToRoute: AppRoutes.cart,
            contentLabel: 'your cart',
            icon: Icons.shopping_cart_outlined,
          );
        }
        return _buildCartContent(context);
      },
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEFD9), Color(0xFFFFFBF5), Color(0xFFDFF3DC)],
            stops: [0, 0.4, 1],
          ),
        ),
        child: BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartError) {
              final l10n = AppLocalizations.of(context)!;
              final displayMessage =
                  (state.message == 'null' || state.message.isEmpty)
                  ? l10n.cartUnexpectedError
                  : l10n.cartUnexpectedError;

              AppToastMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    displayMessage,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CartOperationSuccess) {
              AppToastMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          builder: (context, state) {
            final cartCubit = context.read<CartCubit>();
            final quickCart = cartCubit.quickCart;
            final standardCart = cartCubit.standardCart;
            final activeCart =
                _selectedDeliveryType == CartCubit.deliveryTypeExpress
                ? quickCart
                : standardCart;
            final isInitialLoad =
                state is CartLoading &&
                quickCart.isEmpty &&
                standardCart.isEmpty;

            _syncSelectedTabWithCartAvailability(quickCart, standardCart);

            if (isInitialLoad) {
              return Column(
                children: [
                  _buildHeader(context, activeCart),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildHeader(context, activeCart),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 0, 11, 9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7.5,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDeliveryChip(
                            index: 0,
                            icon: Icons.local_shipping_rounded,
                            label:
                                '${AppLocalizations.of(context)!.quickDelivery} (${quickCart.totalItems})',
                          ),
                        ),
                        const SizedBox(width: 10.5),
                        Expanded(
                          child: _buildDeliveryChip(
                            index: 1,
                            icon: Icons.local_shipping_outlined,
                            label:
                                '${AppLocalizations.of(context)!.standardDelivery} (${standardCart.totalItems})',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is CartLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: activeCart.isEmpty
                      ? _buildEmptyCart(context)
                      : _buildCartBody(context, activeCart),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Festive header: lantern / diya artwork background with title + totals.
  Widget _buildHeader(BuildContext context, Cart activeCart) {
    final topPadding = MediaQuery.of(context).padding.top;
    final total = activeCart.isEmpty
        ? 0
        : (activeCart.totalWithDelivery ?? activeCart.total) +
              ExtraCharge.platformFeeAmount;
    final itemsLabel = activeCart.totalItems == 1
        ? '1 item'
        : '${activeCart.totalItems} items';

    return AspectRatio(
      aspectRatio: 841 / 274,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cart_header_bg.png',
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            gaplessPlayback: true,
          ),
          Positioned(
            left: 21,
            top: topPadding + 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
                Text(
                  '$itemsLabel • ₹$total',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 3)],
                  ),
                ),
              ],
            ),
          ),
          if (!activeCart.isEmpty)
            Positioned(
              right: 12,
              top: topPadding + 6,
              child: Material(
                color: Colors.white.withOpacity(0.92),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () =>
                      _showClearCartDialog(context, _selectedDeliveryType),
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.clearCart,
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryChip({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 37,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF4E6) : const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _accent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? _accent : AppColors.grey900,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _accent : AppColors.grey900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBody(BuildContext context, Cart cart) {
    final isQuick = _selectedDeliveryType == CartCubit.deliveryTypeExpress;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(11, 0, 11, 6),
            children: [
              for (final item in cart.items) _buildCartItem(context, item),
              _buildTrustStrip(),
              CartSuggestionsSection(
                key: ValueKey(isQuick),
                isQuickDelivery: isQuick,
                excludeProductIds: {
                  for (final item in cart.items)
                    if (item.productId != null) item.productId!,
                },
              ),
              _buildBillDetails(context, cart),
            ],
          ),
        ),
        _buildCheckoutBar(context, cart),
      ],
    );
  }

  /// Fast Delivery / Safe & Secure / Quality Products / 100% Genuine strip.
  Widget _buildTrustStrip() {
    Widget cell(IconData icon, String label) => Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2F9E55)),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.3,
              color: AppColors.grey900,
            ),
          ),
        ],
      ),
    );
    Widget divider() => Container(
      width: 1,
      height: 44,
      color: Colors.black.withOpacity(0.08),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F5E8), Color(0xFFF1FAF2)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cell(Icons.local_shipping_rounded, 'Fast\nDelivery'),
          divider(),
          cell(Icons.verified_user_rounded, 'Safe &\nSecure'),
          divider(),
          cell(Icons.workspace_premium_rounded, 'Quality\nProducts'),
          divider(),
          cell(Icons.eco_rounded, '100%\nGenuine'),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart,
              size: 60,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.cartEmptyTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.cartEmptySubtitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: IndiaGradients.saffronGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.startShopping,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: festiveCardDecoration(radius: 13),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image != null
                  ? Image.network(
                      item.image!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.grey900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showRemoveItemDialog(context, item),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 13,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (item.variantName != null &&
                      item.variantName!.trim().isNotEmpty)
                    Text(
                      item.variantName!,
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.sku(item.sku),
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 10.5,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F5E6),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: AppColors.secondaryGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'In stock',
                          style: TextStyle(
                            color: AppColors.secondaryGreen,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${item.price}',
                              style: const TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (item.qty > 1)
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.total(item.total.toString()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildQuantityControls(context, item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        size: 30,
        color: Theme.of(context).disabledColor,
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    Widget segment(IconData icon, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEDD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFC27A), width: 1),
        ),
        child: Icon(icon, size: 15, color: _accent),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        segment(
          item.qty == 1 ? Icons.delete_outline : Icons.remove_rounded,
          () => _decrementQuantity(context, item),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          alignment: Alignment.center,
          child: Text(
            '${item.qty}',
            style: const TextStyle(
              color: AppColors.grey900,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        segment(Icons.add_rounded, () => _incrementQuantity(context, item)),
      ],
    );
  }

  void _incrementQuantity(BuildContext context, CartItem item) {
    context.read<CartCubit>().updateItem(
      cartItemId: item.id,
      qty: item.qty + 1,
      deliveryType: CartCubit.deliveryTypeForItem(item),
    );
  }

  void _decrementQuantity(BuildContext context, CartItem item) {
    if (item.qty <= 1) {
      _showRemoveItemDialog(context, item);
    } else {
      context.read<CartCubit>().updateItem(
        cartItemId: item.id,
        qty: item.qty - 1,
        deliveryType: CartCubit.deliveryTypeForItem(item),
      );
    }
  }

  void _showRemoveItemDialog(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.removeItemTitle),
        content: Text(
          AppLocalizations.of(context)!.removeItemConfirm(item.productName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartCubit>().removeItem(
                item.id,
                deliveryType: CartCubit.deliveryTypeForItem(item),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.remove,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, String deliveryType) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCart),
        content: Text(AppLocalizations.of(context)!.clearCartConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartCubit>().clearAllItems(
                deliveryType: deliveryType,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.clear,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(BuildContext context, Cart cart) {
    final displayTotal =
        (cart.totalWithDelivery ?? cart.total) + ExtraCharge.platformFeeAmount;
    final itemsText = cart.totalItems == 1 ? '1 item' : '${cart.totalItems} items';

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: festiveCardDecoration(radius: 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 15,
                color: Color(0xFF2F9E55),
              ),
              SizedBox(width: 9),
              Text(
                'Order Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            '${AppLocalizations.of(context)!.subtotal} ($itemsText)',
            '₹${cart.total}',
          ),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context)!.deliveryCharges,
            AppLocalizations.of(context)!.free,
            valueColor: AppColors.secondaryGreen,
          ),
          for (final charge in cart.extraCharges)
            _buildSummaryRow(
              context,
              charge.label,
              '${charge.isDiscount ? '- ' : ''}₹${charge.amount}',
              valueColor: charge.isDiscount ? AppColors.secondaryGreen : null,
            ),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context)!.platformFees,
            '₹${ExtraCharge.platformFeeAmount}',
            info: true,
          ),
          const SizedBox(height: 0),
          Divider(height: 1, color: Colors.black.withOpacity(0.08)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalAmount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '₹$displayTotal',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 4, 11, 10),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          height: 43,
          decoration: BoxDecoration(
            gradient: festiveOrangeGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (cart.items.isEmpty) {
                  return;
                }

                context.push(
                  AppRoutes.checkout,
                  extra: SelectedCheckoutItems(
                    items: cart.items,
                    itemIds: cart.items.map((item) => item.id).toList(),
                    subtotal: cart.total,
                    totalQuantity: cart.totalItems,
                    extraCharges: cart.extraCharges,
                    deliveryType: _selectedDeliveryType,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 17, color: Colors.white),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.proceedToCheckout,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool info = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.grey700),
              ),
              if (info) ...[
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Platform fee',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
