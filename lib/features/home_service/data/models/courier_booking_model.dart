import 'package:taksh_e_commerce/features/home_service/data/models/courier_json.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking.dart';

class CourierPaymentOrderModel extends CourierPaymentOrder {
  const CourierPaymentOrderModel({
    required super.razorpayOrderId,
    required super.razorpayKey,
    required super.amountInPaise,
    required super.currency,
  });

  /// The `payment` object embedded in `POST /service/courier/bookings`
  /// (`amount` is in rupees there, `amount_in_paise` in paise).
  factory CourierPaymentOrderModel.fromBooking(Map<String, dynamic> json) {
    final paise = json['amount_in_paise'] != null
        ? cInt(json['amount_in_paise'])
        : (cDouble(json['amount']) * 100).round();
    return CourierPaymentOrderModel(
      razorpayOrderId: cStr(
        json['razorpay_order_id'] ?? json['payment_order_id'],
      ),
      razorpayKey: cStr(json['gateway_key']),
      amountInPaise: paise,
      currency: cStr(json['currency']).isEmpty ? 'INR' : cStr(json['currency']),
    );
  }

  /// `POST /service/courier/payment/create` (`amount` is in paise).
  factory CourierPaymentOrderModel.fromPaymentCreate(
    Map<String, dynamic> json,
  ) {
    final paise = json['amount'] != null && json['amount_in_rupees'] != null
        ? cInt(json['amount'])
        : (cDouble(json['amount_in_rupees']) * 100).round();
    return CourierPaymentOrderModel(
      razorpayOrderId: cStr(
        json['razorpay_order_id'] ?? json['payment_order_id'],
      ),
      razorpayKey: cStr(json['gateway_key']),
      amountInPaise: paise,
      currency: cStr(json['currency']).isEmpty ? 'INR' : cStr(json['currency']),
    );
  }
}

class CourierBookingModel extends CourierBooking {
  const CourierBookingModel({
    required super.bookingId,
    required super.bookingNumber,
    required super.courierName,
    required super.chargeableWeightGrams,
    required super.totalAmount,
    required super.status,
    required super.paymentStatus,
    super.courierRate,
    super.serviceCharge,
    super.estimatedDeliveryDays,
    super.payment,
  });

  factory CourierBookingModel.fromJson(Map<String, dynamic> json) {
    final pay = json['payment'];
    final payment = pay is Map
        ? CourierPaymentOrderModel.fromBooking(Map<String, dynamic>.from(pay))
        : null;
    return CourierBookingModel(
      bookingId: cInt(json['booking_id']),
      bookingNumber: cStr(json['booking_number']),
      courierName: cStr(json['courier_name'] ?? json['partner_name']),
      chargeableWeightGrams: cDouble(json['chargeable_weight_grams']),
      totalAmount: cDouble(json['total_amount']),
      courierRate: cNullDouble(json['shiprocket_rate']),
      serviceCharge: cNullDouble(json['service_charge']),
      estimatedDeliveryDays: cNullInt(json['estimated_delivery_days']),
      status: cStr(json['status']),
      paymentStatus: cStr(json['payment_status']),
      payment: (payment != null && payment.razorpayOrderId.isNotEmpty)
          ? payment
          : null,
    );
  }
}

class CourierPaymentResultModel extends CourierPaymentResult {
  const CourierPaymentResultModel({
    required super.bookingId,
    required super.status,
    required super.paymentStatus,
    required super.amount,
    required super.courierName,
    super.transactionId,
    super.awbCode,
  });

  factory CourierPaymentResultModel.fromJson(Map<String, dynamic> json) {
    final shipment = cMap(json['shipment']);
    return CourierPaymentResultModel(
      bookingId: cInt(json['courier_booking_id']),
      status: cStr(json['status']),
      paymentStatus: cStr(json['payment_status']),
      amount: cDouble(json['amount_in_rupees']),
      courierName: cStr(json['courier_name']),
      transactionId: cNullStr(json['transaction_id']),
      awbCode: cNullStr(shipment['awb_code']),
    );
  }
}
