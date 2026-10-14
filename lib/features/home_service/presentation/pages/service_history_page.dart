import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/theme/app_spacing.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/cubit/home_service_cubit.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/cubit/home_service_state.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/utils/service_invoice_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page displaying service booking history with rich detail view.
///
/// Backed by the marketplace endpoints `GET /service/book` (list) and
/// `GET /service/book/{id}` (detail).
class ServiceHistoryPage extends StatelessWidget {
  final int? serviceId;

  const ServiceHistoryPage({super.key, this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HomeServiceCubit>()..fetchServiceBookings(perPage: 15),
      child: _ServiceHistoryBody(serviceId: serviceId),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

String _formatDate(DateTime? date) =>
    date != null ? _dateFormat.format(date) : '—';

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toStringAsFixed(0);
  }
  return amount.toStringAsFixed(2);
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'paid':
      return const Color(0xFF2E7D32);
    case 'pending':
      return const Color(0xFFF57F17);
    case 'confirmed':
    case 'accepted':
    case 'assigned':
    case 'provider_assigned':
      return const Color(0xFF1565C0);
    case 'cancelled':
      return const Color(0xFFC62828);
    case 'in_progress':
    case 'in-progress':
    case 'started':
      return const Color(0xFF6A1B9A);
    default:
      return const Color(0xFF616161);
  }
}

/// The booking list/detail APIs return the service name, not its slug, so a
/// best-effort slug is derived for consistent theming.
String _serviceSlugFromName(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('courier')) return 'courier-booking';
  if (normalized.contains('electric')) return 'electrician';
  if (normalized.contains('plumb')) return 'plumber';
  if (normalized.contains('salon') ||
      normalized.contains('parlor') ||
      normalized.contains('parlour')) {
    return 'salon-parlor';
  }
  return '';
}

List<Color> _serviceGradient(String slug) {
  switch (slug) {
    case 'courier-booking':
      return [const Color(0xFFFF6B35), const Color(0xFFFF8F5E)];
    case 'electrician':
      return [const Color(0xFF1976D2), const Color(0xFF42A5F5)];
    case 'plumber':
      return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
    case 'salon-parlor':
      return [const Color(0xFFC2185B), const Color(0xFFEC407A)];
    default:
      return [const Color(0xFF5E35B1), const Color(0xFF7E57C2)];
  }
}

IconData _serviceIcon(String slug) {
  switch (slug) {
    case 'courier-booking':
      return Icons.local_shipping_rounded;
    case 'electrician':
      return Icons.electrical_services_rounded;
    case 'plumber':
      return Icons.plumbing_rounded;
    case 'salon-parlor':
      return Icons.content_cut_rounded;
    default:
      return Icons.home_repair_service_rounded;
  }
}

bool _isPaid(ServiceBooking booking) =>
    booking.paymentStatus.toLowerCase() == 'paid';

void _downloadInvoice(BuildContext context, ServiceBooking booking) {
  downloadServiceInvoice(
    context,
    path: ApiConstants.serviceBookInvoice(booking.id),
    bookingNumber: booking.bookingNumber,
  );
}

bool _canCancel(ServiceBooking booking) {
  if (booking.isCancelled) return false;
  final status = booking.status.toLowerCase();
  return status != 'completed' && status != 'cancelled';
}

/// Shows a confirmation dialog with an optional cancellation reason and
/// dispatches the cancel request on confirm.
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
            'This will cancel your service booking. This action cannot be '
            'undone.',
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
    cubit.cancelServiceBooking(
      bookingId: bookingId,
      reason: reason.isEmpty ? null : reason,
    );
  }

  reasonController.dispose();
}

// ─── Main Body ─────────────────────────────────────────────────────────────

class _ServiceHistoryBody extends StatelessWidget {
  final int? serviceId;

  const _ServiceHistoryBody({this.serviceId});

  List<ServiceBooking> _filter(List<ServiceBooking> bookings) {
    if (serviceId == null) return bookings;
    return bookings.where((b) => b.serviceId == serviceId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Service History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFFA726)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
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
          if (state is ServiceBookingCancelled) {
            AppToastMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking cancelled successfully'),
                backgroundColor: Color(0xFF2E7D32),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<HomeServiceCubit>().fetchServiceBookings(perPage: 15);
          } else if (state is ServiceBookingCancelError) {
            AppToastMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<HomeServiceCubit, HomeServiceState>(
          builder: (context, state) {
            if (state is ServiceBookingsLoading ||
                state is ServiceBookingCancelling) {
              return _buildLoadingView();
            }
            if (state is ServiceBookingsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<HomeServiceCubit>()
                    .fetchServiceBookings(perPage: 15),
              );
            }
            if (state is ServiceBookingsLoaded) {
              final bookings = _filter(state.page.bookings);
              if (bookings.isEmpty) {
                return const _EmptyView();
              }
              return RefreshIndicator(
                onRefresh: () => context
                    .read<HomeServiceCubit>()
                    .fetchServiceBookings(perPage: 15),
                color: AppColors.primaryOrange,
                child: ListView.builder(
                  padding: const EdgeInsets.all(
                    AppSpacing.screenPaddingHorizontal,
                  ),
                  itemCount: bookings.length + 1, // +1 for header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHistoryHeader(context, bookings.length);
                    }
                    final booking = bookings[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BookingCard(
                        booking: booking,
                        onTap: () => _openOrderDetails(context, booking),
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

  void _openOrderDetails(BuildContext context, ServiceBooking booking) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => _BookingDetailPage(bookingId: booking.id),
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<HomeServiceCubit>().fetchServiceBookings(perPage: 15);
          }
        });
  }

  Widget _buildHistoryHeader(BuildContext context, int count) {
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

  Widget _buildLoadingView() {
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
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

// ─── Booking Card ──────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final ServiceBooking booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final slug = _serviceSlugFromName(booking.serviceName);
    final grad = _serviceGradient(slug);
    final sColor = _statusColor(booking.status);
    final showCancel = _canCancel(booking);

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
              // ── Top row: icon + name + status ──
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: grad),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _serviceIcon(slug),
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
                          booking.serviceName.isNotEmpty
                              ? booking.serviceName
                              : 'Service Booking',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      booking.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: sColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Dates row ──
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
                        label: booking.providerName != null
                            ? 'Provider'
                            : 'Payment',
                        value:
                            booking.providerName ??
                            booking.paymentStatus.toUpperCase(),
                        icon: booking.providerName != null
                            ? Icons.engineering_rounded
                            : Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Amount ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Charge',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    '₹${_formatAmount(booking.serviceCharge)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: grad.first,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Cancel + Download Invoice ──
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_isPaid(booking))
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadInvoice(context, booking),
                          icon: Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: grad.first,
                          ),
                          label: Text(
                            'Invoice',
                            style: TextStyle(color: grad.first, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: grad.first.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
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
          getIt<HomeServiceCubit>()..fetchServiceBookingDetail(bookingId),
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
        if (state is ServiceBookingCancelled) {
          AppToastMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<HomeServiceCubit>().fetchServiceBookingDetail(bookingId);
        } else if (state is ServiceBookingCancelError) {
          AppToastMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<HomeServiceCubit, HomeServiceState>(
        builder: (context, state) {
          if (state is ServiceBookingDetailLoaded) {
            return _buildDetail(context, state.booking);
          }
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text('Booking Details'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFA726)],
                  ),
                ),
              ),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: state is ServiceBookingDetailError
                ? _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<HomeServiceCubit>()
                        .fetchServiceBookingDetail(bookingId),
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

  Widget _buildDetail(BuildContext context, ServiceBooking booking) {
    final slug = _serviceSlugFromName(booking.serviceName);
    final grad = _serviceGradient(slug);
    final sColor = _statusColor(booking.status);
    final showCancel = _canCancel(booking);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Booking #${booking.bookingNumber}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: grad)),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        children: [
          const SizedBox(height: AppSpacing.sm),

          // ── Service + Status header ──
          _SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _serviceIcon(slug),
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
                        booking.serviceName.isNotEmpty
                            ? booking.serviceName
                            : 'Service Booking',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    booking.status.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: sColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Customer Details ──
          if (booking.customerName != null || booking.customerMobile != null)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.person_rounded,
                    title: 'Customer Details',
                    gradient: grad,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(label: 'Name', value: booking.customerName ?? '—'),
                  _DetailRow(
                    label: 'Mobile',
                    value: booking.customerMobile ?? '—',
                  ),
                ],
              ),
            ),
          if (booking.customerName != null || booking.customerMobile != null)
            const SizedBox(height: AppSpacing.sm),

          // ── Address Details ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.location_on_rounded,
                  title: 'Address Details',
                  gradient: grad,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  label: 'Full Address',
                  value: _buildAddress(booking),
                ),
                if (booking.landmark != null && booking.landmark!.isNotEmpty)
                  _DetailRow(label: 'Landmark', value: booking.landmark!),
                _DetailRow(label: 'Pincode', value: booking.pincode),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Service Description ──
          if (booking.serviceShortDescription != null &&
              booking.serviceShortDescription!.isNotEmpty)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.description_rounded,
                    title: 'Service',
                    gradient: grad,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    booking.serviceShortDescription!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          if (booking.serviceShortDescription != null &&
              booking.serviceShortDescription!.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),

          // ── Provider ──
          if (booking.providerName != null)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.engineering_rounded,
                    title: 'Service Provider',
                    gradient: grad,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(label: 'Name', value: booking.providerName!),
                  if (booking.providerStatus != null)
                    _DetailRow(
                      label: 'Status',
                      value: booking.providerStatus!.toUpperCase().replaceAll(
                        '_',
                        ' ',
                      ),
                    ),
                ],
              ),
            ),
          if (booking.providerName != null)
            const SizedBox(height: AppSpacing.sm),

          // ── Payment Information ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.payment_rounded,
                  title: 'Payment Information',
                  gradient: grad,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PriceRow(
                  label: 'Service Charge',
                  amount: booking.serviceCharge,
                ),
                _PriceRow(
                  label: 'Paid Amount',
                  amount: booking.effectivePaidAmount,
                ),
                if (booking.refundAmount > 0)
                  _PriceRow(
                    label: 'Refund Amount',
                    amount: booking.refundAmount,
                    isDiscount: true,
                  ),
                const Divider(height: 20),
                _PriceRow(
                  label: 'Total',
                  amount: booking.serviceCharge,
                  isBold: true,
                  color: grad.first,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            booking.paymentStatus,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _statusColor(booking.paymentStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Timeline ──
          if (booking.timeline.isNotEmpty)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.timeline_rounded,
                    title: 'Timeline',
                    gradient: grad,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...booking.timeline.map(
                    (entry) => _TimelineRow(entry: entry, color: grad.first),
                  ),
                ],
              ),
            ),
          if (booking.timeline.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),

          // ── Cancel + Download Invoice ──
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
                const SizedBox(width: AppSpacing.sm),
              ],
              if (_isPaid(booking))
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadInvoice(context, booking),
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
                    onPressed: () => _openWhatsApp(booking.bookingNumber),
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
                    onPressed: () => _openEmail(booking.bookingNumber),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement callback request
                    },
                    icon: const Icon(
                      Icons.phone_callback_rounded,
                      size: 18,
                      color: AppColors.secondaryGreen,
                    ),
                    label: const Text(
                      'Call me back',
                      style: TextStyle(color: AppColors.secondaryGreen),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondaryGreen),
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

  String _buildAddress(ServiceBooking booking) {
    final parts = <String>[
      if (booking.addressLine != null && booking.addressLine!.isNotEmpty)
        booking.addressLine!,
      if (booking.addressLine2 != null && booking.addressLine2!.isNotEmpty)
        booking.addressLine2!,
      if (booking.city != null && booking.city!.isNotEmpty) booking.city!,
      if (booking.state != null && booking.state!.isNotEmpty) booking.state!,
    ];
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  Future<void> _openWhatsApp(String bookingNumber) async {
    const phoneNumber = '919518365510';
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail(String bookingNumber) async {
    final emailUrl = Uri.parse(
      'mailto:customersupport@takshallinone.in?subject=Service Booking Support&body=Hi, I need help with my service booking #$bookingNumber',
    );
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
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
  final List<Color> gradient;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
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
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
  final ServiceBookingTimelineEntry entry;
  final Color color;

  const _TimelineRow({required this.entry, required this.color});

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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                  entry.title.isNotEmpty ? entry.title : entry.status,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (entry.at != null)
                  Text(
                    _formatDate(entry.at),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                if (entry.reason != null && entry.reason!.isNotEmpty)
                  Text(
                    entry.reason!,
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

// ─── Empty View ────────────────────────────────────────────────────────────

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
              'Your service booking history\nwill appear here',
              style: TextStyle(color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ────────────────────────────────────────────────────────────

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
              'Could not load history',
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
