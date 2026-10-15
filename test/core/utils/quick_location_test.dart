import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address_type.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/location.dart';

Address _address(String id, double lat, double lng, {String? pincode}) {
  return Address(
    id: id,
    userId: '',
    type: AddressType.home,
    recipientName: 'Test',
    recipientPhone: '9999999999',
    location: Location(latitude: lat, longitude: lng, postalCode: pincode),
    addressLine1: 'Line 1',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('isValidCoordinatePair', () {
    test('rejects null, 0/0, NaN and out of range values', () {
      expect(isValidCoordinatePair(null, 72.5), isFalse);
      expect(isValidCoordinatePair(23.0, null), isFalse);
      expect(isValidCoordinatePair(0.0, 0.0), isFalse);
      expect(isValidCoordinatePair(double.nan, 72.5), isFalse);
      expect(isValidCoordinatePair(91.0, 72.5), isFalse);
      expect(isValidCoordinatePair(23.0, 181.0), isFalse);
    });

    test('accepts a real location', () {
      expect(isValidCoordinatePair(23.0225, 72.5714), isTrue);
    });
  });

  group('resolveQuickLocation', () {
    final good = _address('1', 23.02, 72.57, pincode: '380001');
    final noCoords = _address('2', 0.0, 0.0, pincode: '380002');

    test('selected address wins and carries id and pincode', () {
      final loc = resolveQuickLocation(
        selected: good,
        saved: [noCoords],
        deviceLatitude: 10.0,
        deviceLongitude: 20.0,
        deviceAllowed: true,
      );
      expect(loc?.addressId, '1');
      expect(loc?.pincode, '380001');
      expect(loc?.source, QuickLocationSource.address);
    });

    test('a selected address without coordinates is never replaced by device',
        () {
      final loc = resolveQuickLocation(
        selected: noCoords,
        saved: [good],
        deviceLatitude: 10.0,
        deviceLongitude: 20.0,
        deviceAllowed: true,
      );
      expect(loc, isNull);
    });

    test('falls back to a saved address with valid coordinates', () {
      final loc = resolveQuickLocation(saved: [noCoords, good]);
      expect(loc?.addressId, '1');
    });

    test('device location only when allowed and valid, no saved address', () {
      final allowed = resolveQuickLocation(
        deviceLatitude: 10.0,
        deviceLongitude: 20.0,
        deviceAllowed: true,
      );
      expect(allowed?.source, QuickLocationSource.device);
      expect(allowed?.addressId, isNull);

      expect(
        resolveQuickLocation(deviceLatitude: 10.0, deviceLongitude: 20.0),
        isNull,
      );
      expect(
        resolveQuickLocation(
          deviceLatitude: 0.0,
          deviceLongitude: 0.0,
          deviceAllowed: true,
        ),
        isNull,
      );
    });

    test('nothing available gives null (no made-up coordinates)', () {
      expect(resolveQuickLocation(), isNull);
    });
  });

  group('shouldReloadQuick', () {
    final a = quickLocationFromAddress(_address('1', 23.02, 72.57))!;
    final sameAgain = quickLocationFromAddress(_address('1', 23.02, 72.57))!;
    final otherAddress = quickLocationFromAddress(_address('2', 23.02, 72.57))!;
    final moved = quickLocationFromAddress(_address('1', 23.5, 72.57))!;

    test('first request loads', () {
      expect(shouldReloadQuick(null, a), isTrue);
    });

    test('identical location does not reload (no duplicates or loops)', () {
      expect(shouldReloadQuick(a, sameAgain), isFalse);
    });

    test('another address or moved coordinates reload', () {
      expect(shouldReloadQuick(a, otherAddress), isTrue);
      expect(shouldReloadQuick(a, moved), isTrue);
    });

    test('no usable location never requests', () {
      expect(shouldReloadQuick(a, null), isFalse);
      expect(shouldReloadQuick(null, null), isFalse);
    });
  });
}
