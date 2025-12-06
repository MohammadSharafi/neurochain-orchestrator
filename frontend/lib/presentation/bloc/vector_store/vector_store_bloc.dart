import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/vector_store.dart';
import '../../../domain/repositories/vector_store_repository.dart';
import '../../../core/error/failures.dart';

part 'vector_store_event.dart';
part 'vector_store_state.dart';

class VectorStoreBloc extends Bloc<VectorStoreEvent, VectorStoreState> {
  final VectorStoreRepository repository;

  VectorStoreBloc(this.repository) : super(VectorStoreInitial()) {
    on<LoadVectorStores>(_onLoadVectorStores);
    on<CreateVectorStore>(_onCreateVectorStore);
    on<AddDocument>(_onAddDocument);
    on<DeleteVectorStore>(_onDeleteVectorStore);
  }

  void _onLoadVectorStores(
    LoadVectorStores event,
    Emitter<VectorStoreState> emit,
  ) async {
    emit(VectorStoreLoading());
    final result = await repository.getVectorStores();
    result.fold(
      (failure) => emit(VectorStoreError(_mapFailureToMessage(failure))),
      (stores) => emit(VectorStoreLoaded(stores: stores)),
    );
  }

  void _onCreateVectorStore(
    CreateVectorStore event,
    Emitter<VectorStoreState> emit,
  ) async {
    final result = await repository.createVectorStore(event.name);
    result.fold(
      (failure) => emit(VectorStoreError(_mapFailureToMessage(failure))),
      (_) => add(LoadVectorStores()),
    );
  }

  void _onAddDocument(
    AddDocument event,
    Emitter<VectorStoreState> emit,
  ) async {
    final result = await repository.addDocument(
      event.storeId,
      'doc_${DateTime.now().millisecondsSinceEpoch}',
      event.text,
      event.metadata,
    );
    result.fold(
      (failure) => emit(VectorStoreError(_mapFailureToMessage(failure))),
      (_) => add(LoadVectorStores()),
    );
  }

  void _onDeleteVectorStore(
    DeleteVectorStore event,
    Emitter<VectorStoreState> emit,
  ) async {
    // TODO: Add delete mutation to GraphQL
    add(LoadVectorStores());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else {
      return 'Unexpected error: ${failure.message}';
    }
  }
}

