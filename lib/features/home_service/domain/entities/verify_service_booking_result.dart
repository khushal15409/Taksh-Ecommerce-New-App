import 'package:equatable/equatable.dart';

/// Result returned after verifying a marketplace service booking payment.
///
/// Mirrors the `POST /service/book/verify` response `data` payload.
class VerifyServiceBookingResult extends Equatable {
  final int bookingId;
  final String bookingNumber;
  final String status;
  final String paymentStatus;

  const VerifyServiceBookingResult({
    required this.bookingId,
    required this.bookingNumber,
    required this.status,
    required this.paymentStatus,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  @override
  List<Object?> get props => [bookingId, bookingNumber, status, paymentStatus];
}
