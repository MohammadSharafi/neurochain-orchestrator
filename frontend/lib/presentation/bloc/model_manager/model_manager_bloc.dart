import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/model_info.dart';

part 'model_manager_event.dart';
part 'model_manager_state.dart';

class ModelManagerBloc extends Bloc<ModelManagerEvent, ModelManagerState> {
  ModelManagerBloc() : super(ModelManagerInitial()) {
    on<LoadModels>(_onLoadModels);
    on<InstallModel>(_onInstallModel);
    on<RemoveModel>(_onRemoveModel);
    on<BenchmarkModel>(_onBenchmarkModel);
  }

  void _onLoadModels(LoadModels event, Emitter<ModelManagerState> emit) async {
    emit(ModelManagerLoading());
    try {
      // TODO: Load from GraphQL
      emit(ModelManagerLoaded(models: []));
    } catch (e) {
      emit(ModelManagerError(e.toString()));
    }
  }

  void _onInstallModel(InstallModel event, Emitter<ModelManagerState> emit) async {
    try {
      // TODO: Install via GraphQL
      emit(ModelManagerInstalling(event.modelName));
    } catch (e) {
      emit(ModelManagerError(e.toString()));
    }
  }

  void _onRemoveModel(RemoveModel event, Emitter<ModelManagerState> emit) async {
    try {
      // TODO: Remove via GraphQL
      add(LoadModels());
    } catch (e) {
      emit(ModelManagerError(e.toString()));
    }
  }

  void _onBenchmarkModel(BenchmarkModel event, Emitter<ModelManagerState> emit) async {
    try {
      // TODO: Benchmark via GraphQL
      emit(ModelManagerBenchmarking(event.modelName));
    } catch (e) {
      emit(ModelManagerError(e.toString()));
    }
  }
}

