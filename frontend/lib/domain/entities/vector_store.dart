import 'package:equatable/equatable.dart';

class VectorStore extends Equatable {
  final String id;
  final String name;
  final int documentCount;

  const VectorStore({
    required this.id,
    required this.name,
    required this.documentCount,
  });

  @override
  List<Object> get props => [id, name, documentCount];
}

