import 'package:taksh_e_commerce/features/home_service/domain/entities/verify_service_booking_result.dart';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

class VerifyServiceBookingResultModel extends VerifyServiceBookingResult {
  const VerifyServiceBookingResultModel({
    required super.bookingId,
    required super.bookingNumber,
    required super.status,
    required super.paymentStatus,
  });

  factory VerifyServiceBookingResultModel.fromJson(Map<String, dynamic> json) {
    return VerifyServiceBookingResultModel(
      bookingId: _asInt(json['booking_id']),
      bookingNumber: _asString(json['booking_number']),
      status: _asString(json['status']),
      paymentStatus: _asString(json['payment_status']),
    );
  }
}
