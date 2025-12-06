import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/fine_tuning_repository.dart';
import '../datasources/fine_tuning_remote_datasource.dart';

class FineTuningRepositoryImpl implements FineTuningRepository {
  final FineTuningRemoteDataSource remoteDataSource;

  FineTuningRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FineTuningJob>> getFineTuningJob(String jobId) async {
    try {
      final job = await remoteDataSource.getFineTuningJob(jobId);
      return Right(FineTuningJob(
        jobId: job.jobId,
        modelName: job.modelName,
        method: job.method,
        status: job.status,
        progress: job.progress,
        outputModelPath: job.outputModelPath,
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
  Future<Either<Failure, FineTuningJob>> startFineTuning(String modelName, String trainingDataPath, String method) async {
    try {
      final job = await remoteDataSource.startFineTuning(modelName, trainingDataPath, method);
      return Right(FineTuningJob(
        jobId: job.jobId,
        modelName: job.modelName,
        method: job.method,
        status: job.status,
        progress: job.progress,
        outputModelPath: job.outputModelPath,
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

