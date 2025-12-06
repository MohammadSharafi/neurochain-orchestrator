part of 'fine_tuning_bloc.dart';

abstract class FineTuningEvent extends Equatable {
  const FineTuningEvent();

  @override
  List<Object> get props => [];
}

class LoadFineTuningJobs extends FineTuningEvent {}

class StartFineTuning extends FineTuningEvent {
  final String modelName;
  final String trainingDataPath;
  final String method;

  const StartFineTuning({
    required this.modelName,
    required this.trainingDataPath,
    required this.method,
  });

  @override
  List<Object> get props => [modelName, trainingDataPath, method];
}

class RefreshJob extends FineTuningEvent {
  final String jobId;

  const RefreshJob(this.jobId);

  @override
  List<Object> get props => [jobId];
}

