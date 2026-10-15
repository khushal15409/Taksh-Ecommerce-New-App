import 'package:json_annotation/json_annotation.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';

part 'place_order_request_model.g.dart';

/// Model for place order request
@JsonSerializable(createFactory: false)
class PlaceOrderRequestModel {
  @JsonKey(name: 'address_id')
  final String addressId;

  @JsonKey(name: 'warehouse_id')
  final String warehouseId;

  @JsonKey(name: 'delivery_type')
  final String deliveryType;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(includeToJson: false)
  final List<ExtraCharge> extraCharges;

  const PlaceOrderRequestModel({
    required this.addressId,
    required this.warehouseId,
    required this.deliveryType,
    required this.paymentMethod,
    required this.vendorId,
    this.extraCharges = const [],
  });

  Map<String, dynamic> toJson() => _$PlaceOrderRequestModelToJson(this);

  /// Convert to form data map for API
  DataMap toFormData() {
    // Only what the server reads. The vendor is taken from the cart, and the
    // amounts (items, fees, coupon, total) are always recalculated server-side,
    // so the placeholder warehouse/vendor ids and the client's charges are not sent.
    return {
      'address_id': addressId,
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
    };
  }
}
