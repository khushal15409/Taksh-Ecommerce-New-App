import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/logger/log_redaction.dart';

void main() {
  test('masks tokens, OTPs, payment and personal data but keeps the rest', () {
    final redacted = redactForLog({
      'success': true,
      'message': 'OTP verified',
      'data': {
        'token': 'secret-token',
        'otp': '1234',
        'razorpay_signature': 'sig',
        'mobile': '9999999999',
        'email': 'a@b.c',
        'address_line_1': 'Street 1',
        'latitude': 23.1,
        'order_id': 42,
        'items': [
          {'name': 'Milk', 'qty': 2},
        ],
      },
    }) as Map<String, Object?>;

    final data = redacted['data'] as Map<String, Object?>;
    expect(redacted['success'], true);
    expect(data['token'], '***');
    expect(data['otp'], '***');
    expect(data['razorpay_signature'], '***');
    expect(data['mobile'], '***');
    expect(data['email'], '***');
    expect(data['address_line_1'], '***');
    expect(data['latitude'], '***');
    expect(data['order_id'], 42);
    expect((data['items'] as List).first, {'name': 'Milk', 'qty': 2});
  });

  test('keys are matched case-insensitively and long text is cut', () {
    final redacted = redactForLog({
      'Authorization': 'Bearer abc',
      'note': 'x' * 500,
    }) as Map<String, Object?>;

    expect(redacted['Authorization'], '***');
    expect((redacted['note'] as String).length, lessThan(300));
  });

  test('non-map values pass through and deep nesting is bounded', () {
    expect(redactForLog(null), isNull);
    expect(redactForLog(7), 7);
    Object? deep = 'leaf';
    for (var i = 0; i < 20; i++) {
      deep = {'level': deep};
    }
    expect(() => redactForLog(deep), returnsNormally);
  });
}
