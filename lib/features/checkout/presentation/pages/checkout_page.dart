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
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/checkout_item_card.dart';
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

  /// True once the order has been placed (or its payment is being verified).
  bool _orderAlreadyPlaced = false;

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

    // Navigate to payment failure page. The order already exists (it is unpaid), so its id
    // goes along: the failure page can then offer to pay it again instead of the cart.
    // (The route reads these from the query string; an `extra` map was never read.)
    context.push(
      AppRoutes.paymentFailedPath(
        orderId: context.read<CheckoutBloc>().lastPlacedOrderId,
        errorCode: response.code?.toString(),
        errorMessage: response.message,
      ),
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
              // Once the order exists (placed, or its payment is being verified) a later
              // error must not send the user to the cart: the cart was emptied by the order,
              // and the order itself (and its payment status) is in My Orders.
              if (state is OrderPlaced || state is PaymentVerifying) {
                _orderAlreadyPlaced = true;
              }

              if (state is CheckoutError) {
                setState(() {
                  _isProcessingPayment = false;
                });
                final orderAlreadyPlaced = _orderAlreadyPlaced;
                _orderAlreadyPlaced = false;

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
                    context.go(
                      orderAlreadyPlaced ? AppRoutes.orders : AppRoutes.cart,
                    );
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
            final header = _CheckoutHeader(
              title: AppLocalizations.of(context)!.checkout,
              subtitle: 'Review your order and complete payment',
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
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderItemsSection(),
                        SizedBox(height: 10),
                        _SectionInset(child: AddressSelectorWidget()),
                        SizedBox(height: 9),
                        _SectionInset(child: PaymentMethodSelectorWidget()),
                        SizedBox(height: 9),
                        _SectionInset(child: _PriceBreakdownSection()),
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
        final first = items.isNotEmpty ? items.first : null;

        return Container(
          decoration: checkoutCardDecoration(),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _showItemDetails = !_showItemDetails),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 10, 9),
                  child: first == null
                      ? Text(AppLocalizations.of(context)!.itemsCount(0))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: first.image != null
                                  ? Image.network(
                                      first.image!,
                                      width: 64,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _itemPlaceholder(context),
                                    )
                                  : _itemPlaceholder(context),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: Text(
                                            first.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.grey900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _showItemDetails
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primaryOrange,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    first.variantName != null &&
                                            first.variantName!.trim().isNotEmpty
                                        ? first.variantName!
                                        : AppLocalizations.of(
                                            context,
                                          )!.sku(first.sku),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '₹${first.price}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 84,
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF4E6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primaryOrange,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Qty: ${first.qty}',
                                          style: const TextStyle(
                                            color: AppColors.primaryOrange,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_showItemDetails) ...[
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return CheckoutItemCard(item: items[index]);
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: Text(AppLocalizations.of(context)!.edit),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _itemPlaceholder(BuildContext context) {
    return Container(
      width: 64,
      height: 60,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        size: 22,
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
        final double grandTotal = canPlaceOrder
            ? state.summary.priceBreakdown.grandTotal
            : 0.0;
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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                left: -18,
                bottom: -14,
                child: IgnorePointer(
                  child: Icon(
                    Icons.filter_vintage_rounded,
                    size: 80,
                    color: Color(0xFFFFE3C2),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(46, 9, 14, 9),
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
                                fontSize: 11.5,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlaceOrderButton(
                          enabled:
                              canPlaceOrder && !isProcessing && !hasNoAddresses,
                          isProcessing: isProcessing,
                          hasNoAddresses: hasNoAddresses,
                          isCod: paymentMethod.type == PaymentMethodType.cod,
                          onTap: () => context
                              .findAncestorStateOfType<_CheckoutPageState>()
                              ?._processCheckout(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  final bool enabled;
  final bool isProcessing;
  final bool hasNoAddresses;
  final bool isCod;
  final VoidCallback onTap;

  const _PlaceOrderButton({
    required this.enabled,
    required this.isProcessing,
    required this.hasNoAddresses,
    required this.isCod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = hasNoAddresses
        ? l10n.addAddress
        : (isCod ? l10n.placeOrder : l10n.proceedToPay);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: enabled ? festiveOrangeGradient : null,
        color: enabled ? null : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Center(
            child: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!hasNoAddresses) ...[
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Adds the small extra side inset the section cards have in the design.
class _SectionInset extends StatelessWidget {
  final Widget child;

  const _SectionInset({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.5),
      child: child,
    );
  }
}

/// Festive checkout header: back button, title and subtitle.
class _CheckoutHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _CheckoutHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: topPadding + 79,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8431C), Color(0xFFFF8A1F), Color(0xFFFFB75E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  FestiveHeaderBackdrop.festiveOrangeAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            bottom: 8,
            child: IgnorePointer(
              child: Icon(Icons.eco_rounded, size: 34, color: Color(0xFF3E8E41)),
            ),
          ),
          const Positioned(
            right: 4,
            bottom: 6,
            child: IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 26,
                    color: Color(0xFFFFD36B),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.card_giftcard_rounded,
                    size: 40,
                    color: Color(0xFFD64A8A),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: topPadding + 3,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onBack,
                child: const SizedBox(
                  width: 30,
                  height: 29,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 17,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 56,
            top: topPadding + 21,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
