import 'package:equatable/equatable.dart';

class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class QuickDeliveryTracking extends Equatable {
  final int orderId;
  final String orderStatus;
  final GeoPoint? riderLocation;
  final String message;

  /// The order's delivery address and the shop, sent by the server even before a rider is moving,
  /// so the map always has something to show.
  final GeoPoint? destination;
  final GeoPoint? store;

  bool get isLocationAvailable => riderLocation != null;

  const QuickDeliveryTracking({
    required this.orderId,
    required this.orderStatus,
    required this.riderLocation,
    required this.message,
    this.destination,
    this.store,
  });

  @override
  List<Object?> get props =>
      [orderId, orderStatus, riderLocation, message, destination, store];
}
