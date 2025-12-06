import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;

  MarketplaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MarketplaceItem>>> getMarketplaceItems(String? category) async {
    try {
      final items = await remoteDataSource.getMarketplaceItems(category);
      return Right(items.map((item) => MarketplaceItem(
        id: item.id,
        name: item.name,
        description: item.description,
        category: item.category,
        version: item.version,
        author: item.author,
        installed: item.installed,
      )).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarketplaceItem>> getMarketplaceItem(String id) async {
    try {
      final item = await remoteDataSource.getMarketplaceItem(id);
      return Right(MarketplaceItem(
        id: item.id,
        name: item.name,
        description: item.description,
        category: item.category,
        version: item.version,
        author: item.author,
        installed: item.installed,
      ));
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InstallationResult>> installMarketplaceItem(String itemId) async {
    try {
      final result = await remoteDataSource.installMarketplaceItem(itemId);
      return Right(InstallationResult(
        success: result.success,
        message: result.message,
        error: result.error,
      ));
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

