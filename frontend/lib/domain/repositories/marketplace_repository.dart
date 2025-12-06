import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<MarketplaceItem>>> getMarketplaceItems(String? category);
  Future<Either<Failure, MarketplaceItem>> getMarketplaceItem(String id);
  Future<Either<Failure, InstallationResult>> installMarketplaceItem(String itemId);
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
}

