import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/error/failures.dart';
import '../../graphql/mutations.dart';

abstract class AISandboxRemoteDataSource {
  Future<SandboxResult> executeInSandbox(Map<String, dynamic> node, Map<String, dynamic> inputs);
}

class AISandboxRemoteDataSourceImpl implements AISandboxRemoteDataSource {
  final GraphQLClient client;

  AISandboxRemoteDataSourceImpl(this.client);

  @override
  Future<SandboxResult> executeInSandbox(Map<String, dynamic> node, Map<String, dynamic> inputs) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.executeInSandbox),
        variables: {
          'node': node,
          'inputs': inputs,
        },
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return SandboxResult.fromJson(
        result.data?['executeInSandbox'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to execute in sandbox: ${e.toString()}');
    }
  }
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

  factory SandboxResult.fromJson(Map<String, dynamic> json) {
    return SandboxResult(
      executionId: json['executionId'] as String,
      success: json['success'] as bool,
      inputs: json['inputs'] as Map<String, dynamic>,
      outputs: json['outputs'] as Map<String, dynamic>?,
      reasoning: json['reasoning'] as Map<String, dynamic>?,
      executionTimeMs: json['executionTimeMs'] as int,
      errorMessage: json['errorMessage'] as String?,
      latencyStats: json['latencyStats'] != null
          ? LatencyStats.fromJson(json['latencyStats'] as Map<String, dynamic>)
          : null,
    );
  }
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

  factory LatencyStats.fromJson(Map<String, dynamic> json) {
    return LatencyStats(
      averageMs: (json['averageMs'] as num).toDouble(),
      minMs: (json['minMs'] as num).toDouble(),
      maxMs: (json['maxMs'] as num).toDouble(),
      sampleCount: json['sampleCount'] as int,
    );
  }
}

