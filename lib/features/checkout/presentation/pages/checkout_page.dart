import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/services/razorpay_service.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/app_error_toast.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/core/widgets/festive_page_header.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_event.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_state.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/payment_method_selection.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/pages/order_review_page.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/address_selector_widget.dart';
import 'package:taksh_e_commerce/core/widgets/dashed_divider.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/checkout_section_card.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/payment_method_selector_widget.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/price_breakdown_widget.dart';

/// Main checkout page for completing order
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late RazorpayService _razorpayService;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.initialize(
      onSuccess: _handleRazorpaySuccess,
      onFailure: _handleRazorpayFailure,
    );

    // Use addPostFrameCallback to ensure AddressBloc has time to load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAddressesLoaded();
      _syncAddressSelection(context.read<AddressBloc>().state);
    });
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _ensureAddressesLoaded() {
    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressInitial || addressState is AddressError) {
      context.read<AddressBloc>().add(const LoadAddressesEvent());
    }
  }

  Address? _resolveCheckoutAddress(AddressState addressState) {
    if (addressState is! AddressesLoaded || addressState.addresses.isEmpty) {
      return null;
    }

    return addressState.selectedAddress ??
        addressState.defaultAddress ??
        addressState.addresses.first;
  }

  void _syncAddressSelection(AddressState addressState) {
    final resolvedAddress = _resolveCheckoutAddress(addressState);
    if (resolvedAddress == null) {
      return;
    }

    final checkoutBloc = context.read<CheckoutBloc>();
    if (checkoutBloc.selectedAddress != null) {
      return;
    }

    checkoutBloc.add(SelectAddressEvent(resolvedAddress));
  }

  /// Handle Razorpay payment success
  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    // Step 3: Verify payment with backend
    context.read<CheckoutBloc>().add(
      VerifyPaymentEvent(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      ),
    );
  }

  /// Handle Razorpay payment failure
  void _handleRazorpayFailure(PaymentFailureResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    // Navigate to payment failure page
    context.push(
      AppRoutes.paymentFailed,
      extra: {
        'errorCode': response.code?.toString(),
        'errorMessage': response.message,
      },
    );
  }

  /// Process checkout and open the order review page.
  ///
  /// The review page is pushed via [Navigator] (not go_router) so that
  /// the existing [CheckoutBloc] instance is shared between the checkout
  /// page and the review page. This lets the checkout page continue to
  /// own the Razorpay flow and the post-placement navigation.
  Future<void> _processCheckout() async {
    if (_isProcessingPayment) return;

    final checkoutBloc = context.read<CheckoutBloc>();
    final state = checkoutBloc.state;

    // Ensure we have calculated checkout
    if (state is! CheckoutCalculated) {
      AppToastMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for checkout calculation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (checkoutBloc.selectedAddress == null) {
      AppToastMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final calculatedState = state;
    final reviewData = OrderReviewData(
      items: calculatedState.summary.items,
      address: calculatedState.summary.selectedAddress,
      deliveryOption: calculatedState.summary.deliveryOption,
      priceBreakdown: calculatedState.summary.priceBreakdown,
      paymentMethod: checkoutBloc.selectedPaymentMethod,
      extraCharges: checkoutBloc.extraChargesForReview,
    );

    setState(() {
      _isProcessingPayment = false;
    });

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<CheckoutBloc>.value(
          value: checkoutBloc,
          child: OrderReviewPage(data: reviewData),
        ),
      ),
    );
  }

  void _navigateToQuickDeliveryTracking({
    required int orderId,
    String? orderNumber,
  }) {
    final selectedAddress = context.read<CheckoutBloc>().selectedAddress;
    final customerLat = selectedAddress?.location.latitude;
    final customerLng = selectedAddress?.location.longitude;

    context.go(
      AppRoutes.quickDeliveryTracking(
        orderId.toString(),
        customerLat: customerLat,
        customerLng: customerLng,
        orderNumber: orderNumber,
      ),
    );
  }

  void _navigateToOrderPlaced({
    required int orderId,
    String? orderNumber,
    required String paymentMethod,
  }) {
    context.go(
      AppRoutes.orderPlacedPath(
        orderId: orderId,
        orderNumber: orderNumber,
        paymentMethod: paymentMethod,
      ),
    );
  }

  /// Pop the order review page if it is on the navigator stack.
  ///
  /// The review page is pushed via [Navigator] on top of the checkout
  /// page, so it must be dismissed before navigating to a top-level
  /// route (e.g. the order placed page) so the navigation stack is
  /// clean for the success page.
  void _popOrderReviewIfPresent() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: MultiBlocListener(
        listeners: [
          BlocListener<CheckoutBloc, CheckoutState>(
            listener: (context, state) {
              if (state is CheckoutError) {
                setState(() {
                  _isProcessingPayment = false;
                });

                // Show the specific server error message (e.g.
                // "Insufficient stock available") so the user knows
                // why the order failed, instead of a generic toast.
                AppErrorToast.show(context, message: state.message);

                // Pop the review page (if it's on the stack) so the
                // checkout page can be the one to handle the redirect.
                _popOrderReviewIfPresent();

                // Navigate to cart page after showing error so the
                // user can adjust quantities or remove out-of-stock
                // items before retrying.
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    context.go(AppRoutes.cart);
                  }
                });
              } else if (state is OrderCreated) {
                final isQuickDelivery =
                    state.order.deliveryType == '30_min' ||
                    state.order.isExpress;

                if (isQuickDelivery) {
                  _navigateToQuickDeliveryTracking(
                    orderId: state.order.id,
                    orderNumber: state.order.orderNumber,
                  );
                } else {
                  _navigateToOrderPlaced(
                    orderId: state.order.id,
                    orderNumber: state.order.orderNumber,
                    paymentMethod:
                        context
                            .read<CheckoutBloc>()
                            .selectedPaymentMethod
                            .type
                            .value,
                  );
                }
              } else if (state is OrderPlaced) {
                // Pop the review page (if it's on the stack) so the
                // checkout page is back on top before we proceed.
                _popOrderReviewIfPresent();

                final paymentMethod =
                    context.read<CheckoutBloc>().selectedPaymentMethod;
                if (paymentMethod.type == PaymentMethodType.cod) {
                  // COD: order is complete, show the success page
                  _navigateToOrderPlaced(
                    orderId: state.orderId,
                    orderNumber: state.orderNumber,
                    paymentMethod: paymentMethod.type.value,
                  );
                } else {
                  // Online: dispatch initiate payment
                  context.read<CheckoutBloc>().add(
                    InitiatePaymentEvent(state.orderId),
                  );
                }
              } else if (state is PaymentInitiated) {
                // Online payment flow - Step 2 complete, open Razorpay checkout
                // SECURITY: razorpayKey comes from backend, not from .env

                if (state.razorpayKey == null || state.razorpayKey!.isEmpty) {
                  setState(() {
                    _isProcessingPayment = false;
                  });
                  AppErrorToast.show(context);
                  return;
                }

                _razorpayService.openCheckout(
                  razorpayOrderId: state.razorpayOrderId,
                  amountInPaise: state.amountInPaise,
                  razorpayKey: state.razorpayKey!,
                  orderNumber: state.razorpayOrderId,
                );
              } else if (state is PaymentVerified) {
                // Online payment flow - Step 3 complete, navigate to success
                setState(() {
                  _isProcessingPayment = false;
                });

                final orderId = state.orderId;
                if (orderId != null && state.isQuickDelivery) {
                  _navigateToQuickDeliveryTracking(
                    orderId: orderId,
                    orderNumber: state.orderNumber,
                  );
                } else if (orderId != null) {
                  _navigateToOrderPlaced(
                    orderId: orderId,
                    orderNumber: state.orderNumber,
                    paymentMethod: PaymentMethodType.online.value,
                  );
                } else {
                  context.go(AppRoutes.orders);
                }
              } else if (state is CheckoutInvalid) {
                AppErrorToast.show(context);
              }
            },
          ),
          BlocListener<AddressBloc, AddressState>(
            listener: (context, state) {
              _syncAddressSelection(state);
            },
          ),
        ],
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          buildWhen: (previous, current) => current is OrderCreating,
          builder: (context, state) {
            final header = FestivePageHeader(
              title: AppLocalizations.of(context)!.checkout,
              subtitle: 'Review your order and complete the payment',
              artOpacity: 0.9,
              bottom: const _CheckoutStepper(),
              onBack: () => Navigator.of(context).maybePop(),
            );

            if (state is OrderCreating) {
              return Column(
                children: [
                  header,
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            return Column(
              children: [
                header,
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderItemsSection(),
                        SizedBox(height: 14),
                        AddressSelectorWidget(),
                        SizedBox(height: 14),
                        PaymentMethodSelectorWidget(),
                        SizedBox(height: 14),
                        _PriceBreakdownSection(),
                      ],
                    ),
                  ),
                ),
                const _CheckoutBottomBar(),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

/// Separate widget for order items section - rebuilds only when CheckoutCalculated changes
class _OrderItemsSection extends StatefulWidget {
  const _OrderItemsSection();

  @override
  State<_OrderItemsSection> createState() => _OrderItemsSectionState();
}

class _OrderItemsSectionState extends State<_OrderItemsSection> {
  bool _showItemDetails = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      buildWhen: (previous, current) =>
          current is CheckoutInitial ||
          current is CheckoutCalculated ||
          current is CheckoutCalculating,
      builder: (context, state) {
        if (state is! CheckoutCalculated) {
          // Check if we're waiting for address selection
          final addressState = context.watch<AddressBloc>().state;
          if (addressState is AddressesLoaded &&
              addressState.addresses.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please add a delivery address to continue',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingOrderDetails,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final items = state.summary.items;

        return CheckoutSectionCard(
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.primaryOrange,
          title: AppLocalizations.of(context)!.itemsCount(items.length),
          actionLabel: AppLocalizations.of(context)!.edit,
          onAction: () => context.pop(),
          expanded: _showItemDetails,
          onToggle: () => setState(() => _showItemDetails = !_showItemDetails),
          bodyPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 20),
                _buildItemRow(context, items[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemRow(BuildContext context, CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: item.image != null
              ? Image.network(
                  item.image!,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _itemPlaceholder(context),
                )
              : _itemPlaceholder(context),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.variantName != null && item.variantName!.trim().isNotEmpty
                    ? item.variantName!
                    : AppLocalizations.of(context)!.sku(item.sku),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${item.price}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1E0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.qty}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              Text(
                item.qty == 1 ? 'item' : 'items',
                style: const TextStyle(fontSize: 14, color: AppColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemPlaceholder(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        size: 28,
        color: Theme.of(context).disabledColor,
      ),
    );
  }
}

/// Separate widget for price breakdown - rebuilds only when CheckoutCalculated changes
class _PriceBreakdownSection extends StatelessWidget {
  const _PriceBreakdownSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      buildWhen: (previous, current) =>
          current is CheckoutInitial || current is CheckoutCalculated,
      builder: (context, state) {
        if (state is CheckoutCalculated) {
          return PriceBreakdownWidget(
            priceBreakdown: state.summary.priceBreakdown,
            extraCharges: context.read<CheckoutBloc>().extraChargesForReview,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Separate widget for bottom bar - rebuilds only when necessary
class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      buildWhen: (previous, current) =>
          current is CheckoutInitial ||
          current is CheckoutCalculated ||
          current is OrderCreating ||
          current is PaymentInitiating,
      builder: (context, state) {
        final canPlaceOrder = state is CheckoutCalculated;
        final grandTotal = canPlaceOrder
            ? state.summary.priceBreakdown.grandTotal
            : 0;
        final isProcessing =
            state is OrderCreating ||
            state is PaymentInitiating ||
            (context
                    .findAncestorStateOfType<_CheckoutPageState>()
                    ?._isProcessingPayment ??
                false);
        final paymentMethod = context
            .read<CheckoutBloc>()
            .selectedPaymentMethod;

        // Check if we have addresses
        final addressState = context.watch<AddressBloc>().state;
        final hasNoAddresses =
            addressState is AddressesLoaded && addressState.addresses.isEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalAmount,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.grey700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        hasNoAddresses
                            ? '₹0.00'
                            : '₹${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FestiveGradientButton(
                    onPressed: canPlaceOrder && !isProcessing && !hasNoAddresses
                        ? () => context
                              .findAncestorStateOfType<_CheckoutPageState>()
                              ?._processCheckout()
                        : null,
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!hasNoAddresses) ...[
                                const Icon(Icons.verified_user_rounded, size: 22),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  hasNoAddresses
                                      ? AppLocalizations.of(context)!.addAddress
                                      : (paymentMethod.type ==
                                                PaymentMethodType.cod
                                            ? AppLocalizations.of(
                                                context,
                                              )!.placeOrder
                                            : AppLocalizations.of(
                                                context,
                                              )!.proceedToPay),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Decorative Cart → Address → Payment progress shown in the header.
class _CheckoutStepper extends StatelessWidget {
  const _CheckoutStepper();

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, String label, {bool done = false}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Colors.white : Colors.transparent,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              icon,
              size: 26,
              color: done ? const Color(0xFFE8431C) : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    Widget link({bool check = false}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Row(
            children: [
              const Expanded(child: DashedDivider(color: Colors.white)),
              if (check)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              if (check)
                const Expanded(child: DashedDivider(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step(Icons.shopping_cart_outlined, 'Cart', done: true),
        link(check: true),
        step(Icons.location_on_outlined, 'Address'),
        link(),
        step(Icons.currency_rupee_rounded, 'Payment'),
      ],
    );
  }
}
