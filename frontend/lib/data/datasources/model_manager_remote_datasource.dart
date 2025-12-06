import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/error/failures.dart';
import '../../graphql/queries.dart';
import '../../graphql/mutations.dart';
import '../models/model_info_model.dart';

abstract class ModelManagerRemoteDataSource {
  Future<List<ModelInfoModel>> getInstalledModels();
  Future<ModelInfoModel> getModelInfo(String name);
  Future<ModelBenchmark> benchmarkModel(String name);
  Future<ModelInstallResult> installModel(String name, String url);
  Future<bool> removeModel(String name);
}

class ModelManagerRemoteDataSourceImpl implements ModelManagerRemoteDataSource {
  final GraphQLClient client;

  ModelManagerRemoteDataSourceImpl(this.client);

  @override
  Future<List<ModelInfoModel>> getInstalledModels() async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.getInstalledModels),
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      final models = (result.data?['installedModels'] as List<dynamic>?)
              ?.map((json) => ModelInfoModel.fromJson(json))
              .toList() ??
          [];

      return models;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch models: ${e.toString()}');
    }
  }

  @override
  Future<ModelInfoModel> getModelInfo(String name) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.getModelInfo),
        variables: {'name': name},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return ModelInfoModel.fromJson(result.data?['modelInfo'] as Map<String, dynamic>);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch model info: ${e.toString()}');
    }
  }

  @override
  Future<ModelBenchmark> benchmarkModel(String name) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.benchmarkModel),
        variables: {'name': name},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return ModelBenchmark.fromJson(result.data?['benchmarkModel'] as Map<String, dynamic>);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to benchmark model: ${e.toString()}');
    }
  }

  @override
  Future<ModelInstallResult> installModel(String name, String url) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.installModel),
        variables: {
          'name': name,
          'url': url,
        },
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return ModelInstallResult.fromJson(
        result.data?['installModel'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to install model: ${e.toString()}');
    }
  }

  @override
  Future<bool> removeModel(String name) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.removeModel),
        variables: {'name': name},
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return result.data?['removeModel'] as bool? ?? false;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to remove model: ${e.toString()}');
    }
  }
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

  factory ModelBenchmark.fromJson(Map<String, dynamic> json) {
    return ModelBenchmark(
      modelName: json['modelName'] as String,
      tokensPerSecond: (json['tokensPerSecond'] as num).toDouble(),
      latencyMs: (json['latencyMs'] as num).toDouble(),
      memoryMB: json['memoryMB'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
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

  factory ModelInstallResult.fromJson(Map<String, dynamic> json) {
    return ModelInstallResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      error: json['error'] as String?,
    );
  }
}

