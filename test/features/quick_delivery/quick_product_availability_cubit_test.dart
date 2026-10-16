import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/entities/quick_delivery_tracking.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/repositories/quick_delivery_repository.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/usecases/check_quick_product_availability.dart';
import 'package:taksh_e_commerce/features/quick_delivery/presentation/cubit/quick_product_availability_cubit.dart';

class _Repo implements QuickDeliveryRepository {
  /// One completer per request, in call order.
  final List<Completer<Either<Failure, QuickProductAvailability>>> pending = [];
  final List<String?> askedAddressIds = [];

  @override
  ResultFuture<QuickProductAvailability> getProductAvailability({
    required int productId,
    int? variantId,
    String? addressId,
    double? latitude,
    double? longitude,
  }) {
    askedAddressIds.add(addressId);
    final c = Completer<Either<Failure, QuickProductAvailability>>();
    pending.add(c);
    return c.future;
  }

  @override
  ResultFuture<QuickDeliveryTracking> getDeliveryLocation(int orderId) =>
      throw UnimplementedError();
}

QuickLocation _loc(String id) => QuickLocation(
      latitude: 23.0,
      longitude: 72.5,
      addressId: id,
      source: QuickLocationSource.address,
    );

const _available =
    QuickProductAvailability(status: QuickAvailabilityStatus.available);
const _outOfArea =
    QuickProductAvailability(status: QuickAvailabilityStatus.areaUnserviceable);

void main() {
  late _Repo repo;
  late QuickProductAvailabilityCubit cubit;

  setUp(() {
    repo = _Repo();
    cubit = QuickProductAvailabilityCubit(
      checkQuickProductAvailability: CheckQuickProductAvailability(repo),
    );
  });
  tearDown(() => cubit.close());

  test('nothing can be ordered before a verdict exists', () {
    expect(cubit.state.canOrder, isFalse);
  });

  test('missing location fails closed without a request', () async {
    await cubit.check(productId: 1, variantId: 2, location: null);
    expect(repo.pending, isEmpty);
    expect(cubit.state.canOrder, isFalse);
    expect(cubit.state.availability!.status,
        QuickAvailabilityStatus.locationRequired);
  });

  test('loading and failed requests are never orderable', () async {
    final future = cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    expect(cubit.state.phase, QuickAvailabilityPhase.checking);
    expect(cubit.state.canOrder, isFalse);

    repo.pending.single.complete(const Left(ServerFailure('down')));
    await future;
    expect(cubit.state.phase, QuickAvailabilityPhase.failed);
    expect(cubit.state.canOrder, isFalse);
  });

  test('a fresh available verdict re-enables ordering', () async {
    final first = cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    repo.pending[0].complete(const Right(_outOfArea));
    await first;
    expect(cubit.state.canOrder, isFalse);

    final second = cubit.check(productId: 1, variantId: 2, location: _loc('b'));
    expect(cubit.state.canOrder, isFalse, reason: 'disabled while re-checking');
    repo.pending[1].complete(const Right(_available));
    await second;
    expect(cubit.state.canOrder, isTrue);
  });

  test('address change refreshes; a stale answer cannot replace it', () async {
    final a = cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    final b = cubit.check(productId: 1, variantId: 2, location: _loc('b'));
    expect(repo.askedAddressIds, ['a', 'b']);

    // the newer address answers first, the older (stale) one afterwards
    repo.pending[1].complete(const Right(_outOfArea));
    await b;
    repo.pending[0].complete(const Right(_available));
    await a;

    expect(cubit.state.availability!.status,
        QuickAvailabilityStatus.areaUnserviceable);
    expect(cubit.state.canOrder, isFalse);
  });

  test('the same query is not requested twice', () async {
    final f = cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    await cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    expect(repo.pending, hasLength(1));
    repo.pending[0].complete(const Right(_available));
    await f;
    await cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    expect(repo.pending, hasLength(1));

    final forced = cubit.check(
        productId: 1, variantId: 2, location: _loc('a'), force: true);
    expect(repo.pending, hasLength(2));
    repo.pending[1].complete(const Right(_outOfArea));
    await forced;
    expect(cubit.state.canOrder, isFalse, reason: 'stock changed: not orderable');
  });

  test('reset (non-Quick product) clears the verdict', () async {
    final f = cubit.check(productId: 1, variantId: 2, location: _loc('a'));
    repo.pending[0].complete(const Right(_available));
    await f;
    cubit.reset();
    expect(cubit.state.phase, QuickAvailabilityPhase.idle);
    expect(cubit.state.canOrder, isFalse);
  });
}
