import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class FineTuningRepository {
  Future<Either<Failure, FineTuningJob>> getFineTuningJob(String jobId);
  Future<Either<Failure, FineTuningJob>> startFineTuning(String modelName, String trainingDataPath, String method);
}

class FineTuningJob {
  final String jobId;
  final String modelName;
  final String method;
  final String status;
  final double progress;
  final String? outputModelPath;

  FineTuningJob({
    required this.jobId,
    required this.modelName,
    required this.method,
    required this.status,
    required this.progress,
    this.outputModelPath,
  });
}

