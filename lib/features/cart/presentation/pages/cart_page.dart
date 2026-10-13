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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.cart,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final activeCart = context.read<CartCubit>().cartForDeliveryType(
                _selectedDeliveryType,
              );
              if (activeCart.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _showClearCartDialog(context, _selectedDeliveryType),
                tooltip: AppLocalizations.of(context)!.clearCart,
              );
            },
          ),
        ],
      ),
      body: FestiveHeaderBackdrop(
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
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
                          icon: Icons.local_shipping_outlined,
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
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: selected ? festiveOrangeGradient : null,
          color: selected ? null : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.grey800,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.grey900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBody(BuildContext context, Cart cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length + 1,
            itemBuilder: (context, index) {
              if (index == cart.items.length) {
                return _buildBillDetails(context, cart);
              }
              return _buildCartItem(context, cart.items[index]);
            },
          ),
        ),
        _buildCheckoutBar(context, cart),
      ],
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: festiveCardDecoration(),
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
                      width: 80,
                      height: 80,
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
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.variantName != null &&
                      item.variantName!.trim().isNotEmpty)
                    Text(
                      item.variantName!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.sku(item.sku),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price}',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildQuantityControls(context, item),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.total(item.total.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
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
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryOrange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            context,
            icon: item.qty == 1 ? Icons.delete_outline : Icons.remove,
            onTap: () => _decrementQuantity(context, item),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${item.qty}',
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _buildControlButton(
            context,
            icon: Icons.add,
            onTap: () => _incrementQuantity(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.primaryOrange),
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
    final displayTotal = (cart.totalWithDelivery ?? cart.total) +
        ExtraCharge.platformFeeAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: festiveCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: AppColors.primaryOrange,
              ),
              SizedBox(width: 8),
              Text(
                'Bill Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalItemsLabel(cart.totalItems),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '₹$displayTotal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
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
              Text(
                AppLocalizations.of(context)!.proceedToCheckout,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
