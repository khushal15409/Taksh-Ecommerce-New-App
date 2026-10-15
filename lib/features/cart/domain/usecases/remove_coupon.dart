import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/repositories/cart_repository.dart';

/// Removes the coupon from the cart; the returned cart has its totals without it.
class RemoveCoupon implements UseCase<Cart, RemoveCouponParams> {
  final CartRepository repository;

  RemoveCoupon(this.repository);

  @override
  ResultFuture<Cart> call(RemoveCouponParams params) async {
    return await repository.removeCoupon(
      guestToken: params.guestToken,
      deliveryType: params.deliveryType,
    );
  }
}

class RemoveCouponParams extends Equatable {
  final String? guestToken;
  final String deliveryType;

  const RemoveCouponParams({this.guestToken, this.deliveryType = 'normal'});

  @override
  List<Object?> get props => [guestToken, deliveryType];
}
