import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/features/address/data/datasources/places_remote_datasource.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/place_suggestion.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/location.dart';
import 'package:taksh_e_commerce/features/address/domain/usecases/get_current_location.dart';
import 'package:taksh_e_commerce/features/address/domain/usecases/get_location_from_latlng.dart';
import 'package:taksh_e_commerce/features/address/domain/usecases/search_places.dart';
import 'package:taksh_e_commerce/features/address/presentation/cubit/map_state.dart';

/// Cubit for managing map interactions
class MapCubit extends Cubit<MapState> {
  final GetCurrentLocation _getCurrentLocation;
  final GetLocationFromLatLng _getLocationFromLatLng;
  final SearchPlaces _searchPlaces;

  /// Google type-ahead. Null / not configured: the geocoding search is used.
  final PlacesRemoteDataSource? _places;

  /// One token per typing session (billing + relevance); renewed after a pick.
  String _sessionToken = _newToken();
  Location? _bias;

  static String _newToken() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  MapCubit({
    required GetCurrentLocation getCurrentLocation,
    required GetLocationFromLatLng getLocationFromLatLng,
    required SearchPlaces searchPlaces,
    PlacesRemoteDataSource? places,
  })  : _getCurrentLocation = getCurrentLocation,
        _getLocationFromLatLng = getLocationFromLatLng,
        _searchPlaces = searchPlaces,
        _places = places,
        super(const MapInitial());

  final _log = loggerWithContext({
    'feature': 'address',
    'layer': 'presentation',
    'class': 'MapCubit'
  });

  /// Get current device location
  Future<void> getCurrentLocation() async {
    final startTime = DateTime.now();
    _log.infoWithContext('Getting current location', {'action': 'get_location'});

    emit(const MapLoading(message: 'Getting your location...'));

    final result = await _getCurrentLocation();

    result.fold(
      (failure) {
        _log.errorWithContext(
          'Failed to get current location',
          {
            'error': failure.message,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        
        if (failure.message.toLowerCase().contains('permission')) {
          emit(const MapPermissionDenied());
        } else {
          emit(MapError(failure.message));
        }
      },
      (location) {
        _log.infoWithContext(
          'Current location retrieved',
          {
            'lat': location.latitude,
            'lng': location.longitude,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        _bias = location;
        emit(MapLocationSelected(
          location: location,
          isCurrentLocation: true,
        ));
      },
    );
  }

  /// Select a location by coordinates
  Future<void> selectLocation(double latitude, double longitude) async {
    final startTime = DateTime.now();
    _log.infoWithContext(
      'Selecting location',
      {'action': 'select_location', 'lat': latitude, 'lng': longitude},
    );

    emit(const MapLoading(message: 'Getting address details...'));

    final result = await _getLocationFromLatLng(
      LatLngParams(latitude: latitude, longitude: longitude),
    );

    result.fold(
      (failure) {
        _log.errorWithContext(
          'Failed to get location details',
          {
            'error': failure.message,
            'lat': latitude,
            'lng': longitude,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        emit(MapError(failure.message));
      },
      (location) {
        _log.infoWithContext(
          'Location selected',
          {
            'lat': location.latitude,
            'lng': location.longitude,
            'address': location.formattedAddress,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        emit(MapLocationSelected(location: location));
      },
    );
  }

  int _searchSeq = 0;

  /// Search for places
  Future<void> searchPlaces(String query) async {
    final seq = ++_searchSeq;
    if (query.trim().isEmpty) {
      emit(const MapInitial());
      return;
    }

    final startTime = DateTime.now();
    _log.infoWithContext(
      'Searching places',
      {'action': 'search', 'query': query},
    );

    // Google type-ahead first (partial words like "alp" work); if it is not
    // configured or fails, the geocoding search below is used as before.
    final places = _places;
    if (places != null && places.isConfigured) {
      try {
        final suggestions = await places.autocomplete(
          query.trim(),
          sessionToken: _sessionToken,
          biasLatitude: _bias?.latitude,
          biasLongitude: _bias?.longitude,
        );
        if (isClosed || seq != _searchSeq) return;
        emit(MapSuggestionsLoaded(suggestions: suggestions, query: query));
        return;
      } catch (e) {
        _log.errorWithContext('Places autocomplete failed, using geocoding',
            {'error_type': e.runtimeType.toString()});
        if (isClosed || seq != _searchSeq) return;
      }
    }

    emit(const MapLoading(message: 'Searching...'));

    final result = await _searchPlaces(query);
    // A newer search started (or the cubit closed) while this one was running.
    if (isClosed || seq != _searchSeq) return;

    result.fold(
      (failure) {
        _log.errorWithContext(
          'Failed to search places',
          {
            'error': failure.message,
            'query': query,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        // A failed search just shows no suggestions; no error toast while typing.
        emit(MapSearchResults(places: const [], query: query));
      },
      (places) {
        _log.infoWithContext(
          'Places found',
          {
            'count': places.length,
            'query': query,
            'duration_ms': DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        emit(MapSearchResults(places: places, query: query));
      },
    );
  }

  /// A picked type-ahead suggestion: fetch its exact coordinates and address
  /// parts, fill anything Google left out by reverse geocoding the point.
  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    final places = _places;
    if (places == null) return;
    _searchSeq++; // late suggestion answers must not replace the pick
    emit(const MapLoading(message: 'Getting address details...'));
    try {
      var location =
          await places.details(suggestion, sessionToken: _sessionToken);
      _sessionToken = _newToken();

      if (location.city == null ||
          location.state == null ||
          location.postalCode == null) {
        final reverse = await _getLocationFromLatLng(
          LatLngParams(latitude: location.latitude, longitude: location.longitude),
        );
        location = reverse.fold(
          (_) => location,
          (r) => location.copyWith(
            city: location.city ?? r.city,
            state: location.state ?? r.state,
            postalCode: location.postalCode ?? r.postalCode,
            country: location.country ?? r.country,
          ),
        );
      }
      if (isClosed) return;
      _bias = location;
      emit(MapLocationSelected(location: location));
    } catch (e) {
      _log.errorWithContext('Failed to load place details',
          {'error_type': e.runtimeType.toString()});
      if (!isClosed) emit(const MapError('Could not load this place. Please try again.'));
    }
  }

  /// Select a place from search results
  void selectPlace(Location place) {
    _log.infoWithContext(
      'Place selected from search',
      {
        'lat': place.latitude,
        'lng': place.longitude,
        'address': place.formattedAddress,
      },
    );
    emit(MapLocationSelected(location: place));
  }

  /// Reset to initial state
  void reset() {
    _log.debugWithContext('Resetting map state', {'action': 'reset'});
    emit(const MapInitial());
  }
}
