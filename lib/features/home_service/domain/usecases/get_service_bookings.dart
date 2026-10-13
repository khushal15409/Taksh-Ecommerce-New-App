import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_bookings_page.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Fetches the paginated list of marketplace service bookings.
class GetServiceBookings
    implements UseCase<ServiceBookingsPage, GetServiceBookingsParams> {
  final HomeServiceRepository repository;

  const GetServiceBookings(this.repository);

  @override
  ResultFuture<ServiceBookingsPage> call(GetServiceBookingsParams params) {
    return repository.getServiceBookings(
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetServiceBookingsParams extends Equatable {
  final int page;
  final int perPage;

  const GetServiceBookingsParams({this.page = 1, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}
