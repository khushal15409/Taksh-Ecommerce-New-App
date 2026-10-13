import 'package:taksh_e_commerce/features/home_service/data/models/service_booking_model.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_bookings_page.dart';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class ServiceBookingsPageModel extends ServiceBookingsPage {
  const ServiceBookingsPageModel({
    required super.bookings,
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
  });

  factory ServiceBookingsPageModel.fromJson(Map<String, dynamic> json) {
    final bookingsList = json['bookings'];
    final bookings = bookingsList is List
        ? bookingsList
              .whereType<Map>()
              .map(
                (entry) => ServiceBookingModel.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .toList(growable: false)
        : const <ServiceBooking>[];

    final paginationJson = json['pagination'];
    final pagination = paginationJson is Map
        ? Map<String, dynamic>.from(paginationJson)
        : const <String, dynamic>{};

    return ServiceBookingsPageModel(
      bookings: bookings,
      currentPage: _asInt(pagination['current_page']),
      lastPage: _asInt(pagination['last_page']),
      perPage: _asInt(pagination['per_page']),
      total: _asInt(pagination['total']),
    );
  }
}
