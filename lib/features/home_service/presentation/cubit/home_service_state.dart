import 'package:equatable/equatable.dart';
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

/// States for the HomeService feature.
abstract class HomeServiceState extends Equatable {
  const HomeServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class HomeServiceInitial extends HomeServiceState {
  const HomeServiceInitial();
}

/// Loading available services.
class HomeServiceLoading extends HomeServiceState {
  const HomeServiceLoading();
}

/// Services loaded successfully.
class HomeServiceLoaded extends HomeServiceState {
  final List<HomeService> services;

  const HomeServiceLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

/// Error loading services.
class HomeServiceError extends HomeServiceState {
  final String message;

  const HomeServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading courier delivery partners.
class HomeServiceCourierPartnersLoading extends HomeServiceState {
  const HomeServiceCourierPartnersLoading();
}

/// Courier delivery partners loaded successfully.
class HomeServiceCourierPartnersLoaded extends HomeServiceState {
  final List<CourierDeliveryPartner> partners;

  const HomeServiceCourierPartnersLoaded(this.partners);

  @override
  List<Object?> get props => [partners];
}

/// Error loading courier delivery partners.
class HomeServiceCourierPartnersError extends HomeServiceState {
  final String message;

  const HomeServiceCourierPartnersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading courier quote.
class HomeServiceCourierQuoteLoading extends HomeServiceState {
  const HomeServiceCourierQuoteLoading();
}

/// Courier quote loaded successfully.
class HomeServiceCourierQuoteLoaded extends HomeServiceState {
  final CourierQuote quote;

  const HomeServiceCourierQuoteLoaded(this.quote);

  @override
  List<Object?> get props => [quote];
}

/// Error loading courier quote.
class HomeServiceCourierQuoteError extends HomeServiceState {
  final String message;

  const HomeServiceCourierQuoteError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Creating a courier booking.
class HomeServiceCourierBookingSubmitting extends HomeServiceState {
  const HomeServiceCourierBookingSubmitting();
}

/// Courier booking created successfully.
class HomeServiceCourierBookingSuccess extends HomeServiceState {
  final CourierBooking booking;

  const HomeServiceCourierBookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Error creating courier booking.
class HomeServiceCourierBookingError extends HomeServiceState {
  final String message;

  const HomeServiceCourierBookingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Creating an electrician, plumber, or salon booking + payment order.
class HomeServiceBookingCreating extends HomeServiceState {
  const HomeServiceBookingCreating();
}

/// Service booking created; payment order is ready for checkout.
class HomeServiceBookingCreated extends HomeServiceState {
  final ServiceBookingPayment payment;

  const HomeServiceBookingCreated(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Error creating a service booking.
class HomeServiceBookingError extends HomeServiceState {
  final String message;

  const HomeServiceBookingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Verifying a service booking payment.
class HomeServiceBookingVerifying extends HomeServiceState {
  const HomeServiceBookingVerifying();
}

/// Service booking payment verified successfully.
class HomeServiceBookingConfirmed extends HomeServiceState {
  final VerifyServiceBookingResult booking;

  const HomeServiceBookingConfirmed(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Error verifying a service booking payment.
class HomeServiceBookingVerificationError extends HomeServiceState {
  final String message;

  const HomeServiceBookingVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading service inquiry history.
class HomeServiceHistoryLoading extends HomeServiceState {
  const HomeServiceHistoryLoading();
}

/// Service inquiry history loaded.
class HomeServiceHistoryLoaded extends HomeServiceState {
  final List<ServiceInquiry> orders;

  const HomeServiceHistoryLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// Error loading service inquiry history.
class HomeServiceHistoryError extends HomeServiceState {
  final String message;

  const HomeServiceHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading the marketplace service bookings list.
class ServiceBookingsLoading extends HomeServiceState {
  const ServiceBookingsLoading();
}

/// Marketplace service bookings loaded.
class ServiceBookingsLoaded extends HomeServiceState {
  final ServiceBookingsPage page;

  const ServiceBookingsLoaded(this.page);

  @override
  List<Object?> get props => [page];
}

/// Error loading marketplace service bookings.
class ServiceBookingsError extends HomeServiceState {
  final String message;

  const ServiceBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading a single marketplace service booking.
class ServiceBookingDetailLoading extends HomeServiceState {
  const ServiceBookingDetailLoading();
}

/// Marketplace service booking detail loaded.
class ServiceBookingDetailLoaded extends HomeServiceState {
  final ServiceBooking booking;

  const ServiceBookingDetailLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Error loading a marketplace service booking detail.
class ServiceBookingDetailError extends HomeServiceState {
  final String message;

  const ServiceBookingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cancelling a marketplace service booking.
class ServiceBookingCancelling extends HomeServiceState {
  const ServiceBookingCancelling();
}

/// Marketplace service booking cancelled.
class ServiceBookingCancelled extends HomeServiceState {
  final ServiceBookingCancelResult result;

  const ServiceBookingCancelled(this.result);

  @override
  List<Object?> get props => [result];
}

/// Error cancelling a marketplace service booking.
class ServiceBookingCancelError extends HomeServiceState {
  final String message;

  const ServiceBookingCancelError(this.message);

  @override
  List<Object?> get props => [message];
}
