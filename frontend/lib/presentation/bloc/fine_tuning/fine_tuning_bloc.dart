import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'fine_tuning_event.dart';
part 'fine_tuning_state.dart';

class FineTuningBloc extends Bloc<FineTuningEvent, FineTuningState> {
  FineTuningBloc() : super(FineTuningInitial()) {
    on<LoadFineTuningJobs>(_onLoadFineTuningJobs);
    on<StartFineTuning>(_onStartFineTuning);
    on<RefreshJob>(_onRefreshJob);
  }

  void _onLoadFineTuningJobs(
    LoadFineTuningJobs event,
    Emitter<FineTuningState> emit,
  ) async {
    emit(FineTuningLoading());
    try {
      // TODO: Load from GraphQL
      await Future.delayed(const Duration(seconds: 1));
      emit(FineTuningLoaded(jobs: []));
    } catch (e) {
      emit(FineTuningError(e.toString()));
    }
  }

  void _onStartFineTuning(
    StartFineTuning event,
    Emitter<FineTuningState> emit,
  ) async {
    try {
      // TODO: Start via GraphQL mutation
      add(LoadFineTuningJobs());
    } catch (e) {
      emit(FineTuningError(e.toString()));
    }
  }

  void _onRefreshJob(
    RefreshJob event,
    Emitter<FineTuningState> emit,
  ) async {
    try {
      // TODO: Refresh job status via GraphQL
      add(LoadFineTuningJobs());
    } catch (e) {
      emit(FineTuningError(e.toString()));
    }
  }
}

class FineTuningJob {
  final String jobId;
  final String modelName;
  final String method;
  final String status;
  final double progress;
  final String? outputModelPath;

  FineTuningJob({
    required this.jobId,
    required this.modelName,
    required this.method,
    required this.status,
    required this.progress,
    this.outputModelPath,
  });
}

