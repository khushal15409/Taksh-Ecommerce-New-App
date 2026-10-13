import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';

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

String? _asNullableString(dynamic value) {
  final normalized = _asString(value);
  return normalized.isEmpty ? null : normalized;
}

DateTime? _asDate(dynamic value) {
  final raw = _asNullableString(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

double _refundAmount(dynamic refund) {
  if (refund is Map) {
    return _asDouble(refund['amount'] ?? refund['refund_amount']);
  }
  return 0;
}

ServiceBookingPaymentInfo? _paymentInfo(Map<String, dynamic> json) {
  return ServiceBookingPaymentInfo(
    paidAmount: _asDouble(json['paid_amount']),
    status: _asString(json['status']),
    paidAt: _asDate(json['paid_at']),
    refundAmount: _refundAmount(json['refund']),
  );
}

List<ServiceBookingTimelineEntry> _timeline(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map(
        (entry) => ServiceBookingTimelineEntry(
          status: _asString(entry['status']),
          title: _asString(entry['title']),
          reason: _asNullableString(entry['reason']),
          at: _asDate(entry['at']),
          actor: _asNullableString(entry['actor']),
        ),
      )
      .toList(growable: false);
}

class ServiceBookingModel extends ServiceBooking {
  const ServiceBookingModel({
    required super.id,
    required super.bookingNumber,
    required super.status,
    required super.paymentStatus,
    required super.serviceId,
    required super.serviceName,
    required super.serviceCharge,
    required super.currency,
    super.serviceImage,
    super.serviceShortDescription,
    super.paidAmount,
    super.pincode,
    super.scheduledFor,
    super.paidAt,
    super.createdAt,
    super.updatedAt,
    super.addressLine,
    super.addressLine2,
    super.landmark,
    super.city,
    super.state,
    super.customerName,
    super.customerMobile,
    super.providerName,
    super.providerStatus,
    super.cancellationReason,
    super.refundAmount,
    super.payment,
    super.timeline,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'];
    final service = serviceJson is Map
        ? Map<String, dynamic>.from(serviceJson)
        : const <String, dynamic>{};

    final addressJson = json['address'];
    final address = addressJson is Map
        ? Map<String, dynamic>.from(addressJson)
        : const <String, dynamic>{};

    final providerJson = json['provider'];
    final provider = providerJson is Map
        ? Map<String, dynamic>.from(providerJson)
        : null;

    final paymentJson = json['payment'];
    final payment = paymentJson is Map
        ? _paymentInfo(Map<String, dynamic>.from(paymentJson))
        : null;

    final cancellationJson = json['cancellation'];
    final cancellation = cancellationJson is Map
        ? Map<String, dynamic>.from(cancellationJson)
        : null;

    final topLevelPincode = _asString(json['pincode']);
    final pincode = topLevelPincode.isNotEmpty
        ? topLevelPincode
        : _asString(address['pincode']);

    final currency = _asString(json['currency']);

    final paidAmount = payment != null
        ? payment.paidAmount
        : _asDouble(json['paid_amount']);

    final refundAmount = _refundAmount(json['refund']) != 0
        ? _refundAmount(json['refund'])
        : (payment?.refundAmount ?? 0);

    return ServiceBookingModel(
      id: _asInt(json['id']),
      bookingNumber: _asString(json['booking_number']),
      status: _asString(json['status']),
      paymentStatus: _asString(json['payment_status']),
      serviceId: _asInt(service['id']),
      serviceName: _asString(service['name']),
      serviceImage: _asNullableString(service['image']),
      serviceShortDescription: _asNullableString(service['short_description']),
      serviceCharge: _asDouble(json['service_charge']),
      currency: currency.isEmpty ? 'INR' : currency,
      paidAmount: paidAmount,
      pincode: pincode,
      scheduledFor: _asDate(json['scheduled_for']),
      paidAt: _asDate(json['paid_at']),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
      addressLine: _asNullableString(
        address['line'] ?? address['address_line_1'],
      ),
      addressLine2: _asNullableString(address['address_line_2']),
      landmark: _asNullableString(address['landmark']),
      city: _asNullableString(address['city']),
      state: _asNullableString(address['state']),
      customerName: _asNullableString(address['name']),
      customerMobile: _asNullableString(address['mobile']),
      providerName: provider != null
          ? _asNullableString(provider['name'])
          : null,
      providerStatus: provider != null
          ? _asNullableString(provider['status'])
          : null,
      cancellationReason: cancellation != null
          ? _asNullableString(cancellation['reason'])
          : null,
      refundAmount: refundAmount,
      payment: payment,
      timeline: _timeline(json['timeline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_number': bookingNumber,
      'status': status,
      'payment_status': paymentStatus,
      'service': {
        'id': serviceId,
        'name': serviceName,
        if (serviceImage != null) 'image': serviceImage,
        if (serviceShortDescription != null)
          'short_description': serviceShortDescription,
      },
      'service_charge': serviceCharge,
      'currency': currency,
      'paid_amount': paidAmount,
      'pincode': pincode,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
