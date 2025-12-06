import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/model_info.dart';

abstract class ModelManagerRepository {
  Future<Either<Failure, List<ModelInfo>>> getInstalledModels();
  Future<Either<Failure, ModelInfo>> getModelInfo(String name);
  Future<Either<Failure, ModelBenchmark>> benchmarkModel(String name);
  Future<Either<Failure, ModelInstallResult>> installModel(String name, String url);
  Future<Either<Failure, bool>> removeModel(String name);
}

class ModelBenchmark {
  final String modelName;
  final double tokensPerSecond;
  final double latencyMs;
  final int memoryMB;
  final int timestamp;

  ModelBenchmark({
    required this.modelName,
    required this.tokensPerSecond,
    required this.latencyMs,
    required this.memoryMB,
    required this.timestamp,
  });
}

class ModelInstallResult {
  final bool success;
  final String message;
  final String? error;

  ModelInstallResult({
    required this.success,
    required this.message,
    this.error,
  });
}

