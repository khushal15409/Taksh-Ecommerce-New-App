import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home/data/models/express_dashboard_model.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/express_dashboard_entity.dart';
import 'package:taksh_e_commerce/features/home/domain/repositories/express_dashboard_repository.dart';
import 'package:taksh_e_commerce/features/home/domain/usecases/get_express_dashboard_usecase.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_bloc.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_event.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_state.dart';

class _FakeRepo implements ExpressDashboardRepository {
  final List<ExpressDashboardEntity> responses;
  int calls = 0;
  _FakeRepo(this.responses);

  @override
  ResultFuture<ExpressDashboardEntity> getExpressDashboard({
    required double latitude,
    required double longitude,
    required String pincode,
  }) async =>
      Right(responses[calls++]);
}

Map<String, dynamic> _payload({required bool serviceable}) => {
      'vendors': {'id': 0, 'name': ''},
      if (!serviceable) ...{
        'serviceable': false,
        'code': 'quick_not_serviceable',
        'message': 'Not here',
      },
      'sections': [
        {'key': 'Logo', 'data': []},
        {
          'key': 'Fresh',
          'data': [
            {
              'id': 1,
              'name': 'Milk',
              'price': 50,
              'original_price': 50,
              'in_stock': false,
              'availability': {'status': 'area_unserviceable'},
            },
          ],
        },
      ],
    };

const _event = ExpressDashboardLoadRequested(
  latitude: 23.0,
  longitude: 72.5,
  pincode: '380001',
);

void main() {
  blocTest<ExpressDashboardBloc, ExpressDashboardState>(
    'unserviceable address with a catalogue shows the products (unavailable)',
    build: () => ExpressDashboardBloc(
      getExpressDashboardUseCase: GetExpressDashboardUseCase(_FakeRepo([
        ExpressDashboardModel.fromJson(_payload(serviceable: false)),
      ])),
    ),
    act: (bloc) => bloc.add(_event),
    expect: () => [
      isA<ExpressDashboardLoading>(),
      isA<ExpressDashboardLoaded>()
          .having((s) => s.dashboard.serviceable, 'serviceable', false),
    ],
  );

  blocTest<ExpressDashboardBloc, ExpressDashboardState>(
    'unserviceable address with no catalogue keeps the not-serviceable screen',
    build: () => ExpressDashboardBloc(
      getExpressDashboardUseCase: GetExpressDashboardUseCase(_FakeRepo([
        ExpressDashboardModel.fromJson({
          'serviceable': false,
          'code': 'quick_not_serviceable',
          'sections': [],
        }),
      ])),
    ),
    act: (bloc) => bloc.add(_event),
    expect: () => [
      isA<ExpressDashboardLoading>(),
      isA<ExpressDashboardNotServiceable>(),
    ],
  );

  blocTest<ExpressDashboardBloc, ExpressDashboardState>(
    'a new address replaces the result (refresh re-ranks the catalogue)',
    build: () => ExpressDashboardBloc(
      getExpressDashboardUseCase: GetExpressDashboardUseCase(_FakeRepo([
        ExpressDashboardModel.fromJson(_payload(serviceable: false)),
        ExpressDashboardModel.fromJson(_payload(serviceable: true)),
      ])),
    ),
    act: (bloc) async {
      bloc.add(_event);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ExpressDashboardLoadRequested(
        latitude: 23.1,
        longitude: 72.6,
        pincode: '380002',
      ));
    },
    expect: () => [
      isA<ExpressDashboardLoading>(),
      isA<ExpressDashboardLoaded>(),
      isA<ExpressDashboardLoading>(),
      isA<ExpressDashboardLoaded>()
          .having((s) => s.dashboard.serviceable, 'serviceable', true),
    ],
  );

  test('failure still surfaces as an error state', () async {
    final bloc = ExpressDashboardBloc(
      getExpressDashboardUseCase: GetExpressDashboardUseCase(_FailRepo()),
    );
    bloc.add(_event);
    await expectLater(
      bloc.stream,
      emitsInOrder([isA<ExpressDashboardLoading>(), isA<ExpressDashboardError>()]),
    );
    await bloc.close();
  });
}

class _FailRepo implements ExpressDashboardRepository {
  @override
  ResultFuture<ExpressDashboardEntity> getExpressDashboard({
    required double latitude,
    required double longitude,
    required String pincode,
  }) async =>
      const Left(ServerFailure('boom'));
}
