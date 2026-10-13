import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/book_service.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/cancel_service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/create_courier_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_courier_delivery_partners.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_courier_quote.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_service_booking_detail.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_service_bookings.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_service_inquiry_history.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/get_services.dart';
import 'package:taksh_e_commerce/features/home_service/domain/usecases/verify_service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/cubit/home_service_state.dart';

/// Cubit that manages the home service feature state.
class HomeServiceCubit extends Cubit<HomeServiceState> {
  final GetServices _getServices;
  final GetCourierDeliveryPartners _getCourierDeliveryPartners;
  final GetCourierQuote _getCourierQuote;
  final CreateCourierBooking _createCourierBooking;
  final BookService _bookService;
  final VerifyServiceBooking _verifyServiceBooking;
  final GetServiceBookings _getServiceBookings;
  final GetServiceBookingDetail _getServiceBookingDetail;
  final CancelServiceBooking _cancelServiceBooking;
  final GetServiceInquiryHistory _getServiceInquiryHistory;

  final _log = loggerWithContext({
    'feature': 'home_service',
    'class': 'HomeServiceCubit',
  });

  HomeServiceCubit({
    required GetServices getServices,
    required GetCourierDeliveryPartners getCourierDeliveryPartners,
    required GetCourierQuote getCourierQuote,
    required CreateCourierBooking createCourierBooking,
    required BookService bookService,
    required VerifyServiceBooking verifyServiceBooking,
    required GetServiceBookings getServiceBookings,
    required GetServiceBookingDetail getServiceBookingDetail,
    required CancelServiceBooking cancelServiceBooking,
    required GetServiceInquiryHistory getServiceInquiryHistory,
  }) : _getServices = getServices,
       _getCourierDeliveryPartners = getCourierDeliveryPartners,
       _getCourierQuote = getCourierQuote,
       _createCourierBooking = createCourierBooking,
       _bookService = bookService,
       _verifyServiceBooking = verifyServiceBooking,
       _getServiceBookings = getServiceBookings,
       _getServiceBookingDetail = getServiceBookingDetail,
       _cancelServiceBooking = cancelServiceBooking,
       _getServiceInquiryHistory = getServiceInquiryHistory,
       super(const HomeServiceInitial());

  /// Fetch all available services.
  Future<void> fetchServices() async {
    _log.infoWithContext('Fetching services', {'action': 'fetchServices'});
    emit(const HomeServiceLoading());

    final result = await _getServices();

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch services', {
          'message': failure.message,
        });
        emit(HomeServiceError(failure.message));
      },
      (services) {
        _log.infoWithContext('Services fetched', {'count': services.length});
        emit(HomeServiceLoaded(services));
      },
    );
  }

  /// Fetch courier delivery partners.
  Future<void> fetchCourierDeliveryPartners() async {
    _log.infoWithContext('Fetching courier delivery partners', {
      'action': 'fetchCourierDeliveryPartners',
    });
    emit(const HomeServiceCourierPartnersLoading());

    final result = await _getCourierDeliveryPartners();

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch courier delivery partners', {
          'message': failure.message,
        });
        emit(HomeServiceCourierPartnersError(failure.message));
      },
      (partners) {
        _log.infoWithContext('Courier delivery partners fetched', {
          'count': partners.length,
        });
        emit(HomeServiceCourierPartnersLoaded(partners));
      },
    );
  }

  /// Fetch courier quotes for the current parcel.
  Future<void> fetchCourierQuote(GetCourierQuoteParams params) async {
    _log.infoWithContext('Fetching courier quote', {
      'action': 'fetchCourierQuote',
      'weight_grams': params.weightGrams,
      'dimension_unit': params.dimensionUnit,
    });
    emit(const HomeServiceCourierQuoteLoading());

    final result = await _getCourierQuote(params);

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch courier quote', {
          'message': failure.message,
        });
        emit(HomeServiceCourierQuoteError(failure.message));
      },
      (quote) {
        _log.infoWithContext('Courier quote fetched', {
          'quotes_count': quote.quotes.length,
          'chargeable_weight_grams': quote.chargeableWeightGrams,
        });
        emit(HomeServiceCourierQuoteLoaded(quote));
      },
    );
  }

  /// Submit a courier booking.
  Future<void> submitCourierBooking(CreateCourierBookingParams params) async {
    _log.infoWithContext('Submitting courier booking', {
      'action': 'submitCourierBooking',
      'courier_delivery_partner_id': params.courierDeliveryPartnerId,
    });
    emit(const HomeServiceCourierBookingSubmitting());

    final result = await _createCourierBooking(params);

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to submit courier booking', {
          'message': failure.message,
        });
        emit(HomeServiceCourierBookingError(failure.message));
      },
      (booking) {
        _log.infoWithContext('Courier booking submitted', {
          'booking_id': booking.bookingId,
          'booking_number': booking.bookingNumber,
        });
        emit(HomeServiceCourierBookingSuccess(booking));
      },
    );
  }

  /// Book an electrician, plumber, or salon service and create the payment
  /// order required to complete the booking.
  Future<void> bookService(BookServiceParams params) async {
    _log.infoWithContext('Booking service', {
      'action': 'bookService',
      'service_id': params.serviceId,
    });
    emit(const HomeServiceBookingCreating());

    final result = await _bookService(params);

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to book service', {
          'message': failure.message,
        });
        emit(HomeServiceBookingError(failure.message));
      },
      (payment) {
        _log.infoWithContext('Service booking created', {
          'booking_id': payment.booking.id,
          'booking_number': payment.booking.bookingNumber,
          'has_payment_order': payment.isPayable,
        });
        emit(HomeServiceBookingCreated(payment));
      },
    );
  }

  /// Verify the Razorpay payment for a service booking.
  Future<void> verifyServiceBooking(VerifyServiceBookingParams params) async {
    _log.infoWithContext('Verifying service booking payment', {
      'action': 'verifyServiceBooking',
      'razorpay_order_id': params.razorpayOrderId,
    });
    emit(const HomeServiceBookingVerifying());

    final result = await _verifyServiceBooking(params);

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to verify service booking payment', {
          'message': failure.message,
        });
        emit(HomeServiceBookingVerificationError(failure.message));
      },
      (booking) {
        _log.infoWithContext('Service booking payment verified', {
          'booking_id': booking.bookingId,
          'payment_status': booking.paymentStatus,
        });
        emit(HomeServiceBookingConfirmed(booking));
      },
    );
  }

  /// Fetch the marketplace service bookings list.
  Future<void> fetchServiceBookings({int page = 1, int perPage = 10}) async {
    _log.infoWithContext('Fetching service bookings', {
      'action': 'fetchServiceBookings',
      'page': page,
      'per_page': perPage,
    });
    emit(const ServiceBookingsLoading());

    final result = await _getServiceBookings(
      GetServiceBookingsParams(page: page, perPage: perPage),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch service bookings', {
          'message': failure.message,
        });
        emit(ServiceBookingsError(failure.message));
      },
      (page) {
        _log.infoWithContext('Service bookings fetched', {
          'count': page.bookings.length,
          'total': page.total,
        });
        emit(ServiceBookingsLoaded(page));
      },
    );
  }

  /// Fetch a single marketplace service booking.
  Future<void> fetchServiceBookingDetail(int bookingId) async {
    _log.infoWithContext('Fetching service booking detail', {
      'action': 'fetchServiceBookingDetail',
      'booking_id': bookingId,
    });
    emit(const ServiceBookingDetailLoading());

    final result = await _getServiceBookingDetail(
      GetServiceBookingDetailParams(bookingId: bookingId),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch service booking detail', {
          'message': failure.message,
        });
        emit(ServiceBookingDetailError(failure.message));
      },
      (booking) {
        _log.infoWithContext('Service booking detail fetched', {
          'booking_id': booking.id,
        });
        emit(ServiceBookingDetailLoaded(booking));
      },
    );
  }

  /// Cancel a marketplace service booking.
  Future<void> cancelServiceBooking({
    required int bookingId,
    String? reason,
  }) async {
    _log.infoWithContext('Cancelling service booking', {
      'action': 'cancelServiceBooking',
      'booking_id': bookingId,
    });
    emit(const ServiceBookingCancelling());

    final result = await _cancelServiceBooking(
      CancelServiceBookingParams(bookingId: bookingId, reason: reason),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to cancel service booking', {
          'message': failure.message,
        });
        emit(ServiceBookingCancelError(failure.message));
      },
      (cancelResult) {
        _log.infoWithContext('Service booking cancelled', {
          'booking_id': cancelResult.bookingId,
          'status': cancelResult.status,
        });
        emit(ServiceBookingCancelled(cancelResult));
      },
    );
  }

  /// Fetch service inquiry / order history.
  Future<void> fetchHistory({
    int? serviceId,
    String? status,
    String? paymentStatus,
    int perPage = 15,
  }) async {
    _log.infoWithContext('Fetching service history', {
      'action': 'fetchHistory',
      'service_id': serviceId,
      'status': status,
      'payment_status': paymentStatus,
      'per_page': perPage,
    });
    emit(const HomeServiceHistoryLoading());

    final result = await _getServiceInquiryHistory(
      GetServiceInquiryHistoryParams(
        serviceId: serviceId,
        status: status,
        paymentStatus: paymentStatus,
        perPage: perPage,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _log.warnWithContext('Failed to fetch service history', {
          'message': failure.message,
        });
        emit(HomeServiceHistoryError(failure.message));
      },
      (orders) {
        _log.infoWithContext('Service history fetched', {
          'count': orders.length,
        });
        emit(HomeServiceHistoryLoaded(orders));
      },
    );
  }
}
