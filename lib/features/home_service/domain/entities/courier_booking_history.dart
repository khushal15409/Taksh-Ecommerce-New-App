import 'package:equatable/equatable.dart';

/// Row of `GET /service/courier/bookings`.
class CourierBookingSummary extends Equatable {
  final int id;
  final String bookingNumber;
  final String status;
  final String paymentStatus;
  final String customerName;
  final String pickupPincode;
  final String deliveryPincode;
  final double totalAmount;
  final String courierName;
  final String? awbCode;
  final String? shipmentStatus;
  final String? shipmentStatusLabel;
  final DateTime? createdAt;

  const CourierBookingSummary({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.paymentStatus,
    required this.customerName,
    required this.pickupPincode,
    required this.deliveryPincode,
    required this.totalAmount,
    required this.courierName,
    this.awbCode,
    this.shipmentStatus,
    this.shipmentStatusLabel,
    this.createdAt,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  @override
  List<Object?> get props => [
    id,
    bookingNumber,
    status,
    paymentStatus,
    customerName,
    pickupPincode,
    deliveryPincode,
    totalAmount,
    courierName,
    awbCode,
    shipmentStatus,
    shipmentStatusLabel,
    createdAt,
  ];
}

class CourierBookingsPage extends Equatable {
  final List<CourierBookingSummary> bookings;
  final int currentPage;
  final int lastPage;
  final int total;

  const CourierBookingsPage({
    required this.bookings,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  @override
  List<Object?> get props => [bookings, currentPage, lastPage, total];
}

class CourierTrackingEvent extends Equatable {
  final String title;
  final String? description;
  final String? location;
  final DateTime? eventTime;

  const CourierTrackingEvent({
    required this.title,
    this.description,
    this.location,
    this.eventTime,
  });

  @override
  List<Object?> get props => [title, description, location, eventTime];
}

/// `GET /service/courier/bookings/{id}`.
class CourierBookingDetail extends Equatable {
  final int id;
  final String bookingNumber;
  final String status;
  final String paymentStatus;
  final String customerName;
  final String customerMobile;
  final String pickupAddress;
  final String pickupPincode;
  final String deliveryName;
  final String deliveryMobile;
  final String deliveryAddress;
  final String deliveryPincode;
  final double weightGrams;
  final double chargeableWeightGrams;
  final String dimensionUnit;
  final double length;
  final double width;
  final double height;
  final String? productDetails;
  final String? packagingDetails;
  final String? customerNotes;
  final String? itemPhotoPath;
  final String courierName;
  final String? awbCode;
  final String? trackingUrl;
  final int? estimatedDeliveryDays;
  final String? shipmentStatus;
  final String? shipmentStatusLabel;
  final double totalAmount;
  final double? courierRate;
  final double? serviceCharge;
  final double? paidAmount;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? refundStatus;
  final double? refundAmount;
  final List<CourierTrackingEvent> timeline;

  const CourierBookingDetail({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.paymentStatus,
    required this.customerName,
    required this.customerMobile,
    required this.pickupAddress,
    required this.pickupPincode,
    required this.deliveryName,
    required this.deliveryMobile,
    required this.deliveryAddress,
    required this.deliveryPincode,
    required this.weightGrams,
    required this.chargeableWeightGrams,
    required this.dimensionUnit,
    required this.length,
    required this.width,
    required this.height,
    required this.courierName,
    required this.totalAmount,
    required this.timeline,
    this.productDetails,
    this.packagingDetails,
    this.customerNotes,
    this.itemPhotoPath,
    this.awbCode,
    this.trackingUrl,
    this.estimatedDeliveryDays,
    this.shipmentStatus,
    this.shipmentStatusLabel,
    this.courierRate,
    this.serviceCharge,
    this.paidAmount,
    this.paidAt,
    this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.refundStatus,
    this.refundAmount,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  @override
  List<Object?> get props => [
    id,
    bookingNumber,
    status,
    paymentStatus,
    shipmentStatus,
    awbCode,
    refundStatus,
    timeline,
  ];
}

class CourierCancelResult extends Equatable {
  final String message;
  final String? refundStatus;
  final double? refundAmount;

  const CourierCancelResult({
    required this.message,
    this.refundStatus,
    this.refundAmount,
  });

  @override
  List<Object?> get props => [message, refundStatus, refundAmount];
}
