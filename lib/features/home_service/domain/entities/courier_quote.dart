import 'package:equatable/equatable.dart';

/// One live courier option returned by `POST /service/courier/quote`.
class CourierQuoteOption extends Equatable {
  final String courierCompanyId;
  final String name;
  final double rate;
  final double serviceCharge;
  final double totalAmount;
  final int? estimatedDeliveryDays;
  final String? estimatedDeliveryDate;
  final String? serviceType;

  const CourierQuoteOption({
    required this.courierCompanyId,
    required this.name,
    required this.rate,
    required this.serviceCharge,
    required this.totalAmount,
    this.estimatedDeliveryDays,
    this.estimatedDeliveryDate,
    this.serviceType,
  });

  @override
  List<Object?> get props => [
    courierCompanyId,
    name,
    rate,
    serviceCharge,
    totalAmount,
    estimatedDeliveryDays,
    estimatedDeliveryDate,
    serviceType,
  ];
}

/// Courier options for a parcel, sorted cheapest first by the server.
class CourierQuote extends Equatable {
  final double actualWeightGrams;
  final double weightKg;
  final List<CourierQuoteOption> couriers;

  const CourierQuote({
    required this.actualWeightGrams,
    required this.weightKg,
    required this.couriers,
  });

  @override
  List<Object?> get props => [actualWeightGrams, weightKg, couriers];
}
