import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_cancel_result.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Cancels a marketplace service booking.
class CancelServiceBooking
    implements UseCase<ServiceBookingCancelResult, CancelServiceBookingParams> {
  final HomeServiceRepository repository;

  const CancelServiceBooking(this.repository);

  @override
  ResultFuture<ServiceBookingCancelResult> call(
    CancelServiceBookingParams params,
  ) {
    return repository.cancelServiceBooking(
      bookingId: params.bookingId,
      reason: params.reason,
    );
  }
}

class CancelServiceBookingParams extends Equatable {
  final int bookingId;
  final String? reason;

  const CancelServiceBookingParams({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}
