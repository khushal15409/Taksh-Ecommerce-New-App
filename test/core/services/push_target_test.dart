import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/services/push_notification_service.dart';

void main() {
  group('PushTarget.fromData', () {
    test('opens the order for a known type and a valid id', () {
      final target = PushTarget.fromData({'type': 'order_delivered', 'order_id': '42'});

      expect(target, isNotNull);
      expect(target!.orderId, 42);
      expect(target.path, '/orders/42');
    });

    test('accepts a numeric id as well as a string', () {
      expect(PushTarget.fromData({'type': 'payment_confirmed', 'order_id': 7})?.orderId, 7);
    });

    test('ignores an unknown type', () {
      expect(PushTarget.fromData({'type': 'something_else', 'order_id': '42'}), isNull);
    });

    test('ignores a missing, non-numeric, zero or negative id', () {
      expect(PushTarget.fromData({'type': 'order_placed'}), isNull);
      expect(PushTarget.fromData({'type': 'order_placed', 'order_id': 'abc'}), isNull);
      expect(PushTarget.fromData({'type': 'order_placed', 'order_id': '0'}), isNull);
      expect(PushTarget.fromData({'type': 'order_placed', 'order_id': '-5'}), isNull);
      expect(PushTarget.fromData({'type': 'order_placed', 'order_id': '../admin'}), isNull);
    });

    test('opens a notification of the admin panel by its id', () {
      final target = PushTarget.fromData({'type': 'notification', 'notification_id': '12'});

      expect(target, isNotNull);
      expect(target!.notificationId, 12);
      expect(target.orderId, isNull);
    });

    test('ignores a notification push without a valid id', () {
      expect(PushTarget.fromData({'type': 'notification'}), isNull);
      expect(PushTarget.fromData({'type': 'notification', 'notification_id': 'x'}), isNull);
      expect(PushTarget.fromData({'type': 'notification', 'notification_id': '0'}), isNull);
      // an order id alone does not make a notification push
      expect(PushTarget.fromData({'type': 'notification', 'order_id': '5'}), isNull);
    });

    test('ignores empty data', () {
      expect(PushTarget.fromData({}), isNull);
    });
  });
}
