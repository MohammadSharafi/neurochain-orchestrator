import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'ai_sandbox_event.dart';
part 'ai_sandbox_state.dart';

class AISandboxBloc extends Bloc<AISandboxEvent, AISandboxState> {
  AISandboxBloc() : super(AISandboxInitial()) {
    on<LoadSandboxHistory>(_onLoadSandboxHistory);
    on<ExecuteNode>(_onExecuteNode);
  }

  void _onLoadSandboxHistory(
    LoadSandboxHistory event,
    Emitter<AISandboxState> emit,
  ) async {
    // TODO: Load from GraphQL
    emit(AISandboxInitial());
  }

  void _onExecuteNode(
    ExecuteNode event,
    Emitter<AISandboxState> emit,
  ) async {
    emit(AISandboxLoading());
    try {
      // TODO: Execute via GraphQL mutation
      // For now, simulate result
      await Future.delayed(const Duration(seconds: 2));
      
      emit(AISandboxResult(
        executionId: 'exec_${DateTime.now().millisecondsSinceEpoch}',
        success: true,
        inputs: event.inputs,
        outputs: {'result': 'Mock output'},
        reasoning: {
          'model': 'llama',
          'inputTokens': 10,
          'outputTokens': 20,
        },
        executionTimeMs: 1500,
        latencyStats: LatencyStats(
          averageMs: 1500.0,
          minMs: 1200.0,
          maxMs: 1800.0,
          sampleCount: 5,
        ),
      ));
    } catch (e) {
      emit(AISandboxError(e.toString()));
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

