import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/features/orders/domain/order_delivery_mode.dart';

void main() {
  group('resolveIsQuickOrder', () {
    test('server is_quick wins over everything', () {
      expect(
        resolveIsQuickOrder(
          isQuick: true,
          deliveryType: 'normal',
          isExpress: false,
        ),
        isTrue,
      );
      expect(
        resolveIsQuickOrder(
          isQuick: false,
          deliveryType: '30_min',
          isExpress: true,
        ),
        isFalse,
      );
    });

    test('falls back to delivery_type values', () {
      for (final type in ['30_min', 'express_30', 'quick', ' Quick ']) {
        expect(resolveIsQuickOrder(deliveryType: type), isTrue, reason: type);
      }
    });

    test('falls back to the legacy is_express flag', () {
      expect(resolveIsQuickOrder(deliveryType: 'normal', isExpress: 1), isTrue);
    });

    test('unknown values are standard', () {
      expect(resolveIsQuickOrder(), isFalse);
      expect(resolveIsQuickOrder(deliveryType: 'weird'), isFalse);
      expect(resolveIsQuickOrder(deliveryType: 'normal'), isFalse);
      expect(resolveIsQuickOrder(isQuick: 'maybe', deliveryType: null), isFalse);
    });
  });

  group('deliveryModeParam', () {
    test('maps UI filter keys to the server delivery_mode', () {
      expect(deliveryModeParam('30_min'), 'quick');
      expect(deliveryModeParam('normal'), 'standard');
      expect(deliveryModeParam(null), isNull);
      expect(deliveryModeParam('all'), isNull);
    });
  });
}
