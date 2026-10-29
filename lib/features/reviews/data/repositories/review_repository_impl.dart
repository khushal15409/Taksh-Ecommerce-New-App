import 'package:dartz/dartz.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/network/network_info.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';
import 'package:taksh_e_commerce/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Runs [call] with the shared connectivity check and error mapping.
  ResultFuture<T> _guard<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    try {
      return Right(await call());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<PendingReviewItem>> getPending() =>
      _guard(remoteDataSource.getPending);

  @override
  ResultFuture<ReviewStatus> getStatus(int productId) =>
      _guard(() => remoteDataSource.getStatus(productId));

  @override
  ResultFuture<SubmittedReview> submit({
    required int productId,
    required int rating,
    String? title,
    String? text,
  }) =>
      _guard(
        () => remoteDataSource.submit(
          productId: productId,
          rating: rating,
          title: title,
          text: text,
        ),
      );
}
