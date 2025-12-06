part of 'fine_tuning_bloc.dart';

abstract class FineTuningState extends Equatable {
  const FineTuningState();

  @override
  List<Object> get props => [];
}

class FineTuningInitial extends FineTuningState {}

class FineTuningLoading extends FineTuningState {}

class FineTuningLoaded extends FineTuningState {
  final List<FineTuningJob> jobs;

  const FineTuningLoaded({required this.jobs});

  @override
  List<Object> get props => [jobs];
}

class FineTuningError extends FineTuningState {
  final String message;

  const FineTuningError(this.message);

  @override
  List<Object> get props => [message];
}

