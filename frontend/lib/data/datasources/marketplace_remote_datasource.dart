import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/error/failures.dart';
import '../../graphql/queries.dart';
import '../../graphql/mutations.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<MarketplaceItem>> getMarketplaceItems(String? category);
  Future<MarketplaceItem> getMarketplaceItem(String id);
  Future<InstallationResult> installMarketplaceItem(String itemId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final GraphQLClient client;

  MarketplaceRemoteDataSourceImpl(this.client);

  @override
  Future<List<MarketplaceItem>> getMarketplaceItems(String? category) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.getMarketplaceItems),
        variables: category != null ? {'category': category} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      final items = (result.data?['marketplaceItems'] as List<dynamic>?)
              ?.map((json) => MarketplaceItem.fromJson(json))
              .toList() ??
          [];

      return items;
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch marketplace items: ${e.toString()}');
    }
  }

  @override
  Future<MarketplaceItem> getMarketplaceItem(String id) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(GraphQLQueries.marketplaceItem),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return MarketplaceItem.fromJson(
        result.data?['marketplaceItem'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch marketplace item: ${e.toString()}');
    }
  }

  @override
  Future<InstallationResult> installMarketplaceItem(String itemId) async {
    try {
      final result = await client.mutate(MutationOptions(
        document: gql(GraphQLMutations.installMarketplaceItem),
        variables: {'itemId': itemId},
      ));

      if (result.hasException) {
        throw ServerFailure(
          result.exception?.graphqlErrors.first.message ?? 'Unknown error',
        );
      }

      return InstallationResult.fromJson(
        result.data?['installMarketplaceItem'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to install marketplace item: ${e.toString()}');
    }
  }
}

class MarketplaceItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String version;
  final String author;
  final bool installed;

  MarketplaceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.version,
    required this.author,
    required this.installed,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      version: json['version'] as String,
      author: json['author'] as String,
      installed: json['installed'] as bool,
    );
  }
}

class InstallationResult {
  final bool success;
  final String message;
  final String? error;

  InstallationResult({
    required this.success,
    required this.message,
    this.error,
  });

  factory InstallationResult.fromJson(Map<String, dynamic> json) {
    return InstallationResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      error: json['error'] as String?,
    );
  }
}

