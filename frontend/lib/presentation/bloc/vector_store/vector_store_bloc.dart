import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/vector_store.dart';

part 'vector_store_event.dart';
part 'vector_store_state.dart';

class VectorStoreBloc extends Bloc<VectorStoreEvent, VectorStoreState> {
  VectorStoreBloc() : super(VectorStoreInitial()) {
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
    try {
      // TODO: Load from GraphQL
      await Future.delayed(const Duration(seconds: 1));
      emit(VectorStoreLoaded(stores: []));
    } catch (e) {
      emit(VectorStoreError(e.toString()));
    }
  }

  void _onCreateVectorStore(
    CreateVectorStore event,
    Emitter<VectorStoreState> emit,
  ) async {
    try {
      // TODO: Create via GraphQL mutation
      add(LoadVectorStores());
    } catch (e) {
      emit(VectorStoreError(e.toString()));
    }
  }

  void _onAddDocument(
    AddDocument event,
    Emitter<VectorStoreState> emit,
  ) async {
    try {
      // TODO: Add via GraphQL mutation
      add(LoadVectorStores());
    } catch (e) {
      emit(VectorStoreError(e.toString()));
    }
  }

  void _onDeleteVectorStore(
    DeleteVectorStore event,
    Emitter<VectorStoreState> emit,
  ) async {
    try {
      // TODO: Delete via GraphQL mutation
      add(LoadVectorStores());
    } catch (e) {
      emit(VectorStoreError(e.toString()));
    }
  }
}

