part of 'ai_sandbox_bloc.dart';

abstract class AISandboxEvent extends Equatable {
  const AISandboxEvent();

  @override
  List<Object> get props => [];
}

class LoadSandboxHistory extends AISandboxEvent {}

class ExecuteNode extends AISandboxEvent {
  final String nodeType;
  final String nodeName;
  final Map<String, dynamic> inputs;

  const ExecuteNode({
    required this.nodeType,
    required this.nodeName,
    required this.inputs,
  });

  @override
  List<Object> get props => [nodeType, nodeName, inputs];
}

