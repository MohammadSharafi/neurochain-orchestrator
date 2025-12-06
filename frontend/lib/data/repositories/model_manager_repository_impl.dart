import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/repositories/model_manager_repository.dart';
import '../datasources/model_manager_remote_datasource.dart';
import '../models/model_info_model.dart';

class ModelManagerRepositoryImpl implements ModelManagerRepository {
  final ModelManagerRemoteDataSource remoteDataSource;

  ModelManagerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ModelInfo>>> getInstalledModels() async {
    try {
      final models = await remoteDataSource.getInstalledModels();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModelInfo>> getModelInfo(String name) async {
    try {
      final model = await remoteDataSource.getModelInfo(name);
      return Right(model.toEntity());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModelBenchmark>> benchmarkModel(String name) async {
    try {
      final benchmark = await remoteDataSource.benchmarkModel(name);
      return Right(benchmark);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModelInstallResult>> installModel(String name, String url) async {
    try {
      final result = await remoteDataSource.installModel(name, url);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeModel(String name) async {
    try {
      final result = await remoteDataSource.removeModel(name);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

