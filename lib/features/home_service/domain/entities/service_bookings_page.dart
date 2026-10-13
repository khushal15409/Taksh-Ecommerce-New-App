import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';

/// Paginated list of service bookings returned by `GET /service/book`.
class ServiceBookingsPage extends Equatable {
  final List<ServiceBooking> bookings;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ServiceBookingsPage({
    required this.bookings,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [bookings, currentPage, lastPage, perPage, total];
}
