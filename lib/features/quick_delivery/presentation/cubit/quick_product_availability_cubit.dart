import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/core/utils/request_guard.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/usecases/check_quick_product_availability.dart';

enum QuickAvailabilityPhase { idle, checking, checked, failed }

/// Availability of one Quick product at the selected address.
///
/// Fails closed: the product can be ordered only in the `checked` phase with an
/// explicit `available` verdict for the CURRENT product, variant and address.
/// Loading, failed and not-yet-requested states never enable ordering.
class QuickProductAvailabilityState extends Equatable {
  final QuickAvailabilityPhase phase;

  /// What the verdict belongs to (product, variant, address).
  final String? key;
  final QuickProductAvailability? availability;

  const QuickProductAvailabilityState({
    this.phase = QuickAvailabilityPhase.idle,
    this.key,
    this.availability,
  });

  bool get canOrder =>
      phase == QuickAvailabilityPhase.checked && availability?.canOrder == true;

  @override
  List<Object?> get props => [phase, key, availability];
}

class QuickProductAvailabilityCubit
    extends Cubit<QuickProductAvailabilityState> {
  final CheckQuickProductAvailability _check;

  /// Drops answers for an earlier product / variant / address.
  final RequestGuard _guard = RequestGuard();

  QuickProductAvailabilityCubit({
    required CheckQuickProductAvailability checkQuickProductAvailability,
  })  : _check = checkQuickProductAvailability,
        super(const QuickProductAvailabilityState());

  static String keyFor(int productId, int? variantId, QuickLocation? location) =>
      '$productId|${variantId ?? '-'}|${location?.key ?? 'no-location'}';

  /// Not a Quick product (or nothing to check): ordering is not gated here.
  void reset() {
    _guard.invalidate();
    if (state.phase != QuickAvailabilityPhase.idle) {
      emit(const QuickProductAvailabilityState());
    }
  }

  /// Asks the server. Repeated calls for the same key do nothing unless [force].
  Future<void> check({
    required int productId,
    int? variantId,
    required QuickLocation? location,
    bool force = false,
  }) async {
    final key = keyFor(productId, variantId, location);
    final sameKey = state.key == key;
    // An unchanged query is never repeated (also after a failure: retry is explicit).
    if (!force && sameKey && state.phase != QuickAvailabilityPhase.idle) return;

    final token = _guard.begin(key);

    // No usable address location: nothing to ask, and nothing can be ordered.
    if (location == null) {
      emit(QuickProductAvailabilityState(
        phase: QuickAvailabilityPhase.checked,
        key: key,
        availability: const QuickProductAvailability(
          status: QuickAvailabilityStatus.locationRequired,
        ),
      ));
      return;
    }

    emit(QuickProductAvailabilityState(
      phase: QuickAvailabilityPhase.checking,
      key: key,
    ));

    final result = await _check(
      CheckQuickProductAvailabilityParams(
        productId: productId,
        variantId: variantId,
        addressId: location.addressId,
        latitude: location.addressId == null ? location.latitude : null,
        longitude: location.addressId == null ? location.longitude : null,
      ),
    );
    if (isClosed || !_guard.isCurrent(token)) return;

    result.fold(
      (_) => emit(QuickProductAvailabilityState(
        phase: QuickAvailabilityPhase.failed,
        key: key,
      )),
      (availability) => emit(QuickProductAvailabilityState(
        phase: QuickAvailabilityPhase.checked,
        key: key,
        availability: availability,
      )),
    );
  }
}
