import 'package:dartz/dartz.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/quick_availability.dart';
import 'package:taksh_e_commerce/features/quick_delivery/data/datasources/quick_delivery_remote_datasource.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/entities/quick_delivery_tracking.dart';
import 'package:taksh_e_commerce/features/quick_delivery/domain/repositories/quick_delivery_repository.dart';

class QuickDeliveryRepositoryImpl implements QuickDeliveryRepository {
  final QuickDeliveryRemoteDatasource _remoteDatasource;

  QuickDeliveryRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, QuickProductAvailability>> getProductAvailability({
    required int productId,
    int? variantId,
    String? addressId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = await _remoteDatasource.getProductAvailability(
        productId: productId,
        variantId: variantId,
        addressId: addressId,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check availability: $e'));
    }
  }

  @override
  Future<Either<Failure, QuickDeliveryTracking>> getDeliveryLocation(
    int orderId,
  ) async {
    try {
      final data = await _remoteDatasource.getDeliveryLocation(orderId);
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load delivery location: $e'));
    }
  }
}
