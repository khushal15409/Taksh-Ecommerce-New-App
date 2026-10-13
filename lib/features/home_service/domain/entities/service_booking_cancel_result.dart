import 'package:equatable/equatable.dart';

/// Result returned after cancelling a service booking.
class ServiceBookingCancelResult extends Equatable {
  final int bookingId;
  final String bookingNumber;
  final String status;
  final double refundAmount;
  final String refundStatus;

  const ServiceBookingCancelResult({
    required this.bookingId,
    required this.bookingNumber,
    required this.status,
    required this.refundAmount,
    required this.refundStatus,
  });

  @override
  List<Object?> get props => [
    bookingId,
    bookingNumber,
    status,
    refundAmount,
    refundStatus,
  ];
}
