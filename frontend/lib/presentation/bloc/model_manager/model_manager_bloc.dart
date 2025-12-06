import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/model_info.dart';
import '../../../domain/repositories/model_manager_repository.dart';
import '../../../core/error/failures.dart';

part 'model_manager_event.dart';
part 'model_manager_state.dart';

class ModelManagerBloc extends Bloc<ModelManagerEvent, ModelManagerState> {
  final ModelManagerRepository repository;

  ModelManagerBloc(this.repository) : super(ModelManagerInitial()) {
    on<LoadModels>(_onLoadModels);
    on<InstallModel>(_onInstallModel);
    on<RemoveModel>(_onRemoveModel);
    on<BenchmarkModel>(_onBenchmarkModel);
  }

  void _onLoadModels(LoadModels event, Emitter<ModelManagerState> emit) async {
    emit(ModelManagerLoading());
    final result = await repository.getInstalledModels();
    result.fold(
      (failure) => emit(ModelManagerError(_mapFailureToMessage(failure))),
      (models) => emit(ModelManagerLoaded(models: models)),
    );
  }

  void _onInstallModel(InstallModel event, Emitter<ModelManagerState> emit) async {
    emit(ModelManagerInstalling(event.modelName));
    final result = await repository.installModel(event.modelName, event.url);
    result.fold(
      (failure) => emit(ModelManagerError(_mapFailureToMessage(failure))),
      (installResult) {
        if (installResult.success) {
          add(LoadModels());
        } else {
          emit(ModelManagerError(installResult.error ?? installResult.message));
        }
      },
    );
  }

  void _onRemoveModel(RemoveModel event, Emitter<ModelManagerState> emit) async {
    final result = await repository.removeModel(event.modelName);
    result.fold(
      (failure) => emit(ModelManagerError(_mapFailureToMessage(failure))),
      (_) => add(LoadModels()),
    );
  }

  void _onBenchmarkModel(BenchmarkModel event, Emitter<ModelManagerState> emit) async {
    emit(ModelManagerBenchmarking(event.modelName));
    final result = await repository.benchmarkModel(event.modelName);
    result.fold(
      (failure) => emit(ModelManagerError(_mapFailureToMessage(failure))),
      (benchmark) {
        // TODO: Show benchmark results in a dialog or snackbar
        add(LoadModels()); // Reload to show updated state
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

