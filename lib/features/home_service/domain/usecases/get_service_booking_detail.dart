import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Fetches a single marketplace service booking.
class GetServiceBookingDetail
    implements UseCase<ServiceBooking, GetServiceBookingDetailParams> {
  final HomeServiceRepository repository;

  const GetServiceBookingDetail(this.repository);

  @override
  ResultFuture<ServiceBooking> call(GetServiceBookingDetailParams params) {
    return repository.getServiceBookingDetail(bookingId: params.bookingId);
  }
}

class GetServiceBookingDetailParams extends Equatable {
  final int bookingId;

  const GetServiceBookingDetailParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
