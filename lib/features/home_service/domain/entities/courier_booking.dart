import 'package:equatable/equatable.dart';

/// Razorpay order for a courier booking (same fields the other services use).
class CourierPaymentOrder extends Equatable {
  final String razorpayOrderId;
  final String razorpayKey;
  final int amountInPaise;
  final String currency;

  const CourierPaymentOrder({
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amountInPaise,
    required this.currency,
  });

  @override
  List<Object?> get props => [
    razorpayOrderId,
    razorpayKey,
    amountInPaise,
    currency,
  ];
}

/// Result returned after creating a courier booking.
class CourierBooking extends Equatable {
  final int bookingId;
  final String bookingNumber;
  final String courierName;
  final double chargeableWeightGrams;
  final double totalAmount;
  final double? courierRate;
  final double? serviceCharge;
  final int? estimatedDeliveryDays;
  final String status;
  final String paymentStatus;

  /// Null when the gateway order could not be created together with the
  /// booking; call `POST /service/courier/payment/create` to get it.
  final CourierPaymentOrder? payment;

  const CourierBooking({
    required this.bookingId,
    required this.bookingNumber,
    required this.courierName,
    required this.chargeableWeightGrams,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.courierRate,
    this.serviceCharge,
    this.estimatedDeliveryDays,
    this.payment,
  });

  @override
  List<Object?> get props => [
    bookingId,
    bookingNumber,
    courierName,
    chargeableWeightGrams,
    totalAmount,
    courierRate,
    serviceCharge,
    estimatedDeliveryDays,
    status,
    paymentStatus,
    payment,
  ];
}

/// Result of `POST /service/courier/payment/verify`.
class CourierPaymentResult extends Equatable {
  final int bookingId;
  final String status;
  final String paymentStatus;
  final String? transactionId;
  final double amount;
  final String courierName;
  final String? awbCode;

  const CourierPaymentResult({
    required this.bookingId,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    required this.courierName,
    this.transactionId,
    this.awbCode,
  });

  @override
  List<Object?> get props => [
    bookingId,
    status,
    paymentStatus,
    transactionId,
    amount,
    courierName,
    awbCode,
  ];
}
