import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/features/cart/data/models/cart_model.dart';

void main() {
  test('cart amounts keep their paise (no truncation to whole rupees)', () {
    final cart = CartModel.fromJson({
      'items': [
        {
          'id': 1,
          'product_variant_id': 2,
          'product_name': 'Milk',
          'sku': 'M1',
          'price': '199.50',
          'qty': 1,
          'total': 199.5,
        },
      ],
      'total': 199.5,
      'total_with_delivery': 224.0,
      'charges': [
        {'type': 'platform', 'label': 'Platform Fees', 'amount': 9.5, 'is_discount': false},
        {'type': 'coupon', 'label': 'Coupon (SAVE)', 'amount': -12.5, 'is_discount': true},
      ],
    });

    expect(cart.total, 199.5);
    expect(cart.totalWithDelivery, 224.0);
    expect(cart.items.first.total, 199.5);
    expect(cart.extraCharges[0].amount, 9.5);
    expect(cart.extraCharges[1].amount, -12.5);
    expect(cart.extraCharges[1].isDiscount, true);
  });

  test('an empty cart payload is an empty cart with a zero total', () {
    final cart = CartModel.fromJson({'items': [], 'total': 0, 'total_with_delivery': 0, 'charges': []});
    expect(cart.items, isEmpty);
    expect(cart.total, 0);
  });
}
