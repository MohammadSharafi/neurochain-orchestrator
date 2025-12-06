import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/ai_sandbox_repository.dart';
import '../datasources/ai_sandbox_remote_datasource.dart';

class AISandboxRepositoryImpl implements AISandboxRepository {
  final AISandboxRemoteDataSource remoteDataSource;

  AISandboxRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SandboxResult>> executeInSandbox(Map<String, dynamic> node, Map<String, dynamic> inputs) async {
    try {
      final result = await remoteDataSource.executeInSandbox(node, inputs);
      return Right(SandboxResult(
        executionId: result.executionId,
        success: result.success,
        inputs: result.inputs,
        outputs: result.outputs,
        reasoning: result.reasoning,
        executionTimeMs: result.executionTimeMs,
        errorMessage: result.errorMessage,
        latencyStats: result.latencyStats != null
            ? LatencyStats(
                averageMs: result.latencyStats!.averageMs,
                minMs: result.latencyStats!.minMs,
                maxMs: result.latencyStats!.maxMs,
                sampleCount: result.latencyStats!.sampleCount,
              )
            : null,
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

