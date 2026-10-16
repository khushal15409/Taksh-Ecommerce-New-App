import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';

void main() {
  group('QuickAvailabilityStatus.parse', () {
    test('maps every server status', () {
      expect(QuickAvailabilityStatus.parse('available'),
          QuickAvailabilityStatus.available);
      expect(QuickAvailabilityStatus.parse('out_of_stock'),
          QuickAvailabilityStatus.outOfStock);
      expect(QuickAvailabilityStatus.parse('area_unserviceable'),
          QuickAvailabilityStatus.areaUnserviceable);
      expect(QuickAvailabilityStatus.parse('location_required'),
          QuickAvailabilityStatus.locationRequired);
      expect(QuickAvailabilityStatus.parse('vendor_unavailable'),
          QuickAvailabilityStatus.vendorUnavailable);
      expect(QuickAvailabilityStatus.parse('variant_unavailable'),
          QuickAvailabilityStatus.variantUnavailable);
    });

    test('unknown or missing values are unknown, never available', () {
      expect(QuickAvailabilityStatus.parse(null),
          QuickAvailabilityStatus.unknown);
      expect(QuickAvailabilityStatus.parse(1), QuickAvailabilityStatus.unknown);
      expect(QuickAvailabilityStatus.parse('AVAILABLE?'),
          QuickAvailabilityStatus.unknown);
    });

    test('out of area and out of stock stay distinct', () {
      expect(QuickAvailabilityStatus.areaUnserviceable.isLocationLevel, isTrue);
      expect(QuickAvailabilityStatus.locationRequired.isLocationLevel, isTrue);
      expect(QuickAvailabilityStatus.outOfStock.isLocationLevel, isFalse);
    });
  });

  group('QuickProductAvailability', () {
    test('only an explicit available status can order', () {
      for (final status in QuickAvailabilityStatus.values) {
        expect(
          QuickProductAvailability(status: status).canOrder,
          status == QuickAvailabilityStatus.available,
          reason: '$status',
        );
      }
    });

    test('can_order: true next to another status does not order', () {
      final a = QuickProductAvailability.fromJson(
          {'status': 'out_of_stock', 'can_order': true});
      expect(a!.canOrder, isFalse);
    });

    test('missing or malformed payload gives no verdict (not available)', () {
      expect(QuickProductAvailability.fromJson(null), isNull);
      expect(QuickProductAvailability.fromJson('available'), isNull);
      expect(QuickProductAvailability.fromJson(<String, dynamic>{})!.canOrder,
          isFalse);
    });

    test('keeps the server message', () {
      final a = QuickProductAvailability.fromJson(
          {'status': 'area_unserviceable', 'message': '  Not in your area '});
      expect(a!.message, 'Not in your area');
    });
  });
}
