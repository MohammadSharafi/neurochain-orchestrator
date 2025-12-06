import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/repositories/ai_sandbox_repository.dart';
import '../../../core/error/failures.dart';

part 'ai_sandbox_event.dart';
part 'ai_sandbox_state.dart';

class AISandboxBloc extends Bloc<AISandboxEvent, AISandboxState> {
  final AISandboxRepository repository;

  AISandboxBloc(this.repository) : super(AISandboxInitial()) {
    on<LoadSandboxHistory>(_onLoadSandboxHistory);
    on<ExecuteNode>(_onExecuteNode);
  }

  void _onLoadSandboxHistory(
    LoadSandboxHistory event,
    Emitter<AISandboxState> emit,
  ) async {
    // TODO: Load history from GraphQL
    emit(AISandboxInitial());
  }

  void _onExecuteNode(
    ExecuteNode event,
    Emitter<AISandboxState> emit,
  ) async {
    emit(AISandboxLoading());
    
    final node = {
      'id': 'node_${DateTime.now().millisecondsSinceEpoch}',
      'type': event.nodeType,
      'name': event.nodeName,
      'parameters': {},
    };

    final result = await repository.executeInSandbox(node, event.inputs);
    result.fold(
      (failure) => emit(AISandboxError(_mapFailureToMessage(failure))),
      (sandboxResult) => emit(AISandboxResult(
        executionId: sandboxResult.executionId,
        success: sandboxResult.success,
        inputs: sandboxResult.inputs,
        outputs: sandboxResult.outputs,
        reasoning: sandboxResult.reasoning,
        executionTimeMs: sandboxResult.executionTimeMs,
        errorMessage: sandboxResult.errorMessage,
        latencyStats: sandboxResult.latencyStats != null
            ? LatencyStats(
                averageMs: sandboxResult.latencyStats!.averageMs,
                minMs: sandboxResult.latencyStats!.minMs,
                maxMs: sandboxResult.latencyStats!.maxMs,
                sampleCount: sandboxResult.latencyStats!.sampleCount,
              )
            : null,
      )),
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

class LatencyStats {
  final double averageMs;
  final double minMs;
  final double maxMs;
  final int sampleCount;

  LatencyStats({
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
    required this.sampleCount,
  });
}

