import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/courier_booking_history_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/courier_booking_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/courier_json.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/courier_delivery_partner_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/courier_quote_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/home_service_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/service_booking_cancel_result_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/service_booking_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/service_booking_payment_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/service_bookings_page_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/service_inquiry_model.dart';
import 'package:taksh_e_commerce/features/home_service/data/models/verify_service_booking_result_model.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking_history.dart';

/// Remote data source contract for home service feature.
abstract class HomeServiceRemoteDataSource {
  /// Fetch all available services.
  Future<List<HomeServiceModel>> getServices();

  /// Fetch courier delivery partners.
  Future<List<CourierDeliveryPartnerModel>> getCourierDeliveryPartners();

  /// Live courier options and rates between two pincodes (creates nothing).
  Future<CourierQuoteModel> getCourierQuote({
    required String pickupPincode,
    required String deliveryPincode,
    required double weightGrams,
    required double dimensionLength,
    required double dimensionHeight,
    required double dimensionWidth,
    required String dimensionUnit,
  });

  /// Create a courier booking (and its Razorpay order).
  Future<CourierBookingModel> createCourierBooking({
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
    required String courierCompanyId,
    double? quotedRate,
    String? customerNotes,
    String? itemPhotoPath,
  });

  /// Create (or reuse) the Razorpay order of an unpaid courier booking.
  Future<CourierPaymentOrderModel> createCourierPayment({
    required int bookingId,
  });

  /// Verify the Razorpay signature of a courier booking payment.
  Future<CourierPaymentResultModel> verifyCourierPayment({
    required int bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Paginated courier booking history.
  Future<CourierBookingsPage> getCourierBookings({
    int page = 1,
    int perPage = 15,
  });

  /// Single courier booking with tracking timeline.
  Future<CourierBookingDetail> getCourierBookingDetail({
    required int bookingId,
  });

  /// Cancel a courier booking.
  Future<CourierCancelResult> cancelCourierBooking({
    required int bookingId,
    String? reason,
  });

  /// Downloads the invoice PDF of a paid booking to [savePath].
  /// [path] is the API path, e.g. `/service/book/12/invoice`.
  Future<String> downloadInvoice({
    required String path,
    required String savePath,
    void Function(double progress)? onProgress,
  });

  /// Books a marketplace service and creates the Razorpay payment order.
  Future<ServiceBookingPaymentModel> bookService({
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
  Future<VerifyServiceBookingResultModel> verifyServiceBooking({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Fetch the paginated list of marketplace service bookings.
  Future<ServiceBookingsPageModel> getServiceBookings({
    int page = 1,
    int perPage = 10,
  });

  /// Fetch a single marketplace service booking.
  Future<ServiceBookingModel> getServiceBookingDetail({required int bookingId});

  /// Cancel a marketplace service booking.
  Future<ServiceBookingCancelResultModel> cancelServiceBooking({
    required int bookingId,
    String? reason,
  });

  /// Fetch service inquiry / order history.
  Future<List<ServiceInquiryModel>> getServiceInquiryHistory({
    int? serviceId,
    String? status,
    String? paymentStatus,
    int perPage = 15,
  });
}

/// Implementation of [HomeServiceRemoteDataSource].
class HomeServiceRemoteDataSourceImpl implements HomeServiceRemoteDataSource {
  final ApiClient _apiClient;

  HomeServiceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<HomeServiceModel>> getServices() async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'getServices',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Fetching available services', {});

      final response = await _apiClient.get(ApiConstants.services);

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to fetch services',
        );
      }

      final servicesList = data['data'] as List<dynamic>;
      final services = servicesList
          .map((e) => HomeServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      log.infoWithContext('Services fetched successfully', {
        'count': services.length,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return services;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException fetching services',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to fetch services',
        e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error fetching services',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to fetch services: $e');
    }
  }

  @override
  Future<List<CourierDeliveryPartnerModel>> getCourierDeliveryPartners() async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'getCourierDeliveryPartners',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Fetching courier delivery partners', {});

      final response = await _apiClient.get(
        ApiConstants.courierDeliveryPartners,
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ??
              'Failed to fetch courier delivery partners',
        );
      }

      final payload = data['data'] as Map<String, dynamic>? ?? const {};
      final partnersList = payload['partners'] as List<dynamic>? ?? const [];
      final partners = partnersList
          .map(
            (partner) => CourierDeliveryPartnerModel.fromJson(
              Map<String, dynamic>.from(partner as Map),
            ),
          )
          .toList(growable: false);

      log.infoWithContext('Courier delivery partners fetched successfully', {
        'count': partners.length,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return partners;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException fetching courier delivery partners',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to fetch courier delivery partners',
        e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error fetching courier delivery partners',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to fetch courier delivery partners: $e');
    }
  }

  /// Runs [fn] and maps every failure to a [ServerException] / [NetworkException]
  /// carrying a customer-readable message.
  Future<T> _guard<T>(String fallback, Future<T> Function() fn) async {
    try {
      return await fn();
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } on AppException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? fallback,
        e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      loggerWithContext({
        'feature': 'home_service',
        'class': 'HomeServiceRemoteDataSourceImpl',
      }).errorWithContext(fallback, {'error': e.toString()}, e, stackTrace);
      throw ServerException(fallback);
    }
  }

  Map<String, dynamic> _unwrap(dynamic body, String fallback) {
    final data = body as Map<String, dynamic>;
    if (!(data['success'] as bool? ?? false)) {
      throw ServerException(data['message'] as String? ?? fallback);
    }
    return cMap(data['data']);
  }

  @override
  Future<CourierQuoteModel> getCourierQuote({
    required String pickupPincode,
    required String deliveryPincode,
    required double weightGrams,
    required double dimensionLength,
    required double dimensionHeight,
    required double dimensionWidth,
    required String dimensionUnit,
  }) {
    const fallback = 'Failed to fetch courier rates';
    return _guard(fallback, () async {
      final response = await _apiClient.post(
        ApiConstants.courierQuote,
        data: FormData.fromMap({
          'pickup_pincode': pickupPincode,
          'delivery_pincode': deliveryPincode,
          'weight_grams': weightGrams.round().toString(),
          'dimension_unit': dimensionUnit,
          'length': dimensionLength.toString(),
          'width': dimensionWidth.toString(),
          'height': dimensionHeight.toString(),
        }),
      );
      return CourierQuoteModel.fromJson(_unwrap(response.data, fallback));
    });
  }

  @override
  Future<CourierBookingModel> createCourierBooking({
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
    required String courierCompanyId,
    double? quotedRate,
    String? customerNotes,
    String? itemPhotoPath,
  }) {
    const fallback = 'Failed to create courier booking';
    return _guard(fallback, () async {
      final formMap = <String, dynamic>{
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'pickup_address': pickupAddress,
        'pickup_pincode': pickupPincode,
        'delivery_name': deliveryName,
        'delivery_mobile': deliveryMobile,
        'delivery_address': deliveryAddress,
        'delivery_pincode': deliveryPincode,
        'product_details': productDetails,
        'packaging_details': packagingDetails,
        'weight_grams': weightGrams.round().toString(),
        'dimension_unit': dimensionUnit,
        'length': dimensionLength.toString(),
        'width': dimensionWidth.toString(),
        'height': dimensionHeight.toString(),
        'shiprocket_courier_company_id': courierCompanyId,
      };
      if (quotedRate != null) formMap['quoted_rate'] = quotedRate.toString();
      if (customerNotes != null && customerNotes.isNotEmpty) {
        formMap['customer_notes'] = customerNotes;
      }
      if (itemPhotoPath != null && itemPhotoPath.isNotEmpty) {
        formMap['item_photo'] = await MultipartFile.fromFile(
          itemPhotoPath,
          filename: itemPhotoPath.split('/').last,
        );
      }

      final response = await _apiClient.post(
        ApiConstants.courierBookings,
        data: FormData.fromMap(formMap),
      );
      return CourierBookingModel.fromJson(_unwrap(response.data, fallback));
    });
  }

  @override
  Future<CourierPaymentOrderModel> createCourierPayment({
    required int bookingId,
  }) {
    const fallback = 'Failed to start payment';
    return _guard(fallback, () async {
      final response = await _apiClient.post(
        ApiConstants.courierPaymentCreate,
        data: {'courier_booking_id': bookingId},
      );
      return CourierPaymentOrderModel.fromPaymentCreate(
        _unwrap(response.data, fallback),
      );
    });
  }

  @override
  Future<CourierPaymentResultModel> verifyCourierPayment({
    required int bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    const fallback = 'Failed to verify payment';
    return _guard(fallback, () async {
      final response = await _apiClient.post(
        ApiConstants.courierPaymentVerify,
        data: {
          'courier_booking_id': bookingId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      return CourierPaymentResultModel.fromJson(
        _unwrap(response.data, fallback),
      );
    });
  }

  @override
  Future<CourierBookingsPage> getCourierBookings({
    int page = 1,
    int perPage = 15,
  }) {
    const fallback = 'Failed to fetch courier bookings';
    return _guard(fallback, () async {
      final response = await _apiClient.get(
        ApiConstants.courierBookings,
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return courierPageFromJson(_unwrap(response.data, fallback));
    });
  }

  @override
  Future<CourierBookingDetail> getCourierBookingDetail({
    required int bookingId,
  }) {
    const fallback = 'Failed to fetch booking details';
    return _guard(fallback, () async {
      final response = await _apiClient.get(
        ApiConstants.courierBookingDetail(bookingId),
      );
      return courierDetailFromJson(_unwrap(response.data, fallback));
    });
  }

  @override
  Future<CourierCancelResult> cancelCourierBooking({
    required int bookingId,
    String? reason,
  }) {
    const fallback = 'Failed to cancel booking';
    return _guard(fallback, () async {
      final trimmed = reason?.trim();
      final response = await _apiClient.post(
        ApiConstants.courierBookingCancel(bookingId),
        data: {if (trimmed != null && trimmed.isNotEmpty) 'reason': trimmed},
      );
      return courierCancelFromJson(_unwrap(response.data, fallback));
    });
  }

  @override
  Future<String> downloadInvoice({
    required String path,
    required String savePath,
    void Function(double progress)? onProgress,
  }) {
    const fallback = 'Failed to download invoice';
    return _guard(fallback, () async {
      final base = _apiClient.baseUrl.endsWith('/')
          ? _apiClient.baseUrl.substring(0, _apiClient.baseUrl.length - 1)
          : _apiClient.baseUrl;
      // Dedicated Dio: binary response, no JSON Accept header.
      final dio = Dio(
        BaseOptions(
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: const Duration(seconds: 120),
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
          headers: {'Accept': 'application/pdf, application/json'},
        ),
      );
      final token = await _apiClient.authToken;
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.get<List<int>>(
        '$base$path',
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call((received / total).clamp(0.0, 1.0));
        },
      );
      final bytes = response.data ?? const <int>[];
      final isPdf =
          bytes.length > 5 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
      if (response.statusCode != 200 || !isPdf) {
        var message = fallback;
        try {
          final decoded = jsonDecode(utf8.decode(bytes));
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'] as String;
          }
        } catch (_) {}
        throw ServerException(message, response.statusCode);
      }
      await File(savePath).writeAsBytes(bytes, flush: true);
      onProgress?.call(1);
      return savePath;
    });
  }

  @override
  Future<ServiceBookingPaymentModel> bookService({
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
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'bookService',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Creating service booking', {
        'service_id': serviceId,
        'pincode': pincode,
        'type': type,
      });

      final body = <String, dynamic>{
        'service_id': serviceId.toString(),
        'name': name,
        'mobile': mobile,
        'address_line_1': addressLine1,
        'pincode': pincode,
        'city': city,
        'state': state,
        'type': type,
        'idempotency_key': idempotencyKey,
      };

      final normalizedLandmark = landmark?.trim();
      if (normalizedLandmark != null && normalizedLandmark.isNotEmpty) {
        body['landmark'] = normalizedLandmark;
      }

      final normalizedCustomerNotes = customerNotes?.trim();
      if (normalizedCustomerNotes != null &&
          normalizedCustomerNotes.isNotEmpty) {
        body['customer_notes'] = normalizedCustomerNotes;
      }

      final response = await _apiClient.post(
        ApiConstants.serviceBook,
        data: body,
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to create service booking',
        );
      }

      final payment = ServiceBookingPaymentModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );

      log.infoWithContext('Service booking created successfully', {
        'booking_id': payment.booking.id,
        'booking_number': payment.booking.bookingNumber,
        'amount_in_paise': payment.amountInPaise,
        'has_payment_order': payment.isPayable,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return payment;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException creating service booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to create service booking',
        e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on AppException catch (e, stackTrace) {
      log.errorWithContext(
        'API error creating service booking',
        {'message': e.message, 'status_code': e.statusCode},
        e,
        stackTrace,
      );
      throw ServerException(e.message, e.statusCode);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error creating service booking',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to create service booking: $e');
    }
  }

  @override
  Future<VerifyServiceBookingResultModel> verifyServiceBooking({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'verifyServiceBooking',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Verifying service booking payment', {
        'razorpay_order_id': razorpayOrderId,
      });

      final response = await _apiClient.post(
        ApiConstants.serviceBookVerify,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to verify payment',
        );
      }

      final verified = VerifyServiceBookingResultModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );

      log.infoWithContext('Service booking payment verified', {
        'booking_id': verified.bookingId,
        'payment_status': verified.paymentStatus,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return verified;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException verifying service booking payment',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to verify payment',
        e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on AppException catch (e, stackTrace) {
      log.errorWithContext(
        'API error verifying service booking payment',
        {'message': e.message, 'status_code': e.statusCode},
        e,
        stackTrace,
      );
      throw ServerException(e.message, e.statusCode);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error verifying service booking payment',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to verify payment: $e');
    }
  }

  @override
  Future<ServiceBookingsPageModel> getServiceBookings({
    int page = 1,
    int perPage = 10,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'getServiceBookings',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Fetching service bookings', {
        'page': page,
        'per_page': perPage,
      });

      final response = await _apiClient.get(
        ApiConstants.serviceBook,
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to fetch service bookings',
        );
      }

      final pageModel = ServiceBookingsPageModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );

      log.infoWithContext('Service bookings fetched successfully', {
        'count': pageModel.bookings.length,
        'total': pageModel.total,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return pageModel;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException fetching service bookings',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to fetch service bookings',
        e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on AppException catch (e, stackTrace) {
      log.errorWithContext(
        'API error fetching service bookings',
        {'message': e.message, 'status_code': e.statusCode},
        e,
        stackTrace,
      );
      throw ServerException(e.message, e.statusCode);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error fetching service bookings',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to fetch service bookings: $e');
    }
  }

  @override
  Future<ServiceBookingModel> getServiceBookingDetail({
    required int bookingId,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'getServiceBookingDetail',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Fetching service booking detail', {
        'booking_id': bookingId,
      });

      final response = await _apiClient.get(
        ApiConstants.serviceBookDetail(bookingId),
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to fetch booking detail',
        );
      }

      final booking = ServiceBookingModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );

      log.infoWithContext('Service booking detail fetched successfully', {
        'booking_id': booking.id,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return booking;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException fetching service booking detail',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to fetch booking detail',
        e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on AppException catch (e, stackTrace) {
      log.errorWithContext(
        'API error fetching service booking detail',
        {'message': e.message, 'status_code': e.statusCode},
        e,
        stackTrace,
      );
      throw ServerException(e.message, e.statusCode);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error fetching service booking detail',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to fetch booking detail: $e');
    }
  }

  @override
  Future<ServiceBookingCancelResultModel> cancelServiceBooking({
    required int bookingId,
    String? reason,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'cancelServiceBooking',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Cancelling service booking', {
        'booking_id': bookingId,
      });

      final body = <String, dynamic>{};
      final normalizedReason = reason?.trim();
      if (normalizedReason != null && normalizedReason.isNotEmpty) {
        body['reason'] = normalizedReason;
      }

      final response = await _apiClient.post(
        ApiConstants.serviceBookCancel(bookingId),
        data: body,
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to cancel booking',
        );
      }

      final result = ServiceBookingCancelResultModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );

      log.infoWithContext('Service booking cancelled successfully', {
        'booking_id': result.bookingId,
        'status': result.status,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return result;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException cancelling service booking',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to cancel booking',
        e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on AppException catch (e, stackTrace) {
      log.errorWithContext(
        'API error cancelling service booking',
        {'message': e.message, 'status_code': e.statusCode},
        e,
        stackTrace,
      );
      throw ServerException(e.message, e.statusCode);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error cancelling service booking',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to cancel booking: $e');
    }
  }

  @override
  Future<List<ServiceInquiryModel>> getServiceInquiryHistory({
    int? serviceId,
    String? status,
    String? paymentStatus,
    int perPage = 15,
  }) async {
    final log = loggerWithContext({
      'feature': 'home_service',
      'class': 'HomeServiceRemoteDataSourceImpl',
      'method': 'getServiceInquiryHistory',
    });
    final startTime = DateTime.now();

    try {
      log.infoWithContext('Fetching service inquiry history', {
        'service_id': serviceId,
        'status': status,
        'payment_status': paymentStatus,
        'per_page': perPage,
      });

      final queryParameters = <String, dynamic>{'per_page': perPage.toString()};

      if (serviceId != null) {
        queryParameters['service_id'] = serviceId.toString();
      }

      final normalizedStatus = status?.trim();
      if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
        queryParameters['status'] = normalizedStatus;
      }

      final normalizedPaymentStatus = paymentStatus?.trim();
      if (normalizedPaymentStatus != null &&
          normalizedPaymentStatus.isNotEmpty) {
        queryParameters['payment_status'] = normalizedPaymentStatus;
      }

      final response = await _apiClient.get(
        ApiConstants.serviceOrders,
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!success) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to fetch service orders',
        );
      }

      final ordersData = data['data'] as Map<String, dynamic>;
      final ordersList = ordersData['orders'] as List<dynamic>;
      final orders = ordersList
          .map((e) => ServiceInquiryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      log.infoWithContext('Service inquiry history fetched successfully', {
        'count': orders.length,
        'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
      });

      return orders;
    } on DioException catch (e, stackTrace) {
      log.errorWithContext(
        'DioException fetching service inquiry history',
        {'message': e.message},
        e,
        stackTrace,
      );
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to fetch service orders',
        e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      log.errorWithContext(
        'Unexpected error fetching service inquiry history',
        {'error_type': e.runtimeType.toString()},
        e,
        stackTrace,
      );
      throw ServerException('Failed to fetch service orders: $e');
    }
  }
}
