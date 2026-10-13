import 'package:dartz/dartz.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/data/datasources/home_service_remote_datasource.dart';
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
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Implementation of [HomeServiceRepository].
class HomeServiceRepositoryImpl implements HomeServiceRepository {
  final HomeServiceRemoteDataSource _remoteDataSource;

  HomeServiceRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<List<HomeService>> getServices() async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getServices',
    });

    try {
      log.infoWithContext('Getting services', {});
      final services = await _remoteDataSource.getServices();
      log.infoWithContext('Services retrieved successfully', {
        'count': services.length,
      });
      return Right(services);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting services',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting services',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting services',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  ResultFuture<List<CourierDeliveryPartner>>
  getCourierDeliveryPartners() async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getCourierDeliveryPartners',
    });

    try {
      log.infoWithContext('Getting courier delivery partners', {});
      final partners = await _remoteDataSource.getCourierDeliveryPartners();
      log.infoWithContext('Courier delivery partners retrieved successfully', {
        'count': partners.length,
      });
      return Right(partners);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting courier delivery partners',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting courier delivery partners',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting courier delivery partners',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get courier delivery partners: $e'));
    }
  }

  @override
  ResultFuture<CourierQuote> getCourierQuote({
    required double weightGrams,
    required double dimensionLength,
    required double dimensionHeight,
    required double dimensionWidth,
    required String dimensionUnit,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getCourierQuote',
    });

    try {
      log.infoWithContext('Getting courier quote', {
        'weight_grams': weightGrams,
        'dimension_unit': dimensionUnit,
      });
      final quote = await _remoteDataSource.getCourierQuote(
        weightGrams: weightGrams,
        dimensionLength: dimensionLength,
        dimensionHeight: dimensionHeight,
        dimensionWidth: dimensionWidth,
        dimensionUnit: dimensionUnit,
      );
      log.infoWithContext('Courier quote retrieved successfully', {
        'quotes_count': quote.quotes.length,
      });
      return Right(quote);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting courier quote',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting courier quote',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting courier quote',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get courier quote: $e'));
    }
  }

  @override
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
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'createCourierBooking',
    });

    try {
      log.infoWithContext('Creating courier booking', {
        'pickup_pincode': pickupPincode,
        'delivery_pincode': deliveryPincode,
        'courier_delivery_partner_id': courierDeliveryPartnerId,
      });

      final booking = await _remoteDataSource.createCourierBooking(
        customerName: customerName,
        customerMobile: customerMobile,
        pickupAddress: pickupAddress,
        pickupPincode: pickupPincode,
        deliveryName: deliveryName,
        deliveryMobile: deliveryMobile,
        deliveryAddress: deliveryAddress,
        deliveryPincode: deliveryPincode,
        productDetails: productDetails,
        packagingDetails: packagingDetails,
        weightGrams: weightGrams,
        dimensionLength: dimensionLength,
        dimensionHeight: dimensionHeight,
        dimensionWidth: dimensionWidth,
        dimensionUnit: dimensionUnit,
        courierDeliveryPartnerId: courierDeliveryPartnerId,
        customerNotes: customerNotes,
        itemPhotoPath: itemPhotoPath,
      );

      log.infoWithContext('Courier booking created successfully', {
        'booking_id': booking.bookingId,
        'booking_number': booking.bookingNumber,
      });

      return Right(booking);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception creating courier booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception creating courier booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error creating courier booking',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to create courier booking: $e'));
    }
  }

  @override
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
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'bookService',
    });

    try {
      log.infoWithContext('Booking service', {
        'service_id': serviceId,
        'pincode': pincode,
      });

      final payment = await _remoteDataSource.bookService(
        serviceId: serviceId,
        name: name,
        mobile: mobile,
        addressLine1: addressLine1,
        pincode: pincode,
        city: city,
        state: state,
        type: type,
        idempotencyKey: idempotencyKey,
        landmark: landmark,
        customerNotes: customerNotes,
      );

      log.infoWithContext('Service booking created successfully', {
        'booking_id': payment.booking.id,
        'booking_number': payment.booking.bookingNumber,
      });

      return Right(payment);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception booking service',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception booking service',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error booking service',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to book service: $e'));
    }
  }

  @override
  ResultFuture<VerifyServiceBookingResult> verifyServiceBooking({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'verifyServiceBooking',
    });

    try {
      log.infoWithContext('Verifying service booking payment', {
        'razorpay_order_id': razorpayOrderId,
      });

      final verified = await _remoteDataSource.verifyServiceBooking(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      log.infoWithContext('Service booking payment verified', {
        'booking_id': verified.bookingId,
        'payment_status': verified.paymentStatus,
      });

      return Right(verified);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception verifying service booking payment',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception verifying service booking payment',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error verifying service booking payment',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to verify payment: $e'));
    }
  }

  @override
  ResultFuture<ServiceBookingsPage> getServiceBookings({
    int page = 1,
    int perPage = 10,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getServiceBookings',
    });

    try {
      log.infoWithContext('Getting service bookings', {
        'page': page,
        'per_page': perPage,
      });

      final result = await _remoteDataSource.getServiceBookings(
        page: page,
        perPage: perPage,
      );

      log.infoWithContext('Service bookings retrieved successfully', {
        'count': result.bookings.length,
        'total': result.total,
      });

      return Right(result);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting service bookings',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting service bookings',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting service bookings',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get service bookings: $e'));
    }
  }

  @override
  ResultFuture<ServiceBooking> getServiceBookingDetail({
    required int bookingId,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getServiceBookingDetail',
    });

    try {
      log.infoWithContext('Getting service booking detail', {
        'booking_id': bookingId,
      });

      final booking = await _remoteDataSource.getServiceBookingDetail(
        bookingId: bookingId,
      );

      log.infoWithContext('Service booking detail retrieved successfully', {
        'booking_id': booking.id,
      });

      return Right(booking);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting service booking detail',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting service booking detail',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting service booking detail',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get booking detail: $e'));
    }
  }

  @override
  ResultFuture<ServiceBookingCancelResult> cancelServiceBooking({
    required int bookingId,
    String? reason,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'cancelServiceBooking',
    });

    try {
      log.infoWithContext('Cancelling service booking', {
        'booking_id': bookingId,
      });

      final result = await _remoteDataSource.cancelServiceBooking(
        bookingId: bookingId,
        reason: reason,
      );

      log.infoWithContext('Service booking cancelled successfully', {
        'booking_id': result.bookingId,
        'status': result.status,
      });

      return Right(result);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception cancelling service booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception cancelling service booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error cancelling service booking',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to cancel booking: $e'));
    }
  }

  @override
  ResultFuture<List<ServiceInquiry>> getServiceInquiryHistory({
    int? serviceId,
    String? status,
    String? paymentStatus,
    int perPage = 15,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRepositoryImpl',
      'method': 'getServiceInquiryHistory',
    });

    try {
      log.infoWithContext('Getting service inquiry history', {
        'service_id': serviceId,
        'status': status,
        'payment_status': paymentStatus,
        'per_page': perPage,
      });
      final orders = await _remoteDataSource.getServiceInquiryHistory(
        serviceId: serviceId,
        status: status,
        paymentStatus: paymentStatus,
        perPage: perPage,
      );
      log.infoWithContext('Service inquiry history retrieved successfully', {
        'count': orders.length,
      });
      return Right(orders);
    } on ServerException catch (e, stackTrace) {
      log.errorWithContext(
        'Server exception getting service inquiry history',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      log.errorWithContext(
        'Network exception getting service inquiry history',
        {'message': e.message},
        e,
        stackTrace,
      );
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      log.errorWithContext(
        'Unexpected error getting service inquiry history',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to get service inquiry history: $e'));
    }
  }
}
