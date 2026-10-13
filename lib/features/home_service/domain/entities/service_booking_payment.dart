import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';

/// Payment order returned when a marketplace service booking is created.
///
/// Mirrors the `POST /service/book` response `data` payload.
class ServiceBookingPayment extends Equatable {
  final String razorpayOrderId;
  final double amount;
  final int amountInPaise;
  final String currency;
  final String razorpayKey;
  final String gateway;
  final ServiceBooking booking;

  const ServiceBookingPayment({
    required this.razorpayOrderId,
    required this.amount,
    required this.amountInPaise,
    required this.currency,
    required this.razorpayKey,
    required this.gateway,
    required this.booking,
  });

  /// Whether the Razorpay checkout can be launched for this booking.
  ///
  /// Services with a zero charge are created without a payment order.
  bool get isPayable =>
      razorpayOrderId.trim().isNotEmpty &&
      razorpayKey.trim().isNotEmpty &&
      amountInPaise > 0;

  @override
  List<Object?> get props => [
    razorpayOrderId,
    amount,
    amountInPaise,
    currency,
    razorpayKey,
    gateway,
    booking,
  ];
}
