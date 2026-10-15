import 'package:equatable/equatable.dart';

/// Represents an additional charge/discount line in cart and order payload.
class ExtraCharge extends Equatable {
  final String type;
  final String label;
  final double amount;
  final bool isDiscount;
  final int? sortOrder;

  const ExtraCharge({
    required this.type,
    required this.label,
    required this.amount,
    required this.isDiscount,
    this.sortOrder,
  });

  /// Static platform fee (₹9) applied to every order.
  static const double platformFeeAmount = 9;

  static const String platformFeeType = 'platform_fee';

  static const ExtraCharge platformFee = ExtraCharge(
    type: platformFeeType,
    label: 'Platform Fees',
    amount: platformFeeAmount,
    isDiscount: false,
  );

  @override
  List<Object?> get props => [type, label, amount, isDiscount, sortOrder];
}
