part of 'model_manager_bloc.dart';

abstract class ModelManagerEvent extends Equatable {
  const ModelManagerEvent();

  @override
  List<Object> get props => [];
}

class LoadModels extends ModelManagerEvent {}

class InstallModel extends ModelManagerEvent {
  final String modelName;
  final String url;

  const InstallModel(this.modelName, this.url);

  @override
  List<Object> get props => [modelName, url];
}

class RemoveModel extends ModelManagerEvent {
  final String modelName;

  const RemoveModel(this.modelName);

  @override
  List<Object> get props => [modelName];
}

class BenchmarkModel extends ModelManagerEvent {
  final String modelName;

  const BenchmarkModel(this.modelName);

  @override
  List<Object> get props => [modelName];
}

