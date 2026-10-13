import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/core/usecase/usecase.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/service_booking_payment.dart';
import 'package:taksh_e_commerce/features/home_service/domain/repositories/home_service_repository.dart';

/// Creates a marketplace service booking and its Razorpay payment order.
class BookService implements UseCase<ServiceBookingPayment, BookServiceParams> {
  final HomeServiceRepository repository;

  const BookService(this.repository);

  @override
  ResultFuture<ServiceBookingPayment> call(BookServiceParams params) async {
    return repository.bookService(
      serviceId: params.serviceId,
      name: params.name,
      mobile: params.mobile,
      addressLine1: params.addressLine1,
      pincode: params.pincode,
      city: params.city,
      state: params.state,
      type: params.type,
      idempotencyKey: params.idempotencyKey,
      landmark: params.landmark,
      customerNotes: params.customerNotes,
    );
  }
}

class BookServiceParams extends Equatable {
  final int serviceId;
  final String name;
  final String mobile;
  final String addressLine1;
  final String pincode;
  final String city;
  final String state;
  final String type;
  final String idempotencyKey;
  final String? landmark;
  final String? customerNotes;

  const BookServiceParams({
    required this.serviceId,
    required this.name,
    required this.mobile,
    required this.addressLine1,
    required this.pincode,
    required this.city,
    required this.state,
    required this.type,
    required this.idempotencyKey,
    this.landmark,
    this.customerNotes,
  });

  @override
  List<Object?> get props => [
    serviceId,
    name,
    mobile,
    addressLine1,
    pincode,
    city,
    state,
    type,
    idempotencyKey,
    landmark,
    customerNotes,
  ];
}
