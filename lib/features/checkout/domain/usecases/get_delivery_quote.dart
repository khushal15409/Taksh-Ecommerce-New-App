import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/delivery_quote.dart';
import 'package:taksh_e_commerce/features/checkout/domain/repositories/checkout_repository.dart';

/// Parameters for [GetDeliveryQuote]: only the delivery type and the saved
/// address id (never coordinates or a radius).
class GetDeliveryQuoteParams extends Equatable {
  final String deliveryType;
  final String addressId;

  const GetDeliveryQuoteParams({
    required this.deliveryType,
    required this.addressId,
  });

  @override
  List<Object?> get props => [deliveryType, addressId];
}

/// Asks the server whether a delivery type can serve an address.
class GetDeliveryQuote
    implements UseCase<DeliveryQuote, GetDeliveryQuoteParams> {
  final CheckoutRepository repository;

  GetDeliveryQuote(this.repository);

  @override
  ResultFuture<DeliveryQuote> call(GetDeliveryQuoteParams params) {
    return repository.getDeliveryQuote(
      deliveryType: params.deliveryType,
      addressId: params.addressId,
    );
  }
}
