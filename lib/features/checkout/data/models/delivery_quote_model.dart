import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/delivery_quote.dart';

/// Parses the `data` object of GET /cart/quote.
class DeliveryQuoteModel extends DeliveryQuote {
  const DeliveryQuoteModel({
    required super.deliveryType,
    required super.checked,
    required super.serviceable,
    super.code,
    super.message,
  });

  /// Fails closed: a payload without a boolean-like `serviceable` is treated
  /// as NOT serviceable.
  factory DeliveryQuoteModel.fromJson(DataMap json, {String? deliveryType}) {
    bool? asBool(Object? value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.trim().toLowerCase();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
      return null;
    }

    final code = json['code'];
    final message = json['message'];
    return DeliveryQuoteModel(
      deliveryType: json['delivery_type']?.toString() ?? deliveryType ?? '',
      checked: asBool(json['checked']) ?? false,
      serviceable: asBool(json['serviceable']) ?? false,
      code: code is String && code.isNotEmpty ? code : null,
      message: message is String && message.isNotEmpty ? message : null,
    );
  }
}
