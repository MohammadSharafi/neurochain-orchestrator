part of 'vector_store_bloc.dart';

abstract class VectorStoreEvent extends Equatable {
  const VectorStoreEvent();

  @override
  List<Object> get props => [];
}

class LoadVectorStores extends VectorStoreEvent {}

class CreateVectorStore extends VectorStoreEvent {
  final String name;

  const CreateVectorStore(this.name);

  @override
  List<Object> get props => [name];
}

class AddDocument extends VectorStoreEvent {
  final String storeId;
  final String text;
  final Map<String, dynamic>? metadata;

  const AddDocument({
    required this.storeId,
    required this.text,
    this.metadata,
  });

  @override
  List<Object?> get props => [storeId, text, metadata];
}

class DeleteVectorStore extends VectorStoreEvent {
  final String storeId;

  const DeleteVectorStore(this.storeId);

  @override
  List<Object> get props => [storeId];
}

