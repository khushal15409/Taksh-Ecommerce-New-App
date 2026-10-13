import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_delivery_partner.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_quote.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/home_service.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_cancel_result.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_payment.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_bookings_page.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_inquiry.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/verify_service_booking_result.dart';

/// Repository contract for the Home Service feature.
abstract class HomeServiceRepository {
  /// Fetches all available home services.
  ResultFuture<List<HomeService>> getServices();

  /// Fetches the delivery partners available for courier bookings.
  ResultFuture<List<CourierDeliveryPartner>> getCourierDeliveryPartners();

  /// Computes courier quotes for the current parcel dimensions and weight.
  ResultFuture<CourierQuote> getCourierQuote({
    required double weightGrams,
    required double dimensionLength,
    required double dimensionHeight,
    required double dimensionWidth,
    required String dimensionUnit,
  });

  /// Creates a courier booking.
  ResultFuture<CourierBooking> createCourierBooking({
    required String customerName,
    required String customerMobile,
    required String pickupAddress,
    required String pickupPincode,
    required String deliveryName,
    required String deliveryMobile,
    required String deliveryAddress,
    required String deliveryPincode,
    required String productDetails,
    required String packagingDetails,
    required double weightGrams,
    required double dimensionLength,
    required double dimensionHeight,
    required double dimensionWidth,
    required String dimensionUnit,
    required int courierDeliveryPartnerId,
    String? customerNotes,
    String? itemPhotoPath,
  });

  /// Books a marketplace service (electrician, plumber, salon) and creates
  /// the associated Razorpay payment order.
  ResultFuture<ServiceBookingPayment> bookService({
    required int serviceId,
    required String name,
    required String mobile,
    required String addressLine1,
    required String pincode,
    required String city,
    required String state,
    required String type,
    required String idempotencyKey,
    String? landmark,
    String? customerNotes,
  });

  /// Verifies a marketplace service booking payment signature.
  ResultFuture<VerifyServiceBookingResult> verifyServiceBooking({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Fetches the paginated list of marketplace service bookings.
  ResultFuture<ServiceBookingsPage> getServiceBookings({
    int page = 1,
    int perPage = 10,
  });

  /// Fetches a single marketplace service booking.
  ResultFuture<ServiceBooking> getServiceBookingDetail({
    required int bookingId,
  });

  /// Cancels a marketplace service booking.
  ResultFuture<ServiceBookingCancelResult> cancelServiceBooking({
    required int bookingId,
    String? reason,
  });

  /// Fetches the order / inquiry history for the current user.
  ResultFuture<List<ServiceInquiry>> getServiceInquiryHistory({
    int? serviceId,
    String? status,
    String? paymentStatus,
    int perPage = 15,
  });
}
