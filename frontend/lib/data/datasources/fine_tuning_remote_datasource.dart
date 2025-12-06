import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/error/failures.dart';
import '../../graphql/queries.dart';
import '../../graphql/mutations.dart';

abstract class FineTuningRemoteDataSource {
  Future<FineTuningJob> getFineTuningJob(String jobId);
  Future<FineTuningJob> startFineTuning(String modelName, String trainingDataPath, String method);
}

class FineTuningRemoteDataSourceImpl implements FineTuningRemoteDataSource {
  final GraphQLClient client;

  FineTuningRemoteDataSourceImpl(this.client);

  @override
  Future<FineTuningJob> getFineTuningJob(String jobId) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.getFineTuningJob),
        variables: {'jobId': jobId},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return FineTuningJob.fromJson(
        result.data?['fineTuningJob'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to get fine-tuning job: ${e.toString()}');
    }
  }

  @override
  Future<FineTuningJob> startFineTuning(String modelName, String trainingDataPath, String method) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.startFineTuning),
        variables: {
          'input': {
            'modelName': modelName,
            'trainingDataPath': trainingDataPath,
            'method': method,
          },
        },
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return FineTuningJob.fromJson(
        result.data?['startFineTuning'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to start fine-tuning: ${e.toString()}');
    }
  }
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

  factory FineTuningJob.fromJson(Map<String, dynamic> json) {
    return FineTuningJob(
      jobId: json['jobId'] as String,
      modelName: json['modelName'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      outputModelPath: json['outputModelPath'] as String?,
    );
  }
}

