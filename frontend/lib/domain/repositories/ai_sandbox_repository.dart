import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class AISandboxRepository {
  Future<Either<Failure, SandboxResult>> executeInSandbox(Map<String, dynamic> node, Map<String, dynamic> inputs);
}

class SandboxResult {
  final String executionId;
  final bool success;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic>? outputs;
  final Map<String, dynamic>? reasoning;
  final int executionTimeMs;
  final String? errorMessage;
  final LatencyStats? latencyStats;

  SandboxResult({
    required this.executionId,
    required this.success,
    required this.inputs,
    this.outputs,
    this.reasoning,
    required this.executionTimeMs,
    this.errorMessage,
    this.latencyStats,
  });
}

class LatencyStats {
  final double averageMs;
  final double minMs;
  final double maxMs;
  final int sampleCount;

  LatencyStats({
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
    required this.sampleCount,
  });
}

