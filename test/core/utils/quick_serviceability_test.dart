import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/api_error_code.dart';
import 'package:taksh_e_commerce/core/utils/quick_serviceability.dart';

void main() {
  group('QuickServiceability.fromData', () {
    test('payload without serviceable key is serviceable', () {
      final s = QuickServiceability.fromData({'sections': []});
      expect(s.serviceable, isTrue);
      expect(s.code, isNull);
    });

    test('parses the not serviceable verdict with message', () {
      final s = QuickServiceability.fromData({
        'serviceable': false,
        'code': 'quick_not_serviceable',
        'message': 'Not available here',
        'sections': [],
      });
      expect(s.serviceable, isFalse);
      expect(s.code, quickNotServiceableCode);
      expect(s.message, 'Not available here');
    });

    test('accepts boolean-like values', () {
      expect(
        QuickServiceability.fromData({'serviceable': 0}).serviceable,
        isFalse,
      );
      expect(
        QuickServiceability.fromData({'serviceable': 'false'}).serviceable,
        isFalse,
      );
      expect(
        QuickServiceability.fromData({'serviceable': 1}).serviceable,
        isTrue,
      );
    });

    test('null data is serviceable', () {
      expect(QuickServiceability.fromData(null).serviceable, isTrue);
    });
  });

  test('isQuickServiceabilityCode', () {
    expect(isQuickServiceabilityCode('quick_not_serviceable'), isTrue);
    expect(isQuickServiceabilityCode('quick_location_required'), isTrue);
    expect(isQuickServiceabilityCode('cart_vendor_conflict'), isFalse);
    expect(isQuickServiceabilityCode(null), isFalse);
  });

  group('extractApiErrorCode', () {
    test('reads data.code from the error body', () {
      expect(
        extractApiErrorCode({
          'success': false,
          'message': 'm',
          'data': {'serviceable': false, 'code': 'quick_not_serviceable'},
        }),
        'quick_not_serviceable',
      );
    });

    test('returns null when there is no code', () {
      expect(extractApiErrorCode({'data': {'errors': {}}}), isNull);
      expect(extractApiErrorCode({'data': null}), isNull);
      expect(extractApiErrorCode('oops'), isNull);
      expect(extractApiErrorCode({'data': {'code': ''}}), isNull);
    });
  });
}
