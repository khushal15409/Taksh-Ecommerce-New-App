import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/features/home/data/models/product_model.dart';

Map<String, dynamic> _json({bool inStock = true, Object? availability}) => {
      'id': 7,
      'name': 'Milk',
      'price': 50,
      'original_price': 55,
      'in_stock': inStock,
      if (availability != null) 'availability': availability,
    };

void main() {
  test('Standard / older server payload: stock alone decides (unchanged)', () {
    final p = ProductModel.fromJson(_json());
    expect(p.availability, isNull);
    expect(p.canOrder, isTrue);
    expect(ProductModel.fromJson(_json(inStock: false)).canOrder, isFalse);
  });

  test('area_unserviceable product cannot be ordered', () {
    final p = ProductModel.fromJson(_json(
      inStock: false,
      availability: {'status': 'area_unserviceable', 'can_order': false},
    ));
    expect(p.canOrder, isFalse);
    expect(p.availability!.status.isLocationLevel, isTrue);
  });

  test('available verdict with stock can be ordered', () {
    final p = ProductModel.fromJson(
        _json(availability: {'status': 'available', 'can_order': true}));
    expect(p.canOrder, isTrue);
  });

  test('unreadable availability status fails closed', () {
    final p = ProductModel.fromJson(_json(availability: {'status': 'maybe'}));
    expect(p.availability!.status, QuickAvailabilityStatus.unknown);
    expect(p.canOrder, isFalse);
  });

  test('server order is kept: available products stay ahead', () {
    final list = [
      _json(availability: {'status': 'available'}),
      _json(inStock: false, availability: {'status': 'out_of_stock'}),
    ].map(ProductModel.fromJson).toList();
    expect(list.map((p) => p.canOrder).toList(), [true, false]);
  });
}
