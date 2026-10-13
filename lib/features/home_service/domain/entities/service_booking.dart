import 'package:equatable/equatable.dart';

/// A single entry in a service booking's status timeline.
class ServiceBookingTimelineEntry extends Equatable {
  final String status;
  final String title;
  final String? reason;
  final DateTime? at;
  final String? actor;

  const ServiceBookingTimelineEntry({
    required this.status,
    required this.title,
    this.reason,
    this.at,
    this.actor,
  });

  @override
  List<Object?> get props => [status, title, reason, at, actor];
}

/// Payment information attached to a service booking detail.
class ServiceBookingPaymentInfo extends Equatable {
  final double paidAmount;
  final String status;
  final DateTime? paidAt;
  final double refundAmount;

  const ServiceBookingPaymentInfo({
    required this.paidAmount,
    required this.status,
    this.paidAt,
    this.refundAmount = 0,
  });

  bool get isPaid => status.toLowerCase() == 'paid';

  @override
  List<Object?> get props => [paidAmount, status, paidAt, refundAmount];
}

/// Represents a marketplace home-service booking.
///
/// Used for the `POST /service/book` response (nested under the payment
/// order) as well as the `GET /service/book` list and detail responses.
class ServiceBooking extends Equatable {
  final int id;
  final String bookingNumber;
  final String status;
  final String paymentStatus;
  final int serviceId;
  final String serviceName;
  final String? serviceImage;
  final String? serviceShortDescription;
  final double serviceCharge;
  final String currency;
  final double paidAmount;
  final String pincode;
  final DateTime? scheduledFor;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Address
  final String? addressLine;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? customerName;
  final String? customerMobile;

  // Assigned provider
  final String? providerName;
  final String? providerStatus;

  // Cancellation / refund
  final String? cancellationReason;
  final double refundAmount;

  // Detail extras
  final ServiceBookingPaymentInfo? payment;
  final List<ServiceBookingTimelineEntry> timeline;

  const ServiceBooking({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.paymentStatus,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCharge,
    required this.currency,
    this.serviceImage,
    this.serviceShortDescription,
    this.paidAmount = 0,
    this.pincode = '',
    this.scheduledFor,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
    this.addressLine,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.customerName,
    this.customerMobile,
    this.providerName,
    this.providerStatus,
    this.cancellationReason,
    this.refundAmount = 0,
    this.payment,
    this.timeline = const [],
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Amount actually paid, preferring the detailed payment block.
  double get effectivePaidAmount => payment?.paidAmount ?? paidAmount;

  @override
  List<Object?> get props => [
    id,
    bookingNumber,
    status,
    paymentStatus,
    serviceId,
    serviceName,
    serviceImage,
    serviceShortDescription,
    serviceCharge,
    currency,
    paidAmount,
    pincode,
    scheduledFor,
    paidAt,
    createdAt,
    updatedAt,
    addressLine,
    addressLine2,
    landmark,
    city,
    state,
    customerName,
    customerMobile,
    providerName,
    providerStatus,
    cancellationReason,
    refundAmount,
    payment,
    timeline,
  ];
}
