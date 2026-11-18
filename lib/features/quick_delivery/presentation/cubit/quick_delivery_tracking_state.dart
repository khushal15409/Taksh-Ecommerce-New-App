import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/entities/quick_delivery_tracking.dart';

enum QuickDeliveryTrackingStatus { initial, loading, loaded, error }

class QuickDeliveryTrackingState extends Equatable {
  final QuickDeliveryTrackingStatus status;
  final int? orderId;
  final String orderStatus;
  final GeoPoint? riderLocation;
  final GeoPoint? customerLocation;
  final GeoPoint? storeLocation;
  final String message;
  final String? errorMessage;
  final DateTime? lastUpdatedAt;

  const QuickDeliveryTrackingState({
    required this.status,
    this.orderId,
    this.orderStatus = '',
    this.riderLocation,
    this.customerLocation,
    this.storeLocation,
    this.message = '',
    this.errorMessage,
    this.lastUpdatedAt,
  });

  const QuickDeliveryTrackingState.initial()
      : this(status: QuickDeliveryTrackingStatus.initial);

  bool get hasRiderLocation => riderLocation != null;
  bool get hasCustomerLocation => customerLocation != null;

  QuickDeliveryTrackingState copyWith({
    QuickDeliveryTrackingStatus? status,
    int? orderId,
    bool clearOrderId = false,
    String? orderStatus,
    GeoPoint? riderLocation,
    bool clearRiderLocation = false,
    GeoPoint? customerLocation,
    bool clearCustomerLocation = false,
    GeoPoint? storeLocation,
    String? message,
    String? errorMessage,
    bool clearErrorMessage = false,
    DateTime? lastUpdatedAt,
    bool clearLastUpdatedAt = false,
  }) {
    return QuickDeliveryTrackingState(
      status: status ?? this.status,
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
      orderStatus: orderStatus ?? this.orderStatus,
      riderLocation:
          clearRiderLocation ? null : (riderLocation ?? this.riderLocation),
      customerLocation: clearCustomerLocation
          ? null
          : (customerLocation ?? this.customerLocation),
      storeLocation: storeLocation ?? this.storeLocation,
      message: message ?? this.message,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastUpdatedAt:
          clearLastUpdatedAt ? null : (lastUpdatedAt ?? this.lastUpdatedAt),
    );
  }

  @override
  List<Object?> get props => [
        status,
        orderId,
        orderStatus,
        riderLocation,
        customerLocation,
        storeLocation,
        message,
        errorMessage,
        lastUpdatedAt,
      ];
}
