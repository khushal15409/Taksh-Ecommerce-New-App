import 'package:equatable/equatable.dart';

/// A wallet credit (refund) given back for an order.
///
/// Refunds are returned by the order API under `refund_transactions`.
class RefundTransaction extends Equatable {
  final String id;
  final String amount;
  final String status;
  final DateTime? createdAt;
  final String? paymentMethod;

  const RefundTransaction({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [id, amount, status, createdAt, paymentMethod];
}
