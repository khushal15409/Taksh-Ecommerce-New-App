import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/orders/domain/entities/refund_transaction.dart';

class RefundTransactionModel extends RefundTransaction {
  const RefundTransactionModel({
    required super.id,
    required super.amount,
    required super.status,
    super.createdAt,
    super.paymentMethod,
  });

  factory RefundTransactionModel.fromJson(DataMap json) {
    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    String? parseOptionalString(dynamic value) {
      if (value == null) return null;
      final normalized = value.toString().trim();
      if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
        return null;
      }
      return normalized;
    }

    DateTime? parseDate(dynamic value) {
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return RefundTransactionModel(
      id: parseString(json['id']),
      amount: parseString(json['amount'], fallback: '0'),
      status: parseString(json['status'], fallback: 'completed'),
      createdAt: parseDate(json['created_at']),
      paymentMethod: parseOptionalString(
        json['payment_method'] ?? json['method'],
      ),
    );
  }
}
