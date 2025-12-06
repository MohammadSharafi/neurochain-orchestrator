import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/error/failures.dart';
import '../../graphql/queries.dart';
import '../../graphql/mutations.dart';
import '../models/vector_store_model.dart';

abstract class VectorStoreRemoteDataSource {
  Future<List<VectorStoreModel>> getVectorStores();
  Future<VectorStoreModel> createVectorStore(String name);
  Future<bool> addDocument(String storeId, String documentId, String text, Map<String, dynamic>? metadata);
  Future<List<SearchResult>> searchVectorStore(String storeId, String query, int topK);
}

class VectorStoreRemoteDataSourceImpl implements VectorStoreRemoteDataSource {
  final GraphQLClient client;

  VectorStoreRemoteDataSourceImpl(this.client);

  @override
  Future<List<VectorStoreModel>> getVectorStores() async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.getVectorStores),
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      final stores = (result.data?['vectorStores'] as List<dynamic>?)
              ?.map((json) => VectorStoreModel.fromJson(json))
              .toList() ??
          [];

      return stores;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch vector stores: ${e.toString()}');
    }
  }

  @override
  Future<VectorStoreModel> createVectorStore(String name) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.createVectorStore),
        variables: {'name': name},
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return VectorStoreModel.fromJson(
        result.data?['createVectorStore'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to create vector store: ${e.toString()}');
    }
  }

  @override
  Future<bool> addDocument(String storeId, String documentId, String text, Map<String, dynamic>? metadata) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.addDocument),
        variables: {
          'storeId': storeId,
          'documentId': documentId,
          'text': text,
          'metadata': metadata,
        },
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return result.data?['addDocument'] as bool? ?? false;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to add document: ${e.toString()}');
    }
  }

  @override
  Future<List<SearchResult>> searchVectorStore(String storeId, String query, int topK) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.searchVectorStore),
        variables: {
          'storeId': storeId,
          'query': query,
          'topK': topK,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      final results = (result.data?['searchVectorStore'] as List<dynamic>?)
              ?.map((json) => SearchResult.fromJson(json))
              .toList() ??
          [];

      return results;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to search vector store: ${e.toString()}');
    }
  }
}

class SearchResult {
  final String documentId;
  final String text;
  final double score;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.documentId,
    required this.text,
    required this.score,
    required this.metadata,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      documentId: json['documentId'] as String,
      text: json['text'] as String,
      score: (json['score'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

