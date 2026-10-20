import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/placed_order_summary.dart';

/// Entity for place order response
class PlaceOrderResponse extends Equatable {
  final int orderId;
  final String? orderNumber;
  final String? message;
  final String? totalAmount;
  final String? paymentStatus;
  final String? orderStatus;

  /// Every order this checkout created (one per shop). Empty when the server did not say.
  final List<PlacedOrderSummary> placedOrders;

  const PlaceOrderResponse({
    required this.orderId,
    this.orderNumber,
    this.message,
    this.totalAmount,
    this.paymentStatus,
    this.orderStatus,
    this.placedOrders = const [],
  });

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        message,
        totalAmount,
        paymentStatus,
        orderStatus,
        placedOrders,
      ];
}
