import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/repositories/cart_repository.dart';

/// Applies a coupon code to the cart. The server decides whether the coupon is
/// valid and how much it takes off; the returned cart carries the result.
class ApplyCoupon implements UseCase<Cart, ApplyCouponParams> {
  final CartRepository repository;

  ApplyCoupon(this.repository);

  @override
  ResultFuture<Cart> call(ApplyCouponParams params) async {
    return await repository.applyCoupon(
      couponCode: params.couponCode,
      guestToken: params.guestToken,
      deliveryType: params.deliveryType,
    );
  }
}

class ApplyCouponParams extends Equatable {
  final String couponCode;
  final String? guestToken;
  final String deliveryType;

  const ApplyCouponParams({
    required this.couponCode,
    this.guestToken,
    this.deliveryType = 'normal',
  });

  @override
  List<Object?> get props => [couponCode, guestToken, deliveryType];
}
