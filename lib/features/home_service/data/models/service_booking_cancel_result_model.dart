import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_cancel_result.dart';

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

class ServiceBookingCancelResultModel extends ServiceBookingCancelResult {
  const ServiceBookingCancelResultModel({
    required super.bookingId,
    required super.bookingNumber,
    required super.status,
    required super.refundAmount,
    required super.refundStatus,
  });

  factory ServiceBookingCancelResultModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingCancelResultModel(
      bookingId: _asInt(json['booking_id']),
      bookingNumber: _asString(json['booking_number']),
      status: _asString(json['status']),
      refundAmount: _asDouble(json['refund_amount']),
      refundStatus: _asString(json['refund_status']),
    );
  }
}
