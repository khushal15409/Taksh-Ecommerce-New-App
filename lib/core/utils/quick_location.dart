import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';

/// A coordinate pair is usable only when it is finite, in range and not the
/// 0/0 placeholder used for "no coordinates".
bool isValidCoordinatePair(double? latitude, double? longitude) {
  if (latitude == null || longitude == null) return false;
  if (latitude.isNaN || longitude.isNaN) return false;
  if (latitude.isInfinite || longitude.isInfinite) return false;
  if (latitude == 0.0 && longitude == 0.0) return false;
  return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
}

enum QuickLocationSource { address, device }

/// Location used to request the Quick dashboard/listing.
class QuickLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String pincode;
  final String? addressId;
  final QuickLocationSource source;

  const QuickLocation({
    required this.latitude,
    required this.longitude,
    this.pincode = '',
    this.addressId,
    required this.source,
  });

  /// Identity used to decide whether a reload is needed.
  String get key =>
      '${addressId ?? 'device'}|${latitude.toStringAsFixed(5)}|${longitude.toStringAsFixed(5)}|$pincode';

  @override
  List<Object?> get props => [latitude, longitude, pincode, addressId, source];
}

/// Location of [address], or null when it has no valid coordinates.
QuickLocation? quickLocationFromAddress(Address? address) {
  if (address == null) return null;
  final lat = address.location.latitude;
  final lng = address.location.longitude;
  if (!isValidCoordinatePair(lat, lng)) return null;
  return QuickLocation(
    latitude: lat,
    longitude: lng,
    pincode: address.location.postalCode ?? '',
    addressId: address.id,
    source: QuickLocationSource.address,
  );
}

/// Precedence: selected address > saved address with valid coordinates >
/// device location (only when allowed and valid) > none.
///
/// A selected address always wins: when it has no valid coordinates the result
/// is null (the user must fix/choose an address), the device fix never
/// replaces a user selection.
QuickLocation? resolveQuickLocation({
  Address? selected,
  Iterable<Address> saved = const [],
  double? deviceLatitude,
  double? deviceLongitude,
  bool deviceAllowed = false,
}) {
  if (selected != null) return quickLocationFromAddress(selected);
  for (final address in saved) {
    final loc = quickLocationFromAddress(address);
    if (loc != null) return loc;
  }
  if (deviceAllowed && isValidCoordinatePair(deviceLatitude, deviceLongitude)) {
    return QuickLocation(
      latitude: deviceLatitude!,
      longitude: deviceLongitude!,
      source: QuickLocationSource.device,
    );
  }
  return null;
}

/// Whether the Quick dashboard must be requested again after the location
/// changed from [previous] (null when never requested) to [next].
bool shouldReloadQuick(QuickLocation? previous, QuickLocation? next) {
  if (next == null) return false;
  if (previous == null) return true;
  return previous.key != next.key;
}
