import 'package:taksh_e_commerce/features/home_service/data/models/courier_json.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_quote.dart';

class CourierQuoteOptionModel extends CourierQuoteOption {
  const CourierQuoteOptionModel({
    required super.courierCompanyId,
    required super.name,
    required super.rate,
    required super.serviceCharge,
    required super.totalAmount,
    super.estimatedDeliveryDays,
    super.estimatedDeliveryDate,
    super.serviceType,
  });

  factory CourierQuoteOptionModel.fromJson(Map<String, dynamic> json) {
    final rate = cDouble(json['rate']);
    final charge = cDouble(json['service_charge'] ?? json['platform_charge']);
    return CourierQuoteOptionModel(
      courierCompanyId: cStr(json['courier_company_id']),
      name: cStr(json['courier_name']).isEmpty
          ? 'Courier'
          : cStr(json['courier_name']),
      rate: rate,
      serviceCharge: charge,
      totalAmount: json['total_amount'] != null
          ? cDouble(json['total_amount'])
          : rate + charge,
      estimatedDeliveryDays: cNullInt(json['estimated_delivery_days']),
      estimatedDeliveryDate: cNullStr(json['estimated_delivery_date']),
      serviceType: cNullStr(json['service_type']),
    );
  }
}

class CourierQuoteModel extends CourierQuote {
  const CourierQuoteModel({
    required super.actualWeightGrams,
    required super.weightKg,
    required super.couriers,
  });

  factory CourierQuoteModel.fromJson(Map<String, dynamic> json) {
    final list = json['couriers'] is List ? json['couriers'] as List : const [];
    return CourierQuoteModel(
      actualWeightGrams: cDouble(json['actual_weight_grams']),
      weightKg: cDouble(json['weight_kg']),
      couriers: list
          .whereType<Map>()
          .map(
            (e) =>
                CourierQuoteOptionModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(growable: false),
    );
  }
}
