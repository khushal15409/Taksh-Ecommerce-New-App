import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/app_error_toast.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/features/cart/presentation/services/variant_cache_service.dart';
import 'package:taksh_e_commerce/features/orders/domain/entities/order.dart';
import 'package:taksh_e_commerce/features/orders/domain/entities/order_item.dart';
import 'package:taksh_e_commerce/features/orders/domain/entities/refund_transaction.dart';
import 'package:taksh_e_commerce/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:taksh_e_commerce/features/orders/presentation/cubit/orders_state.dart';
import 'package:taksh_e_commerce/features/orders/presentation/pages/return_request_page.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_ecommerce_product_details.dart';
import 'package:url_launcher/url_launcher.dart';

/// Order details page - displays detailed information about a specific order
class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isCancellingOrder = false;

  /// Cached order details so the page keeps rendering the content even
  /// when the cubit briefly transitions through transient states such as
  /// [DownloadingInvoice] or [OrdersInitial] (e.g. on first build
  /// before [fetchOrderDetails] emits [OrderDetailsLoading]).
  Order? _lastLoadedOrder;

  @override
  void initState() {
    super.initState();
    // Fetch order details when page loads
    context.read<OrdersCubit>().fetchOrderDetails(widget.orderId);
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
            colors: [Color(0xFFFFE9CC), Color(0xFFFFFAF2), Color(0xFFE3F4E1)],
            stops: [0, 0.3, 1],
          ),
        ),
        child: Column(
          children: [
            _buildPageHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  /// Peach/orange header with the "Taksh" parcel artwork.
  Widget _buildPageHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      height: topPadding + 80,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA43A), Color(0xFFFFD9A8), Color(0xFFFFEBD0)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 2,
            top: 0,
            child: const IgnorePointer(child: _OrderBoxArt()),
          ),
          Positioned(
            left: 13.5,
            top: topPadding + 15,
            child: Material(
              color: Colors.white.withOpacity(0.92),
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black26,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 59,
            top: topPadding + 15,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.orderDetails,
                  style: const TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const Text(
                  'Track your order & view details',
                  style: TextStyle(fontSize: 13, color: AppColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is OrdersError) {
              if (_isCancellingOrder) {
                setState(() {
                  _isCancellingOrder = false;
                });
              }
              AppErrorToast.show(context, message: state.message);
            } else if (state is OrderDetailsLoaded) {
              // Cache the latest order so the page keeps rendering
              // content while transient states (e.g. DownloadingInvoice)
              // flow through the cubit.
              _lastLoadedOrder = state.order;
            } else if (state is OrderStatusUpdating) {
              AppToastMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Processing update...'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (state is OrderStatusUpdated) {
              if (_isCancellingOrder) {
                _isCancellingOrder = false;
                _completeCancelFlow(state.message);
              } else {
                AppToastMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<OrdersCubit>().fetchOrderDetails(state.orderId);
              }
            }
          },
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderDetailsLoaded) {
              return _buildOrderDetails(context, state.order);
            }

            if (state is OrderStatusUpdating) {
              return const Center(child: CircularProgressIndicator());
            }

            // While an invoice is being downloaded we keep the order
            // details visible (the progress is shown in a modal
            // dialog). The same applies to the OrdersInitial state
            // and the post-success InvoiceDownloaded state.
            final cached = _lastLoadedOrder;
            if (cached != null &&
                (state is DownloadingInvoice ||
                    state is InvoiceDownloaded ||
                    state is OrdersError ||
                    state is OrdersInitial)) {
              return _buildOrderDetails(context, cached);
            }

            return Center(
              child: Text(AppLocalizations.of(context)!.somethingWentWrong),
            );
          },
    );
  }

  /// Build order details content
  Widget _buildOrderDetails(BuildContext context, Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeaderCard(order),
          const SizedBox(height: 11),
          _buildOrderTimelineSection(order),
          const SizedBox(height: 11),
          _buildOrderItemsSection(order),
          const SizedBox(height: 11),
          _buildOrderSummarySection(order),
          const SizedBox(height: 11),
          if (order.address != null) ...[
            _buildDeliveryAddressSection(order),
            const SizedBox(height: 11),
          ],
          _buildActionButtons(order),
        ],
      ),
    );
  }

  /// White rounded section card with an icon + title header.
  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    Widget? trailing,
    bool filledIcon = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              if (filledIcon)
                Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 12),
                )
              else
                Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  /// Build order header card
  Widget _buildOrderHeaderCard(Order order) {
    final l10n = AppLocalizations.of(context)!;
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    final canCancel = ![
      'delivered',
      'cancelled',
      'returned',
    ].contains(order.orderStatus.toLowerCase());

    Widget infoCell(
      IconData icon,
      Color tint,
      String value,
      String label, {
      Color? valueColor,
    }) {
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tint, size: 18),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.grey900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 13, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE7CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryOrange,
                  size: 16,
                ),
              ),
              const SizedBox(width: 7.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderNumber(order.orderNumber),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey900,
                      ),
                    ),
                    Text(
                      l10n.placedOn(_formatDateTimeAmPm(order.createdAt)),
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildStatusChip(order.orderStatus),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              infoCell(
                Icons.local_shipping_rounded,
                AppColors.secondaryGreen,
                _formatDeliveryType(context, order.deliveryType, order.isExpress),
                l10n.deliveryType,
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: Colors.black.withOpacity(0.08),
              ),
              infoCell(
                Icons.credit_card_rounded,
                AppColors.secondaryGreen,
                order.paymentMethod.toUpperCase(),
                l10n.paymentMethod,
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: Colors.black.withOpacity(0.08),
              ),
              infoCell(
                Icons.account_balance_wallet_outlined,
                AppColors.primaryOrange,
                order.paymentStatus.toUpperCase(),
                l10n.paymentStatus,
                valueColor: isPaid
                    ? AppColors.secondaryGreen
                    : AppColors.primaryOrange,
              ),
            ],
          ),
          if (order.estimatedDeliveryTime != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.access_time,
              l10n.estimatedDelivery,
              _formatDate(order.estimatedDeliveryTime!),
            ),
          ],
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                flex: 12,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadInvoice(order),
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: const Text('Download Invoice'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    side: const BorderSide(
                      color: AppColors.secondaryGreen,
                      width: 1.5,
                    ),
                    foregroundColor: AppColors.secondaryGreen,
                    backgroundColor: const Color(0xFFF2FAF3),
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 10,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelOrder(order),
                    icon: const Icon(Icons.cancel_rounded, size: 16),
                    label: Text(l10n.cancelOrder),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                      foregroundColor: const Color(0xFFE53935),
                      backgroundColor: const Color(0xFFFFF4F4),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Order tracking timeline with parcel illustration.
  Widget _buildOrderTimelineSection(Order order) {
    final timelineSteps = _buildTimelineSteps(order);

    return _sectionCard(
      icon: Icons.local_shipping_rounded,
      iconColor: AppColors.secondaryGreen,
      filledIcon: true,
      title: 'Order Tracking',
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 16,
            child: IgnorePointer(child: _ParcelIllustration()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: List.generate(
                timelineSteps.length,
                (index) => _buildTimelineStepTile(
                  step: timelineSteps[index],
                  isLast: index == timelineSteps.length - 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepTile({
    required _OrderTimelineStep step,
    required bool isLast,
  }) {
    const completedColor = AppColors.secondaryGreen;
    final pendingColor = Colors.grey.shade400;
    final indicatorColor = step.isCompleted ? completedColor : pendingColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted ? completedColor : Colors.white,
                    border: Border.all(color: indicatorColor, width: 2),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: step.isCompleted ? completedColor : pendingColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: step.isCompleted
                          ? AppColors.grey900
                          : AppColors.grey800,
                    ),
                  ),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  if (step.timeLabel.isNotEmpty)
                    Text(
                      step.timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_OrderTimelineStep> _buildTimelineSteps(Order order) {
    final normalizedStatus = order.orderStatus.toLowerCase();
    final currentRank = _timelineStatusRank(normalizedStatus);

    return [
      _OrderTimelineStep(
        title: 'Order Placed',
        subtitle: 'Your order has been placed successfully',
        timeLabel: _formatTimelineDateTime(order.createdAt),
        isCompleted: currentRank >= 0,
      ),
      _OrderTimelineStep(
        title: 'Order Confirmed',
        subtitle: 'Seller has processed your order',
        timeLabel: _formatTimelineDateTime(order.confirmedAt),
        isCompleted: currentRank >= 1,
      ),
      _OrderTimelineStep(
        title: 'Shipped',
        subtitle: 'Your item has been picked up by the courier',
        timeLabel: _formatTimelineDateTime(_inferShippedTime(order)),
        isCompleted: currentRank >= 2,
      ),
      _OrderTimelineStep(
        title: 'Out for Delivery',
        subtitle: 'Your item is out for delivery',
        timeLabel: _formatTimelineDateTime(_inferOutForDeliveryTime(order)),
        isCompleted: currentRank >= 3,
      ),
      _OrderTimelineStep(
        title: 'Delivered',
        subtitle: 'Your order has been delivered',
        timeLabel: _formatTimelineDateTime(order.deliveredAt),
        isCompleted: currentRank >= 4,
      ),
    ];
  }

  int _timelineStatusRank(String status) {
    switch (status) {
      case 'placed':
      case 'pending':
      case 'new':
        return 0;
      case 'confirmed':
      case 'ready_for_dispatch':
      case 'processing':
        return 1;
      case 'shipped':
      case 'dispatched':
      case 'picked_up':
        return 2;
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
      case 'cancelled':
      case 'returned':
        if (status == 'cancelled') {
          return 0;
        }
        return 4;
      default:
        return 0;
    }
  }

  DateTime? _inferShippedTime(Order order) {
    if (_timelineStatusRank(order.orderStatus.toLowerCase()) < 2) {
      return null;
    }

    return order.deliveredAt ??
        order.estimatedDeliveryTime ??
        order.confirmedAt ??
        order.updatedAt;
  }

  DateTime? _inferOutForDeliveryTime(Order order) {
    if (_timelineStatusRank(order.orderStatus.toLowerCase()) < 3) {
      return null;
    }

    return order.deliveredAt ?? order.estimatedDeliveryTime ?? order.updatedAt;
  }

  String _formatTimelineDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    return _formatDateTimeWithMonth(dateTime);
  }

  /// Build order items section
  Widget _buildOrderItemsSection(Order order) {
    return _sectionCard(
      icon: Icons.shopping_bag_rounded,
      iconColor: AppColors.primaryOrange,
      title: AppLocalizations.of(context)!.orderItems(order.items.length),
      child: Column(
        children: order.items
            .map((item) => _buildOrderItemCard(order, item))
            .toList(),
      ),
    );
  }

  /// Build individual order item card
  Widget _buildOrderItemCard(Order order, OrderItem item) {
    final productName =
        item.productName ?? item.productVariant?.product?.name ?? 'Product';
    final sku = item.productVariant?.sku ?? '';
    final variantLabel =
        item.productVariant?.variantLabel ??
        VariantCacheService.instance.getVariantLabel(item.productVariantId) ??
        '';
    final qty = item.qty;
    // `price` already includes the Taksh charge (it is the price the customer
    // saw in the cart), so it is shown as it is.
    final unitPrice = double.tryParse(item.price) ?? 0;
    final totalPrice = unitPrice * qty;
    final canReturn = order.orderStatus.toLowerCase() == 'delivered';

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _OrderItemThumbnail(item: item),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.grey900,
                      ),
                    ),
                    if (variantLabel.isNotEmpty)
                      Text(
                        variantLabel,
                        style: const TextStyle(
                          color: AppColors.grey700,
                          fontSize: 12,
                        ),
                      )
                    else if (sku.isNotEmpty)
                      Text(
                        'SKU: $sku',
                        style: const TextStyle(
                          color: AppColors.grey700,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.qtyPrice(qty, unitPrice.toStringAsFixed(2)),
                      style: const TextStyle(
                        color: AppColors.grey700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBD6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          // Return button (only for delivered orders)
          if (canReturn) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReturnRequest(item),
                icon: const Icon(Icons.keyboard_return, size: 18),
                label: Text(AppLocalizations.of(context)!.returnItem),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                  foregroundColor: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build delivery address section
  Widget _buildDeliveryAddressSection(Order order) {
    final address = order.address!;
    final addressLine = [
      address.addressLine1,
      address.addressLine2,
    ].where((line) => line != null && line.trim().isNotEmpty).join(', ');
    final canChange = ![
      'delivered',
      'cancelled',
      'returned',
    ].contains(order.orderStatus.toLowerCase());
    const bodyStyle = TextStyle(
      fontSize: 13,
      color: AppColors.grey800,
      height: 1.3,
    );

    return _sectionCard(
      icon: Icons.location_on_rounded,
      iconColor: AppColors.primaryOrange,
      title: AppLocalizations.of(context)!.deliveryAddress,
      trailing: canChange
          ? OutlinedButton.icon(
              onPressed: () => _requestAddressChange(order),
              icon: const Icon(Icons.edit_note_rounded, size: 14),
              label: const Text('Change Address'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(color: Color(0xFFFFB067)),
                backgroundColor: const Color(0xFFFFF6EC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(child: _HouseIllustration()),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
                    color: AppColors.grey900,
                  ),
                ),
                Text(address.mobile, style: bodyStyle),
                Text(addressLine, style: bodyStyle),
                Text(
                  '${address.landmark != null && address.landmark!.isNotEmpty ? '${address.landmark}, ' : ''}${address.pincode}',
                  style: bodyStyle,
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  /// There is no change-address API for placed orders, so route the request
  /// to support with the order number pre-filled.
  Future<void> _requestAddressChange(Order order) async {
    final emailUrl = Uri.parse(
      'mailto:support@taksh.com?subject=${Uri.encodeComponent('Change delivery address for order #${order.orderNumber}')}&body=${Uri.encodeComponent('Hi, I would like to change the delivery address for order #${order.orderNumber}.')}',
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else if (mounted) {
      AppErrorToast.show(context);
    }
  }

  /// Build order summary section
  Widget _buildOrderSummarySection(Order order) {
    final l10n = AppLocalizations.of(context)!;
    // `itemsTotal` is the vendor share; the Taksh charge is part of what the
    // customer pays for the product, so it is folded into the subtotal instead
    // of being shown as a separate line.
    final takshCharge = _parseAmount(order.takshChargeTotal) ?? 0;
    final vendorItemsTotal = _parseAmount(order.itemsTotal);
    final itemsTotal = vendorItemsTotal != null
        ? vendorItemsTotal + takshCharge
        : _parseAmount(order.subtotalAmount) ??
              order.items.fold<double>(
                0,
                (sum, item) =>
                    sum + ((double.tryParse(item.price) ?? 0) * item.qty),
              );
    final deliveryCharges = _parseAmount(order.deliveryCharges);
    final platformFee = _parseAmount(order.platformFee);
    final quickDeliveryFee = _parseAmount(order.quickDeliveryFee);
    final discount = _parseAmount(order.discountAmount);
    final totalAmount = _parseAmount(order.totalAmount) ?? itemsTotal;
    final itemCount = order.items.length;

    return _sectionCard(
      icon: Icons.description_rounded,
      iconColor: AppColors.secondaryGreen,
      title: l10n.orderSummary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            '${l10n.subtotal} ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
            '₹${itemsTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),
          _buildSummaryRow(
            l10n.deliveryCharges,
            deliveryCharges != null && deliveryCharges != 0
                ? '₹${deliveryCharges.toStringAsFixed(2)}'
                : l10n.free,
            valueColor: deliveryCharges != null && deliveryCharges != 0
                ? null
                : AppColors.secondaryGreen,
          ),
          if (platformFee != null && platformFee != 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              l10n.platformFee,
              '₹${platformFee.toStringAsFixed(2)}',
            ),
          ],
          if (quickDeliveryFee != null && quickDeliveryFee != 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              l10n.quickDeliveryFee,
              '₹${quickDeliveryFee.toStringAsFixed(2)}',
            ),
          ],
          if (discount != null && discount != 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              l10n.discountLabel,
              '- ₹${discount.abs().toStringAsFixed(2)}',
              valueColor: AppColors.secondaryGreen,
            ),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBD6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalAmount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          if (order.refundTransactions.isNotEmpty) ...[
            const Divider(height: 24),
            const Text(
              'Refunds',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            for (final refund in order.refundTransactions)
              _buildRefundRow(refund),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundRow(RefundTransaction refund) {
    final amount = _parseAmount(refund.amount) ?? 0;
    final status = refund.status.replaceAll('_', ' ');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Wallet credit${status.isEmpty ? '' : ' · $status'}',
              style: const TextStyle(fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '+ ₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  double? _parseAmount(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.replaceAll(',', '').trim();
    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  /// Build action buttons
  Widget _buildActionButtons(Order order) {
    final canReturn = order.orderStatus.toLowerCase() == 'delivered';

    return Column(
      children: [
        if (canReturn)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _openReturnRequestPage(order: order);
              },
              icon: const Icon(Icons.keyboard_return),
              label: Text(AppLocalizations.of(context)!.returnOrder),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primaryOrange),
                foregroundColor: AppColors.primaryOrange,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        if (canReturn) const SizedBox(height: 11),

        // Need Help Section
        _sectionCard(
          icon: Icons.headset_mic_rounded,
          iconColor: AppColors.primaryOrange,
          title: AppLocalizations.of(context)!.needHelp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.orderIssues,
                style: const TextStyle(
                  color: AppColors.grey700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.chatWithUs),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: const Color(0xFFFF8A1F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 42),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7.5),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openEmail,
                      icon: const Icon(Icons.mail_outline_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.sendEmail),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(
                          color: Color(0xFFFF8A1F),
                          width: 1.5,
                        ),
                        foregroundColor: const Color(0xFFFF8A1F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 42),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build info row
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.grey600, fontSize: 15),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.grey900,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Build summary row
  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool info = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: AppColors.grey800),
            ),
            if (info) ...[
              const SizedBox(width: 6),
              const Tooltip(
                message: 'Taksh service charge',
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.grey900,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build status chip
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'ready_for_dispatch':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade400;
        displayText = AppLocalizations.of(
          context,
        )!.readyForDispatch.toUpperCase();
        break;
      case 'dispatched':
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue.shade400;
        displayText = AppLocalizations.of(context)!.dispatched.toUpperCase();
        break;
      case 'delivered':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade400;
        displayText = AppLocalizations.of(context)!.delivered.toUpperCase();
        break;
      case 'pending':
        backgroundColor = const Color(0xFFDDF3E1);
        textColor = AppColors.secondaryGreen;
        displayText = 'PENDING';
        break;
      default:
        backgroundColor = Theme.of(context).dividerColor.withOpacity(0.1);
        textColor =
            Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grey700;
        displayText = status.toUpperCase().replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// Format datetime as "2 Oct 2026 at 06:42 AM".
  String _formatDateTimeAmPm(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year} at '
        '${hour12.toString().padLeft(2, '0')}:$minute $suffix';
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date to DD month YYYY (e.g. 09 March 2026)
  String _formatDateWithMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];

    return '$day $month ${date.year}';
  }

  /// Format datetime to DD month YYYY at HH:mm (e.g. 09 March 2026 at 20:08)
  String _formatDateTimeWithMonth(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${_formatDateWithMonth(date)} at $hour:$minute';
  }

  /// Format delivery type
  String _formatDeliveryType(
    BuildContext context,
    String type,
    bool isExpress,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // No guaranteed time exists for Quick delivery: label only.
    if (isExpress) {
      return l10n.quickDelivery;
    }
    switch (type.toLowerCase()) {
      case 'normal':
      case '1_day':
        return 'Normal Delivery';
      default:
        return type.toUpperCase();
    }
  }

  /// Show return request bottom sheet for specific item
  Future<void> _showReturnRequest(OrderItem item) async {
    final didSubmit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersCubit>(),
          child: ReturnRequestPage(
            orderId: widget.orderId,
            items: [item],
            initialSelectedItem: item,
          ),
        ),
      ),
    );

    if (didSubmit == true && mounted) {
      context.read<OrdersCubit>().fetchOrderDetails(widget.orderId);
    }
  }

  /// Open return request page for full order flow.
  Future<void> _openReturnRequestPage({required Order order}) async {
    final didSubmit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersCubit>(),
          child: ReturnRequestPage(orderId: order.id, items: order.items),
        ),
      ),
    );

    if (didSubmit == true && mounted) {
      context.read<OrdersCubit>().fetchOrderDetails(order.id);
    }
  }

  /// Download the invoice PDF for the given order.
  ///
  /// Shows a modal progress dialog while the file is being downloaded
  /// and opens the PDF with the system viewer once the download
  /// completes. On failure, the error is surfaced through the existing
  /// OrdersError toast.
  Future<void> _downloadInvoice(Order order) async {
    if (order.orderNumber.isEmpty) {
      AppToastMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice is not available for this order.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Capture the cubit from the page's context BEFORE showing the
    // dialog. The dialog is rendered in a separate Navigator overlay
    // that does not inherit the BlocProvider from the page, so we
    // re-provide it inside the dialog via BlocProvider.value.
    final cubit = context.read<OrdersCubit>();
    _showInvoiceDownloadDialog(context, cubit, order.orderNumber);

    await cubit.downloadInvoice(order.orderNumber);
  }

  void _showInvoiceDownloadDialog(
    BuildContext context,
    OrdersCubit cubit,
    String orderNumber,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: BlocConsumer<OrdersCubit, OrdersState>(
            listenWhen: (previous, current) =>
                current is DownloadingInvoice ||
                current is InvoiceDownloaded ||
                current is OrdersError,
            listener: (dialogContext, state) {
              if (state is InvoiceDownloaded &&
                  state.orderNumber == orderNumber) {
                Navigator.of(dialogContext).pop();
                _onInvoiceDownloaded(context, state);
              } else if (state is OrdersError) {
                Navigator.of(dialogContext).pop();
              }
            },
            buildWhen: (previous, current) => current is DownloadingInvoice,
            builder: (dialogContext, state) {
              final progress = state is DownloadingInvoice
                  ? state.progress.clamp(0.0, 1.0)
                  : 0.0;
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  title: const Text('Downloading invoice'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order #$orderNumber',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Theme.of(dialogContext)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onInvoiceDownloaded(BuildContext context, InvoiceDownloaded state) {
    AppToastMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice for order #${state.orderNumber} downloaded successfully',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: Colors.white,
          onPressed: () => _openInvoiceFile(context, state.filePath),
        ),
      ),
    );
  }

  Future<void> _openInvoiceFile(
    BuildContext context,
    String filePath,
  ) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        AppToastMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open invoice (${result.message}). '
              'File saved at: $filePath',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToastMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open invoice. File saved at: $filePath',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Mock function to cancel order (simulates API call)
  Future<void> _cancelOrder(Order order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancelOrder),
        content: Text(
          'Are you sure you want to cancel order #${order.orderNumber}?', // Keep number formatted
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.exit, // Or 'Yes, Cancel'
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isCancellingOrder = true;
      });
      context.read<OrdersCubit>().cancelOrder(order.id);
    }
  }

  void _completeCancelFlow(String message) {
    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop<String>(message);
      return;
    }

    AppToastMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
    context.go(AppRoutes.orders);
  }

  /// Open WhatsApp chat
  Future<void> _openWhatsApp() async {
    final whatsappUrl = Uri.parse(
      'https://wa.me/919999999999?text=Hi, I need help with my order',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppErrorToast.show(context);
      }
    }
  }

  /// Open email client
  Future<void> _openEmail() async {
    final emailUrl = Uri.parse(
      'mailto:support@taksh.com?subject=Order Support Request&body=Hi, I need help with my order',
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      if (mounted) {
        AppErrorToast.show(context);
      }
    }
  }
}

class _OrderItemThumbnail extends StatefulWidget {
  const _OrderItemThumbnail({required this.item});

  final OrderItem item;

  @override
  State<_OrderItemThumbnail> createState() => _OrderItemThumbnailState();
}

class _OrderItemThumbnailState extends State<_OrderItemThumbnail> {
  static final Map<int, String?> _productImageCache = <int, String?>{};
  static final Map<int, Future<String?>> _pendingProductImages =
      <int, Future<String?>>{};

  String? _resolvedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void didUpdateWidget(covariant _OrderItemThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.image != widget.item.image ||
        oldWidget.item.productVariant?.product?.id !=
            widget.item.productVariant?.product?.id ||
        oldWidget.item.productVariant?.productId !=
            widget.item.productVariant?.productId) {
      _initializeImage();
    }
  }

  void _initializeImage() {
    _resolvedImageUrl = _normalizeImageUrl(widget.item.image);
    if (_resolvedImageUrl != null) {
      return;
    }

    final productId =
        widget.item.productVariant?.product?.id ??
        widget.item.productVariant?.productId;
    if (productId == null) {
      return;
    }

    if (_productImageCache.containsKey(productId)) {
      _resolvedImageUrl = _normalizeImageUrl(_productImageCache[productId]);
      return;
    }

    _resolveMissingImage(productId);
  }

  Future<void> _resolveMissingImage(int productId) async {
    final future = _pendingProductImages.putIfAbsent(productId, () async {
      final result = await getIt<GetEcommerceProductDetails>()(
        GetEcommerceProductDetailsParams(productId: productId),
      );

      return result.fold(
        (_) => null,
        (product) => _normalizeImageUrl(product.primaryImageUrl),
      );
    });

    final imageUrl = await future;
    _pendingProductImages.remove(productId);
    _productImageCache[productId] = imageUrl;

    if (!mounted) {
      return;
    }

    setState(() {
      _resolvedImageUrl = imageUrl;
    });
  }

  String? _normalizeImageUrl(String? rawImageUrl) {
    final normalized = rawImageUrl?.trim();
    if (normalized == null ||
        normalized.isEmpty ||
        normalized.toLowerCase() == 'null') {
      return null;
    }

    final imageUri = Uri.tryParse(normalized);
    if (imageUri != null && imageUri.hasScheme) {
      return normalized;
    }

    final apiBaseUri = Uri.parse(ApiConstants.prodBaseUrl);
    final originUri = apiBaseUri.replace(path: '', query: '', fragment: '');
    final origin = originUri.toString().replaceAll(RegExp(r'/$'), '');

    if (normalized.startsWith('/')) {
      return '$origin$normalized';
    }

    return '$origin/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 49,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _resolvedImageUrl != null
            ? Image.network(
                _resolvedImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.shopping_bag_outlined,
                  color: Theme.of(context).disabledColor,
                  size: 22,
                ),
              )
            : Icon(
                Icons.shopping_bag_outlined,
                color: Theme.of(context).disabledColor,
                size: 30,
              ),
      ),
    );
  }
}

class _OrderTimelineStep {
  final String title;
  final String subtitle;
  final String timeLabel;
  final bool isCompleted;

  const _OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.isCompleted,
  });
}

/// Decorative "Taksh" parcel + map pin shown in the page header.
class _OrderBoxArt extends StatelessWidget {
  const _OrderBoxArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(
            left: 8,
            bottom: 6,
            child: Icon(Icons.eco_rounded, size: 30, color: Color(0xFF4CAF50)),
          ),
          Positioned(
            right: 2,
            bottom: 8,
            child: Icon(Icons.eco_rounded, size: 34, color: Color(0xFF66BB6A)),
          ),
          Positioned(right: 26, bottom: 4, child: _TakshBox()),
          Positioned(
            left: 70,
            top: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 40,
              color: Color(0xFFE8531C),
            ),
          ),
        ],
      ),
    );
  }
}

class _TakshBox extends StatelessWidget {
  const _TakshBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2A25E), Color(0xFFC9803A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Taksh',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color(0xFF5A3A1A),
        ),
      ),
    );
  }
}

/// Parcel + pin illustration beside the tracking timeline.
class _ParcelIllustration extends StatelessWidget {
  const _ParcelIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(Icons.eco_rounded, size: 28, color: Color(0xFFA5D6A7)),
          ),
          Positioned(
            right: 0,
            bottom: 8,
            child: Icon(Icons.eco_rounded, size: 34, color: Color(0xFF81C784)),
          ),
          Positioned(
            left: 14,
            bottom: 6,
            child: Icon(
              Icons.inventory_2_rounded,
              size: 72,
              color: Color(0xFFE8A65D),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 36,
              color: Color(0xFFE8531C),
            ),
          ),
        ],
      ),
    );
  }
}

/// House + pin illustration beside the delivery address.
class _HouseIllustration extends StatelessWidget {
  const _HouseIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 94,
      height: 66,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(Icons.park_rounded, size: 24, color: Color(0xFF81C784)),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: Icon(Icons.home_rounded, size: 46, color: Color(0xFFE5532D)),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 26,
              color: Color(0xFFFF8A1F),
            ),
          ),
        ],
      ),
    );
  }
}
