import 'package:equatable/equatable.dart';

/// Server verdict for a delivery type at a saved address (GET /cart/quote).
///
/// The app never computes serviceability itself and there is no real ETA
/// source: [guaranteed] is always false and no minutes are exposed.
class DeliveryQuote extends Equatable {
  final String deliveryType;

  /// Whether the server actually checked serviceability (false for standard).
  final bool checked;
  final bool serviceable;
  final String? code;
  final String? message;

  const DeliveryQuote({
    required this.deliveryType,
    required this.checked,
    required this.serviceable,
    this.code,
    this.message,
  });

  @override
  List<Object?> get props => [deliveryType, checked, serviceable, code, message];
}
