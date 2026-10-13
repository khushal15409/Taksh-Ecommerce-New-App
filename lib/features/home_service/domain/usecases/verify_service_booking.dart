import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/verify_service_booking_result.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Verifies a marketplace service booking payment signature.
class VerifyServiceBooking
    implements UseCase<VerifyServiceBookingResult, VerifyServiceBookingParams> {
  final HomeServiceRepository repository;

  const VerifyServiceBooking(this.repository);

  @override
  ResultFuture<VerifyServiceBookingResult> call(
    VerifyServiceBookingParams params,
  ) async {
    return repository.verifyServiceBooking(
      razorpayOrderId: params.razorpayOrderId,
      razorpayPaymentId: params.razorpayPaymentId,
      razorpaySignature: params.razorpaySignature,
    );
  }
}

class VerifyServiceBookingParams extends Equatable {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyServiceBookingParams({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object?> get props => [
    razorpayOrderId,
    razorpayPaymentId,
    razorpaySignature,
  ];
}
