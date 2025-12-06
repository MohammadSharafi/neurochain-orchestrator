part of 'ai_sandbox_bloc.dart';

abstract class AISandboxState extends Equatable {
  const AISandboxState();

  @override
  List<Object?> get props => [];
}

class AISandboxInitial extends AISandboxState {}

class AISandboxLoading extends AISandboxState {}

class AISandboxResult extends AISandboxState {
  final String executionId;
  final bool success;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic>? outputs;
  final Map<String, dynamic>? reasoning;
  final int executionTimeMs;
  final String? errorMessage;
  final LatencyStats? latencyStats;

  const AISandboxResult({
    required this.executionId,
    required this.success,
    required this.inputs,
    this.outputs,
    this.reasoning,
    required this.executionTimeMs,
    this.errorMessage,
    this.latencyStats,
  });

  @override
  List<Object?> get props => [
        executionId,
        success,
        inputs,
        outputs,
        reasoning,
        executionTimeMs,
        errorMessage,
        latencyStats,
      ];
}

class AISandboxError extends AISandboxState {
  final String message;

  const AISandboxError(this.message);

  @override
  List<Object> get props => [message];
}

