import 'package:equatable/equatable.dart';

class ModelInfo extends Equatable {
  final String name;
  final bool installed;
  final int sizeBytes;
  final String path;

  const ModelInfo({
    required this.name,
    required this.installed,
    required this.sizeBytes,
    required this.path,
  });

  @override
  List<Object> get props => [name, installed, sizeBytes, path];
}

