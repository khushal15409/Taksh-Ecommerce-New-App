import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/location.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/place_suggestion.dart';

/// Google Places type-ahead (autocomplete + details) for the address search.
///
/// Uses its own Dio: the app's ApiClient adds the customer's Bearer token and
/// must never send it to Google. The key comes from `.env`
/// (`GOOGLE_PLACES_API_KEY`); without it [isConfigured] is false and the caller
/// keeps using the geocoding search.
class PlacesRemoteDataSource {
  final Dio _dio;
  final String? _keyOverride;

  PlacesRemoteDataSource({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(BaseOptions(
              baseUrl: 'https://maps.googleapis.com/maps/api/place',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            )),
        _keyOverride = apiKey;

  String? get _key {
    if (_keyOverride != null) return _keyOverride;
    if (!dotenv.isInitialized) return null;
    final key = dotenv.maybeGet('GOOGLE_PLACES_API_KEY')?.trim();
    return key == null || key.isEmpty ? null : key;
  }

  bool get isConfigured => _key != null;

  /// Suggestions for [query] (India), biased to a point when one is known.
  Future<List<PlaceSuggestion>> autocomplete(
    String query, {
    required String sessionToken,
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    final key = _key;
    if (key == null) throw StateError('Places key not configured');

    final response = await _dio.get(
      '/autocomplete/json',
      queryParameters: {
        'input': query,
        'key': key,
        'sessiontoken': sessionToken,
        'components': 'country:in',
        if (biasLatitude != null && biasLongitude != null) ...{
          'location': '$biasLatitude,$biasLongitude',
          'radius': '50000',
        },
      },
    );
    final body = response.data;
    final status = body is Map ? body['status'] : null;
    if (status == 'ZERO_RESULTS') return const [];
    if (status != 'OK') throw StateError('Places autocomplete: $status');

    return (body['predictions'] as List)
        .whereType<Map>()
        .map((p) {
          final formatting = p['structured_formatting'];
          final description = '${p['description'] ?? ''}';
          final main = formatting is Map
              ? '${formatting['main_text'] ?? ''}'
              : description.split(',').first;
          final secondary = formatting is Map
              ? '${formatting['secondary_text'] ?? ''}'
              : '';
          return PlaceSuggestion(
            placeId: '${p['place_id']}',
            mainText: main.isEmpty ? description : main,
            secondaryText: secondary,
          );
        })
        .where((s) => s.placeId.isNotEmpty && s.placeId != 'null')
        .toList();
  }

  /// Exact coordinates and address parts of a picked suggestion.
  Future<Location> details(
    PlaceSuggestion suggestion, {
    required String sessionToken,
  }) async {
    final key = _key;
    if (key == null) throw StateError('Places key not configured');

    final response = await _dio.get(
      '/details/json',
      queryParameters: {
        'place_id': suggestion.placeId,
        'fields': 'geometry,formatted_address,address_component',
        'key': key,
        'sessiontoken': sessionToken,
      },
    );
    final body = response.data;
    if (body is! Map || body['status'] != 'OK') {
      throw StateError('Places details: ${body is Map ? body['status'] : 'bad body'}');
    }
    final result = body['result'] as Map;
    final point = (result['geometry'] as Map)['location'] as Map;
    final lat = (point['lat'] as num).toDouble();
    final lng = (point['lng'] as num).toDouble();

    String? component(List<String> types) {
      for (final c in (result['address_components'] as List? ?? const [])) {
        if (c is Map && (c['types'] as List).any(types.contains)) {
          return '${c['long_name']}';
        }
      }
      return null;
    }

    final formatted = '${result['formatted_address'] ?? ''}'.trim();
    final name = suggestion.mainText.trim();
    final address = formatted.isEmpty
        ? [name, suggestion.secondaryText].where((e) => e.isNotEmpty).join(', ')
        : (name.isNotEmpty && !formatted.toLowerCase().contains(name.toLowerCase())
            ? '$name, $formatted'
            : formatted);

    return Location(
      latitude: lat,
      longitude: lng,
      formattedAddress: address,
      street: component(['route', 'sublocality_level_1', 'sublocality']),
      city: component(['locality', 'administrative_area_level_3', 'administrative_area_level_2']),
      state: component(['administrative_area_level_1']),
      country: component(['country']),
      postalCode: component(['postal_code']),
    );
  }
}
