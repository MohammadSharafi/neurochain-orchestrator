part of 'model_manager_bloc.dart';

abstract class ModelManagerState extends Equatable {
  const ModelManagerState();

  @override
  List<Object> get props => [];
}

class ModelManagerInitial extends ModelManagerState {}

class ModelManagerLoading extends ModelManagerState {}

class ModelManagerLoaded extends ModelManagerState {
  final List<ModelInfo> models;

  const ModelManagerLoaded({required this.models});

  @override
  List<Object> get props => [models];
}

class ModelManagerInstalling extends ModelManagerState {
  final String modelName;

  const ModelManagerInstalling(this.modelName);

  @override
  List<Object> get props => [modelName];
}

class ModelManagerBenchmarking extends ModelManagerState {
  final String modelName;

  const ModelManagerBenchmarking(this.modelName);

  @override
  List<Object> get props => [modelName];
}

class ModelManagerError extends ModelManagerState {
  final String message;

  const ModelManagerError(this.message);

  @override
  List<Object> get props => [message];
}

