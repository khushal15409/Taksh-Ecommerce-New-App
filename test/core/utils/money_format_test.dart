import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/money_format.dart';

void main() {
  test('formatRupees prints whole amounts without decimals and paise with two', () {
    expect(formatRupees(199), '199');
    expect(formatRupees(199.0), '199');
    expect(formatRupees(199.5), '199.50');
    expect(formatRupees(34.9), '34.90');
    expect(formatRupees(0), '0');
    expect(formatRupees(2000079.5), '2000079.50');
  });

  test('parseMoney keeps paise from numbers and numeric strings', () {
    expect(parseMoney(199.5), 199.5);
    expect(parseMoney(100), 100.0);
    expect(parseMoney('12.50'), 12.5);
    expect(parseMoney(null), isNull);
    expect(parseMoney('abc'), isNull);
  });
}
