import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/vector_store.dart';
import '../../domain/repositories/vector_store_repository.dart';
import '../datasources/vector_store_remote_datasource.dart';
import '../models/vector_store_model.dart';

class VectorStoreRepositoryImpl implements VectorStoreRepository {
  final VectorStoreRemoteDataSource remoteDataSource;

  VectorStoreRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<VectorStore>>> getVectorStores() async {
    try {
      final stores = await remoteDataSource.getVectorStores();
      return Right(stores.map((s) => s.toEntity()).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VectorStore>> createVectorStore(String name) async {
    try {
      final store = await remoteDataSource.createVectorStore(name);
      return Right(store.toEntity());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addDocument(String storeId, String documentId, String text, Map<String, dynamic>? metadata) async {
    try {
      final result = await remoteDataSource.addDocument(storeId, documentId, text, metadata);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchVectorStore(String storeId, String query, int topK) async {
    try {
      final results = await remoteDataSource.searchVectorStore(storeId, query, topK);
      return Right(results.map((r) => SearchResult(
        documentId: r.documentId,
        text: r.text,
        score: r.score,
        metadata: r.metadata,
      )).toList());
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

