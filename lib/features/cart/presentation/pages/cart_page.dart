import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/dashed_divider.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/core/widgets/festive_page_header.dart';
import 'package:taksh_e_commerce/core/widgets/guest_auth_wall.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_state.dart';
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
            colors: [Color(0xFFFFF1DE), Color(0xFFF3F8E8), Color(0xFFBFE8C0)],
            stops: [0, 0.45, 1],
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

              ScaffoldMessenger.of(context).showSnackBar(
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
              ScaffoldMessenger.of(context).showSnackBar(
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDeliveryChip(
                          index: 0,
                          icon: Icons.bolt_rounded,
                          label:
                              '${AppLocalizations.of(context)!.quickDelivery} (${quickCart.totalItems})',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDeliveryChip(
                          index: 1,
                          icon: Icons.local_shipping_rounded,
                          label:
                              '${AppLocalizations.of(context)!.standardDelivery} (${standardCart.totalItems})',
                        ),
                      ),
                    ],
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

  Widget _buildHeader(BuildContext context, Cart activeCart) {
    return FestivePageHeader(
      title: 'My Cart',
      subtitle: 'Review your items and proceed to checkout',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      trailing: activeCart.isEmpty
          ? null
          : FestiveHeaderIconButton(
              icon: Icons.delete_outline_rounded,
              color: _accent,
              tooltip: AppLocalizations.of(context)!.clearCart,
              onPressed: () =>
                  _showClearCartDialog(context, _selectedDeliveryType),
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
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.1 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? _accent : AppColors.grey800,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? _accent : AppColors.grey900,
                    ),
                  ),
                ),
              ],
            ),
            if (selected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 110,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(4),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            children: [
              for (final item in cart.items) _buildCartItem(context, item),
              if (isQuick) _buildSavingTimeBanner(),
              _buildBillDetails(context, cart),
            ],
          ),
        ),
        _buildCheckoutBar(context, cart),
      ],
    );
  }

  /// "You're saving time!" promo shown on the quick delivery cart.
  Widget _buildSavingTimeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFFAF2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE3BF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_bag_rounded,
            size: 52,
            color: Color(0xFFB04BD6),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're saving time!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get your items delivered in just 25 minutes',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _accent, width: 3),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '25',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  'min',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
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
    final isQuick = item.isExpress30 == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: festiveCardDecoration(radius: 22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: item.image != null
                  ? Image.network(
                      item.image!,
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 14),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.grey900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showRemoveItemDialog(context, item),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEDD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: _accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.variantName != null &&
                      item.variantName!.trim().isNotEmpty)
                    Text(
                      item.variantName!,
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.sku(item.sku),
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                      ),
                    ),
                  if (isQuick) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F5E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppColors.secondaryGreen,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '25 mins',
                            style: TextStyle(
                              color: AppColors.secondaryGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
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
                                fontSize: 24,
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
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.image,
        size: 40,
        color: Theme.of(context).disabledColor,
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC27A), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _decrementQuantity(context, item),
            child: Container(
              width: 36,
              height: double.infinity,
              color: const Color(0xFFFFEEDD),
              child: Icon(
                item.qty == 1 ? Icons.delete_outline : Icons.remove_rounded,
                size: 20,
                color: _accent,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 38),
            alignment: Alignment.center,
            child: Text(
              '${item.qty}',
              style: const TextStyle(
                color: AppColors.grey900,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          InkWell(
            onTap: () => _incrementQuantity(context, item),
            child: Container(
              width: 36,
              height: double.infinity,
              color: const Color(0xFFFFEEDD),
              child: const Icon(
                Icons.add_circle_rounded,
                size: 22,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: festiveCardDecoration(radius: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 24,
                color: AppColors.grey900,
              ),
              SizedBox(width: 12),
              Text(
                'Bill Details',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context)!.subtotal,
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
          ),
          const SizedBox(height: 4),
          const DashedDivider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.totalItemsLabel(
                      cart.totalItems,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.totalAmount,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Text(
                '₹$displayTotal',
                style: const TextStyle(
                  fontSize: 32,
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FestiveGradientButton(
            onPressed: () {
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
                const Icon(Icons.verified_user_rounded, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.proceedToCheckout,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppColors.grey700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
