import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking_history.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_quote.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

// ─── Quote ─────────────────────────────────────────────────────────────────

class GetCourierQuote implements UseCase<CourierQuote, GetCourierQuoteParams> {
  final HomeServiceRepository repository;

  const GetCourierQuote(this.repository);

  @override
  ResultFuture<CourierQuote> call(GetCourierQuoteParams p) {
    return repository.getCourierQuote(
      pickupPincode: p.pickupPincode,
      deliveryPincode: p.deliveryPincode,
      weightGrams: p.weightGrams,
      dimensionLength: p.dimensionLength,
      dimensionHeight: p.dimensionHeight,
      dimensionWidth: p.dimensionWidth,
      dimensionUnit: p.dimensionUnit,
    );
  }
}

class GetCourierQuoteParams extends Equatable {
  final String pickupPincode;
  final String deliveryPincode;
  final double weightGrams;
  final double dimensionLength;
  final double dimensionHeight;
  final double dimensionWidth;
  final String dimensionUnit;

  const GetCourierQuoteParams({
    required this.pickupPincode,
    required this.deliveryPincode,
    required this.weightGrams,
    required this.dimensionLength,
    required this.dimensionHeight,
    required this.dimensionWidth,
    required this.dimensionUnit,
  });

  @override
  List<Object?> get props => [
    pickupPincode,
    deliveryPincode,
    weightGrams,
    dimensionLength,
    dimensionHeight,
    dimensionWidth,
    dimensionUnit,
  ];
}

// ─── Create booking ────────────────────────────────────────────────────────

class CreateCourierBooking
    implements UseCase<CourierBooking, CreateCourierBookingParams> {
  final HomeServiceRepository repository;

  const CreateCourierBooking(this.repository);

  @override
  ResultFuture<CourierBooking> call(CreateCourierBookingParams p) {
    return repository.createCourierBooking(
      customerName: p.customerName,
      customerMobile: p.customerMobile,
      pickupAddress: p.pickupAddress,
      pickupPincode: p.pickupPincode,
      deliveryName: p.deliveryName,
      deliveryMobile: p.deliveryMobile,
      deliveryAddress: p.deliveryAddress,
      deliveryPincode: p.deliveryPincode,
      productDetails: p.productDetails,
      packagingDetails: p.packagingDetails,
      weightGrams: p.weightGrams,
      dimensionLength: p.dimensionLength,
      dimensionHeight: p.dimensionHeight,
      dimensionWidth: p.dimensionWidth,
      dimensionUnit: p.dimensionUnit,
      courierCompanyId: p.courierCompanyId,
      quotedRate: p.quotedRate,
      customerNotes: p.customerNotes,
      itemPhotoPath: p.itemPhotoPath,
    );
  }
}

class CreateCourierBookingParams extends Equatable {
  final String customerName;
  final String customerMobile;
  final String pickupAddress;
  final String pickupPincode;
  final String deliveryName;
  final String deliveryMobile;
  final String deliveryAddress;
  final String deliveryPincode;
  final String productDetails;
  final String packagingDetails;
  final double weightGrams;
  final double dimensionLength;
  final double dimensionHeight;
  final double dimensionWidth;
  final String dimensionUnit;
  final String courierCompanyId;
  final double? quotedRate;
  final String? customerNotes;
  final String? itemPhotoPath;

  const CreateCourierBookingParams({
    required this.customerName,
    required this.customerMobile,
    required this.pickupAddress,
    required this.pickupPincode,
    required this.deliveryName,
    required this.deliveryMobile,
    required this.deliveryAddress,
    required this.deliveryPincode,
    required this.productDetails,
    required this.packagingDetails,
    required this.weightGrams,
    required this.dimensionLength,
    required this.dimensionHeight,
    required this.dimensionWidth,
    required this.dimensionUnit,
    required this.courierCompanyId,
    this.quotedRate,
    this.customerNotes,
    this.itemPhotoPath,
  });

  @override
  List<Object?> get props => [
    customerName,
    customerMobile,
    pickupAddress,
    pickupPincode,
    deliveryName,
    deliveryMobile,
    deliveryAddress,
    deliveryPincode,
    productDetails,
    packagingDetails,
    weightGrams,
    dimensionLength,
    dimensionHeight,
    dimensionWidth,
    dimensionUnit,
    courierCompanyId,
    quotedRate,
    customerNotes,
    itemPhotoPath,
  ];
}

// ─── Payment ───────────────────────────────────────────────────────────────

class CreateCourierPayment implements UseCase<CourierPaymentOrder, int> {
  final HomeServiceRepository repository;

  const CreateCourierPayment(this.repository);

  @override
  ResultFuture<CourierPaymentOrder> call(int bookingId) =>
      repository.createCourierPayment(bookingId: bookingId);
}

class VerifyCourierPayment
    implements UseCase<CourierPaymentResult, VerifyCourierPaymentParams> {
  final HomeServiceRepository repository;

  const VerifyCourierPayment(this.repository);

  @override
  ResultFuture<CourierPaymentResult> call(VerifyCourierPaymentParams p) {
    return repository.verifyCourierPayment(
      bookingId: p.bookingId,
      razorpayOrderId: p.razorpayOrderId,
      razorpayPaymentId: p.razorpayPaymentId,
      razorpaySignature: p.razorpaySignature,
    );
  }
}

class VerifyCourierPaymentParams extends Equatable {
  final int bookingId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyCourierPaymentParams({
    required this.bookingId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object?> get props => [
    bookingId,
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature,
  ];
}

// ─── History / detail / cancel ─────────────────────────────────────────────

class GetCourierBookings
    implements UseCase<CourierBookingsPage, GetCourierBookingsParams> {
  final HomeServiceRepository repository;

  const GetCourierBookings(this.repository);

  @override
  ResultFuture<CourierBookingsPage> call(GetCourierBookingsParams p) =>
      repository.getCourierBookings(page: p.page, perPage: p.perPage);
}

class GetCourierBookingsParams extends Equatable {
  final int page;
  final int perPage;

  const GetCourierBookingsParams({this.page = 1, this.perPage = 15});

  @override
  List<Object?> get props => [page, perPage];
}

class GetCourierBookingDetail implements UseCase<CourierBookingDetail, int> {
  final HomeServiceRepository repository;

  const GetCourierBookingDetail(this.repository);

  @override
  ResultFuture<CourierBookingDetail> call(int bookingId) =>
      repository.getCourierBookingDetail(bookingId: bookingId);
}

class CancelCourierBooking
    implements UseCase<CourierCancelResult, CancelCourierBookingParams> {
  final HomeServiceRepository repository;

  const CancelCourierBooking(this.repository);

  @override
  ResultFuture<CourierCancelResult> call(CancelCourierBookingParams p) =>
      repository.cancelCourierBooking(bookingId: p.bookingId, reason: p.reason);
}

class CancelCourierBookingParams extends Equatable {
  final int bookingId;
  final String? reason;

  const CancelCourierBookingParams({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}

// ─── Invoice ───────────────────────────────────────────────────────────────

class DownloadServiceInvoice
    implements UseCase<String, DownloadServiceInvoiceParams> {
  final HomeServiceRepository repository;

  const DownloadServiceInvoice(this.repository);

  @override
  ResultFuture<String> call(DownloadServiceInvoiceParams p) {
    return repository.downloadInvoice(
      path: p.path,
      fileName: p.fileName,
      onProgress: p.onProgress,
    );
  }
}

class DownloadServiceInvoiceParams {
  final String path;
  final String fileName;
  final void Function(double progress)? onProgress;

  const DownloadServiceInvoiceParams({
    required this.path,
    required this.fileName,
    this.onProgress,
  });
}
