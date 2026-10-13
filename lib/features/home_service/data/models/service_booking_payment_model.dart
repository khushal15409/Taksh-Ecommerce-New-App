import 'package:taksh_e_commerce/features/home_service/data/models/service_booking_model.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_payment.dart';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

class ServiceBookingPaymentModel extends ServiceBookingPayment {
  const ServiceBookingPaymentModel({
    required super.razorpayOrderId,
    required super.amount,
    required super.amountInPaise,
    required super.currency,
    required super.razorpayKey,
    required super.gateway,
    required super.booking,
  });

  factory ServiceBookingPaymentModel.fromJson(Map<String, dynamic> json) {
    final bookingJson = json['booking'];
    final booking = bookingJson is Map
        ? ServiceBookingModel.fromJson(Map<String, dynamic>.from(bookingJson))
        : const ServiceBookingModel(
            id: 0,
            bookingNumber: '',
            status: '',
            paymentStatus: '',
            serviceId: 0,
            serviceName: '',
            serviceCharge: 0,
            currency: 'INR',
          );

    final amount = _asDouble(json['amount']);
    final amountInPaise = _asInt(json['amount_in_paise']);
    final currency = _asString(json['currency']);

    return ServiceBookingPaymentModel(
      razorpayOrderId: _asString(json['razorpay_order_id']),
      amount: amount,
      amountInPaise: amountInPaise != 0
          ? amountInPaise
          : (amount * 100).round(),
      currency: currency.isEmpty ? 'INR' : currency,
      razorpayKey: _asString(json['razorpay_key']),
      gateway: _asString(json['gateway']),
      booking: booking,
    );
  }
}
