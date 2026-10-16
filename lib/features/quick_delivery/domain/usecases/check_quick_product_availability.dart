import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/repositories/quick_delivery_repository.dart';

/// Asks the server whether the selected address can order a Quick product now.
class CheckQuickProductAvailability
    extends UseCase<QuickProductAvailability, CheckQuickProductAvailabilityParams> {
  final QuickDeliveryRepository _repository;

  const CheckQuickProductAvailability(this._repository);

  @override
  ResultFuture<QuickProductAvailability> call(
    CheckQuickProductAvailabilityParams params,
  ) {
    return _repository.getProductAvailability(
      productId: params.productId,
      variantId: params.variantId,
      addressId: params.addressId,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class CheckQuickProductAvailabilityParams extends Equatable {
  final int productId;
  final int? variantId;
  final String? addressId;
  final double? latitude;
  final double? longitude;

  const CheckQuickProductAvailabilityParams({
    required this.productId,
    this.variantId,
    this.addressId,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [productId, variantId, addressId, latitude, longitude];
}
