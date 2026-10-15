import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/delivery_quote_model.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/delivery_quote.dart';
import 'package:taksh_e_commerce/features/checkout/domain/quick_checkout_gate.dart';

void main() {
  group('isQuickCheckoutBlocked', () {
    const ok = DeliveryQuote(
      deliveryType: '30_min',
      checked: true,
      serviceable: true,
    );
    const no = DeliveryQuote(
      deliveryType: '30_min',
      checked: true,
      serviceable: false,
      message: 'Not available',
    );

    test('standard is never blocked', () {
      expect(isQuickCheckoutBlocked(quickSelected: false, quote: null), isFalse);
      expect(isQuickCheckoutBlocked(quickSelected: false, quote: no), isFalse);
    });

    test('quick fails closed without a quote', () {
      expect(isQuickCheckoutBlocked(quickSelected: true, quote: null), isTrue);
    });

    test('quick is blocked when not serviceable and open when serviceable', () {
      expect(isQuickCheckoutBlocked(quickSelected: true, quote: no), isTrue);
      expect(isQuickCheckoutBlocked(quickSelected: true, quote: ok), isFalse);
    });

    test('a failed quote request blocks quick', () {
      expect(
        isQuickCheckoutBlocked(quickSelected: true, quote: failedQuote()),
        isTrue,
      );
    });
  });

  group('DeliveryQuoteModel.fromJson', () {
    test('parses a serviceable quote', () {
      final q = DeliveryQuoteModel.fromJson({
        'delivery_type': '30_min',
        'checked': true,
        'serviceable': true,
        'eta': {'guaranteed': false, 'estimated_minutes': null},
      });
      expect(q.serviceable, isTrue);
      expect(q.checked, isTrue);
      expect(q.deliveryType, '30_min');
    });

    test('parses a not serviceable quote with message and code', () {
      final q = DeliveryQuoteModel.fromJson({
        'delivery_type': '30_min',
        'checked': true,
        'serviceable': false,
        'code': 'quick_not_serviceable',
        'message': 'Not here',
      });
      expect(q.serviceable, isFalse);
      expect(q.code, 'quick_not_serviceable');
      expect(q.message, 'Not here');
    });

    test('missing serviceable fails closed', () {
      final q = DeliveryQuoteModel.fromJson(
        {'checked': true},
        deliveryType: '30_min',
      );
      expect(q.serviceable, isFalse);
      expect(q.deliveryType, '30_min');
    });
  });
}
