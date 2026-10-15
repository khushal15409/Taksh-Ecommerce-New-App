import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/features/home/data/models/express_dashboard_model.dart';

void main() {
  test('parses the not serviceable dashboard payload', () {
    final model = ExpressDashboardModel.fromJson({
      'serviceable': false,
      'code': 'quick_not_serviceable',
      'message': 'We do not deliver here yet',
      'sections': [],
    });
    expect(model.serviceable, isFalse);
    expect(model.code, 'quick_not_serviceable');
    expect(model.message, 'We do not deliver here yet');
    expect(model.sections, isEmpty);
  });

  test('a normal payload without serviceable is serviceable', () {
    final model = ExpressDashboardModel.fromJson({
      'fulfillment_center': {'id': 1, 'name': 'Store'},
      'sections': [],
    });
    expect(model.serviceable, isTrue);
    expect(model.code, isNull);
  });
}
