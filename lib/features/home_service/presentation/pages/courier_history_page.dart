import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/theme/app_spacing.dart';
import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking_history.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/cubit/home_service_cubit.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/cubit/home_service_state.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/utils/service_invoice_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

/// Courier booking history (same look as the service booking history).
///
/// Backed by `GET /service/courier/bookings` (list) and
/// `GET /service/courier/bookings/{id}` (detail).
class CourierHistoryPage extends StatelessWidget {
  final int? serviceId;

  const CourierHistoryPage({super.key, this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HomeServiceCubit>()..fetchCourierBookings(perPage: 30),
      child: const _CourierHistoryBody(),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

const _gradient = [Color(0xFFFF6B35), Color(0xFFFF8F5E)];
final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

String _formatDate(DateTime? date) =>
    date != null ? _dateFormat.format(date) : '—';

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) return amount.toStringAsFixed(0);
  return amount.toStringAsFixed(2);
}

Color _statusColor(String status) {
  switch (status.toLowerCase().replaceAll(' ', '_')) {
    case 'delivered':
    case 'paid':
      return const Color(0xFF2E7D32);
    case 'pending':
    case 'payment_pending':
      return const Color(0xFFF57F17);
    case 'order_created':
    case 'courier_assigned':
    case 'pickup_scheduled':
    case 'confirmed':
      return const Color(0xFF1565C0);
    case 'cancelled':
    case 'delivery_exception':
    case 'failed':
      return const Color(0xFFC62828);
    case 'picked_up':
    case 'in_transit':
    case 'out_for_delivery':
      return const Color(0xFF6A1B9A);
    default:
      return const Color(0xFF616161);
  }
}

/// What the customer sees as the booking state.
String _displayStatus({
  required bool cancelled,
  required bool paid,
  String? shipmentLabel,
}) {
  if (cancelled) return 'Cancelled';
  if (!paid) return 'Payment Pending';
  return shipmentLabel ?? 'Confirmed';
}

bool _canCancel({required bool cancelled, required String? shipmentStatus}) {
  if (cancelled) return false;
  const cancellable = [
    null,
    'pending',
    'order_created',
    'awb_assigned',
    'pickup_requested',
  ];
  return cancellable.contains(shipmentStatus);
}

Future<void> _confirmCancel(
  BuildContext context,
  HomeServiceCubit cubit,
  int bookingId,
) async {
  final reasonController = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Cancel Booking?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will cancel your courier booking. Paid bookings are refunded '
            'as per the cancellation policy.',
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Tell us why you are cancelling',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep Booking'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Cancel Booking'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final reason = reasonController.text.trim();
    cubit.cancelCourierBooking(
      bookingId: bookingId,
      reason: reason.isEmpty ? null : reason,
    );
  }

  reasonController.dispose();
}

void _downloadInvoice(BuildContext context, int id, String bookingNumber) {
  downloadServiceInvoice(
    context,
    path: ApiConstants.courierBookingInvoice(id),
    bookingNumber: bookingNumber,
  );
}

PreferredSizeWidget _gradientAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFA726)],
        ),
      ),
    ),
    foregroundColor: Colors.white,
    elevation: 0,
    actions: actions,
  );
}

void _toast(BuildContext context, String message, {bool error = false}) {
  AppToastMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ─── Main Body ─────────────────────────────────────────────────────────────

class _CourierHistoryBody extends StatelessWidget {
  const _CourierHistoryBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _gradientAppBar(
        'Courier History',
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              'New Booking',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<HomeServiceCubit, HomeServiceState>(
        listener: (context, state) {
          if (state is CourierBookingCancelled) {
            _toast(
              context,
              state.result.message.isNotEmpty
                  ? state.result.message
                  : 'Booking cancelled successfully',
            );
            context.read<HomeServiceCubit>().fetchCourierBookings(perPage: 30);
          } else if (state is CourierBookingCancelError) {
            _toast(context, state.message, error: true);
            context.read<HomeServiceCubit>().fetchCourierBookings(perPage: 30);
          }
        },
        child: BlocBuilder<HomeServiceCubit, HomeServiceState>(
          builder: (context, state) {
            if (state is CourierBookingsLoading ||
                state is CourierBookingCancelling) {
              return const _LoadingView();
            }
            if (state is CourierBookingsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<HomeServiceCubit>()
                    .fetchCourierBookings(perPage: 30),
              );
            }
            if (state is CourierBookingsLoaded) {
              final bookings = state.page.bookings;
              if (bookings.isEmpty) return const _EmptyView();
              return RefreshIndicator(
                onRefresh: () => context
                    .read<HomeServiceCubit>()
                    .fetchCourierBookings(perPage: 30),
                color: AppColors.primaryOrange,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppSpacing.screenPaddingHorizontal,
                  ),
                  itemCount: bookings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader(context, state.page.total);
                    }
                    final booking = bookings[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BookingCard(
                        booking: booking,
                        onTap: () => _openDetails(context, booking),
                        onCancel: () => _confirmCancel(
                          context,
                          context.read<HomeServiceCubit>(),
                          booking.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, CourierBookingSummary booking) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => _BookingDetailPage(bookingId: booking.id),
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<HomeServiceCubit>().fetchCourierBookings(perPage: 30);
          }
        });
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFFA726)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            count == 1 ? 'Booking' : 'Bookings',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Card ──────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final CourierBookingSummary booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final label = _displayStatus(
      cancelled: booking.isCancelled,
      paid: booking.isPaid,
      shipmentLabel: booking.shipmentStatusLabel,
    );
    final sColor = _statusColor(label);
    final showCancel = _canCancel(
      cancelled: booking.isCancelled,
      shipmentStatus: booking.shipmentStatus,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: _gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.courierName.isNotEmpty
                              ? booking.courierName
                              : 'Courier Booking',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking #${booking.bookingNumber}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(label: label, color: sColor, small: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DateInfo(
                        label: 'Booked on',
                        value: _formatDate(booking.createdAt),
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    Container(width: 1, height: 28, color: Colors.grey[300]),
                    Expanded(
                      child: _DateInfo(
                        label: booking.awbCode != null ? 'AWB' : 'Route',
                        value:
                            booking.awbCode ??
                            '${booking.pickupPincode} → ${booking.deliveryPincode}',
                        icon: booking.awbCode != null
                            ? Icons.qr_code_2_rounded
                            : Icons.route_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    '₹${_formatAmount(booking.totalAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _gradient.first,
                    ),
                  ),
                ],
              ),
              if (showCancel || booking.isPaid) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (showCancel) ...[
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: onCancel,
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: Colors.red[400],
                            ),
                            label: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (booking.isPaid) const SizedBox(width: 8),
                    ],
                    if (booking.isPaid)
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () => _downloadInvoice(
                              context,
                              booking.id,
                              booking.bookingNumber,
                            ),
                            icon: Icon(
                              Icons.download_rounded,
                              size: 16,
                              color: _gradient.first,
                            ),
                            label: Text(
                              'Invoice',
                              style: TextStyle(
                                color: _gradient.first,
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _gradient.first.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _StatusPill({
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 10 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(small ? 8 : 10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DateInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Detail Page ───────────────────────────────────────────────────

class _BookingDetailPage extends StatelessWidget {
  final int bookingId;

  const _BookingDetailPage({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HomeServiceCubit>()..fetchCourierBookingDetail(bookingId),
      child: _BookingDetailBody(bookingId: bookingId),
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  final int bookingId;

  const _BookingDetailBody({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeServiceCubit, HomeServiceState>(
      listener: (context, state) {
        if (state is CourierBookingCancelled) {
          _toast(
            context,
            state.result.message.isNotEmpty
                ? state.result.message
                : 'Booking cancelled successfully',
          );
          context.read<HomeServiceCubit>().fetchCourierBookingDetail(bookingId);
        } else if (state is CourierBookingCancelError) {
          _toast(context, state.message, error: true);
          context.read<HomeServiceCubit>().fetchCourierBookingDetail(bookingId);
        }
      },
      child: BlocBuilder<HomeServiceCubit, HomeServiceState>(
        builder: (context, state) {
          if (state is CourierBookingDetailLoaded) {
            return _buildDetail(context, state.booking);
          }
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _gradientAppBar('Booking Details'),
            body: state is CourierBookingDetailError
                ? _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<HomeServiceCubit>()
                        .fetchCourierBookingDetail(bookingId),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, CourierBookingDetail booking) {
    final label = _displayStatus(
      cancelled: booking.isCancelled,
      paid: booking.isPaid,
      shipmentLabel: booking.shipmentStatusLabel,
    );
    final sColor = _statusColor(label);
    final showCancel = _canCancel(
      cancelled: booking.isCancelled,
      shipmentStatus: booking.shipmentStatus,
    );
    final unit = booking.dimensionUnit;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _gradientAppBar('Booking #${booking.bookingNumber}'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        children: [
          const SizedBox(height: AppSpacing.sm),

          // ── Courier + Status header ──
          _SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: _gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courierName.isNotEmpty
                            ? booking.courierName
                            : 'Courier Booking',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Booking #${booking.bookingNumber}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusPill(label: label, color: sColor),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Pickup ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.person_rounded,
                  title: 'Pickup Details',
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(label: 'Name', value: booking.customerName),
                _DetailRow(label: 'Mobile', value: booking.customerMobile),
                _DetailRow(label: 'Address', value: booking.pickupAddress),
                _DetailRow(label: 'Pincode', value: booking.pickupPincode),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Delivery ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.location_on_rounded,
                  title: 'Delivery Details',
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(label: 'Receiver', value: booking.deliveryName),
                _DetailRow(label: 'Mobile', value: booking.deliveryMobile),
                _DetailRow(label: 'Address', value: booking.deliveryAddress),
                _DetailRow(label: 'Pincode', value: booking.deliveryPincode),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Parcel ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.inventory_2_rounded,
                  title: 'Parcel Details',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (booking.productDetails != null)
                  _DetailRow(label: 'Product', value: booking.productDetails!),
                if (booking.packagingDetails != null)
                  _DetailRow(
                    label: 'Packaging',
                    value: booking.packagingDetails!,
                  ),
                _DetailRow(
                  label: 'Weight',
                  value: '${_formatAmount(booking.weightGrams)} g',
                ),
                _DetailRow(
                  label: 'Chargeable',
                  value: '${_formatAmount(booking.chargeableWeightGrams)} g',
                ),
                _DetailRow(
                  label: 'Dimensions',
                  value:
                      '${_formatAmount(booking.length)} × ${_formatAmount(booking.height)} × ${_formatAmount(booking.width)} $unit',
                ),
                if (booking.customerNotes != null)
                  _DetailRow(label: 'Notes', value: booking.customerNotes!),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Courier & tracking ──
          if (booking.courierName.isNotEmpty || booking.awbCode != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.route_rounded,
                    title: 'Courier & Tracking',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (booking.courierName.isNotEmpty)
                    _DetailRow(label: 'Courier', value: booking.courierName),
                  if (booking.awbCode != null)
                    _DetailRow(label: 'AWB', value: booking.awbCode!),
                  if (booking.estimatedDeliveryDays != null)
                    _DetailRow(
                      label: 'Est. delivery',
                      value: '${booking.estimatedDeliveryDays} days',
                    ),
                  if (booking.trackingUrl != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(booking.trackingUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('Track shipment'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // ── Payment ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.payment_rounded,
                  title: 'Payment Information',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (booking.courierRate != null)
                  _PriceRow(
                    label: 'Courier Charge',
                    amount: booking.courierRate!,
                  ),
                if (booking.serviceCharge != null)
                  _PriceRow(
                    label: 'Service Charge',
                    amount: booking.serviceCharge!,
                  ),
                _PriceRow(
                  label: 'Paid Amount',
                  amount: booking.paidAmount ?? 0,
                ),
                if ((booking.refundAmount ?? 0) > 0)
                  _PriceRow(
                    label: 'Refund Amount',
                    amount: booking.refundAmount!,
                    isDiscount: true,
                  ),
                const Divider(height: 20),
                _PriceRow(
                  label: 'Total',
                  amount: booking.totalAmount,
                  isBold: true,
                  color: _gradient.first,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      _StatusPill(
                        label: booking.paymentStatus,
                        color: _statusColor(booking.paymentStatus),
                        small: true,
                      ),
                    ],
                  ),
                ),
                if (booking.refundStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Refund: ${booking.refundStatus!.replaceAll('_', ' ')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Timeline ──
          if (booking.timeline.isNotEmpty || booking.createdAt != null) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.timeline_rounded,
                    title: 'Timeline',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TimelineRow(title: 'Booking created', at: booking.createdAt),
                  if (booking.paidAt != null)
                    _TimelineRow(title: 'Payment received', at: booking.paidAt),
                  ...booking.timeline.map(
                    (e) => _TimelineRow(
                      title: e.title,
                      at: e.eventTime,
                      note: [
                        if (e.location != null) e.location!,
                        if (e.description != null) e.description!,
                      ].join(' • '),
                    ),
                  ),
                  if (booking.cancelledAt != null)
                    _TimelineRow(
                      title: 'Booking cancelled',
                      at: booking.cancelledAt,
                      note: booking.cancellationReason,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // ── Cancel + Download Invoice ──
          if (showCancel || booking.isPaid)
            Row(
              children: [
                if (showCancel) ...[
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmCancel(
                          context,
                          context.read<HomeServiceCubit>(),
                          booking.id,
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 18,
                          color: Colors.red[400],
                        ),
                        label: Text(
                          'Cancel Booking',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (booking.isPaid) const SizedBox(width: AppSpacing.sm),
                ],
                if (booking.isPaid)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: _gradient),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadInvoice(
                            context,
                            booking.id,
                            booking.bookingNumber,
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text(
                            'Download Invoice',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),

          // ── Need Help ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.primaryOrange,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Do you have any issues with this booking?',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse('https://wa.me/919518365510'),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Chat with us'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(
                        'mailto:customersupport@takshallinone.in?subject=Courier Booking Support&body=Hi, I need help with my courier booking #${booking.bookingNumber}',
                      ),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Send us an email'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryOrange),
                      foregroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: _gradient),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final bool isDiscount;
  final Color? color;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.isDiscount = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = isDiscount
        ? '- ₹${amount.abs().toStringAsFixed(2)}'
        : '₹${amount.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[isBold ? 800 : 600],
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            displayAmount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: isBold ? 16 : 13,
              color: isDiscount
                  ? const Color(0xFF2E7D32)
                  : (color ?? Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final DateTime? at;
  final String? note;

  const _TimelineRow({required this.title, this.at, this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 22, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (at != null)
                  Text(
                    _formatDate(at),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                if (note != null && note!.isNotEmpty)
                  Text(
                    note!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
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
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange.withValues(alpha: 0.1),
                    AppColors.primaryOrange.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 44,
                color: AppColors.primaryOrange.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No previous bookings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your courier booking history\nwill appear here',
              style: TextStyle(color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load bookings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
