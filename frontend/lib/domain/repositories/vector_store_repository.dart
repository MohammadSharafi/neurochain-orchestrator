import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/vector_store.dart';

abstract class VectorStoreRepository {
  Future<Either<Failure, List<VectorStore>>> getVectorStores();
  Future<Either<Failure, VectorStore>> createVectorStore(String name);
  Future<Either<Failure, bool>> addDocument(String storeId, String documentId, String text, Map<String, dynamic>? metadata);
  Future<Either<Failure, List<SearchResult>>> searchVectorStore(String storeId, String query, int topK);
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
}

