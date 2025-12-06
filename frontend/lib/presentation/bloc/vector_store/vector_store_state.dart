part of 'vector_store_bloc.dart';

abstract class VectorStoreState extends Equatable {
  const VectorStoreState();

  @override
  List<Object> get props => [];
}

class VectorStoreInitial extends VectorStoreState {}

class VectorStoreLoading extends VectorStoreState {}

class VectorStoreLoaded extends VectorStoreState {
  final List<VectorStore> stores;

  const VectorStoreLoaded({required this.stores});

  @override
  List<Object> get props => [stores];
}

class VectorStoreError extends VectorStoreState {
  final String message;

  const VectorStoreError(this.message);

  @override
  List<Object> get props => [message];
}

