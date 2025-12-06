import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/repositories/fine_tuning_repository.dart';
import '../../../core/error/failures.dart';

part 'fine_tuning_event.dart';
part 'fine_tuning_state.dart';

class FineTuningBloc extends Bloc<FineTuningEvent, FineTuningState> {
  final FineTuningRepository repository;
  final List<FineTuningJob> _jobs = [];

  FineTuningBloc(this.repository) : super(FineTuningInitial()) {
    on<LoadFineTuningJobs>(_onLoadFineTuningJobs);
    on<StartFineTuning>(_onStartFineTuning);
    on<RefreshJob>(_onRefreshJob);
  }

  void _onLoadFineTuningJobs(
    LoadFineTuningJobs event,
    Emitter<FineTuningState> emit,
  ) async {
    emit(FineTuningLoading());
    // TODO: Load all jobs from backend
    // For now, use cached jobs
    emit(FineTuningLoaded(jobs: List.from(_jobs)));
  }

  void _onStartFineTuning(
    StartFineTuning event,
    Emitter<FineTuningState> emit,
  ) async {
    final result = await repository.startFineTuning(
      event.modelName,
      event.trainingDataPath,
      event.method,
    );
    result.fold(
      (failure) => emit(FineTuningError(_mapFailureToMessage(failure))),
      (job) {
        _jobs.add(job);
        add(LoadFineTuningJobs());
      },
    );
  }

  void _onRefreshJob(
    RefreshJob event,
    Emitter<FineTuningState> emit,
  ) async {
    final result = await repository.getFineTuningJob(event.jobId);
    result.fold(
      (failure) => emit(FineTuningError(_mapFailureToMessage(failure))),
      (job) {
        final index = _jobs.indexWhere((j) => j.jobId == job.jobId);
        if (index >= 0) {
          _jobs[index] = job;
        } else {
          _jobs.add(job);
        }
        add(LoadFineTuningJobs());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else {
      return 'Unexpected error: ${failure.message}';
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

