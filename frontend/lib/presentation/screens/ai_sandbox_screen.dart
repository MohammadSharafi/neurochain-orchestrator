import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_sandbox/ai_sandbox_bloc.dart';

class AISandboxScreen extends StatefulWidget {
  const AISandboxScreen({super.key});

  @override
  State<AISandboxScreen> createState() => _AISandboxScreenState();
}

class _AISandboxScreenState extends State<AISandboxScreen> {
  final _nodeTypeController = TextEditingController(text: 'AI_GENERATE');
  final _nodeNameController = TextEditingController(text: 'Test Node');
  final _inputsController = TextEditingController(text: '{"prompt": "Hello, world!"}');

  @override
  void dispose() {
    _nodeTypeController.dispose();
    _nodeNameController.dispose();
    _inputsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sandbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AISandboxBloc, AISandboxState>(
        builder: (context, state) => Column(
          children: [
            _buildNodeConfiguration(),
            const Divider(),
            Expanded(child: _buildExecutionArea(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeConfiguration() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Node Configuration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nodeTypeController,
            decoration: const InputDecoration(
              labelText: 'Node Type',
              hintText: 'AI_GENERATE, AI_TRANSCRIBE, etc.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nodeNameController,
            decoration: const InputDecoration(
              labelText: 'Node Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputsController,
            decoration: const InputDecoration(
              labelText: 'Inputs (JSON)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _executeNode(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Execute Node'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionArea(BuildContext context) {
    return BlocBuilder<AISandboxBloc, AISandboxState>(
      builder: (context, state) {
        if (state is AISandboxLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AISandboxError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _executeNode(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AISandboxResult) {
          return _buildResultView(state);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Ready to Test',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Configure a node and click Execute',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultView(AISandboxResult state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            'Execution Info',
            [
              _buildInfoRow('Execution ID', state.executionId),
              _buildInfoRow('Status', state.success ? 'Success' : 'Failed'),
              _buildInfoRow('Execution Time', '${state.executionTimeMs}ms'),
              if (state.latencyStats != null) ...[
                const Divider(),
                _buildInfoRow('Avg Latency', '${state.latencyStats!.averageMs.toStringAsFixed(2)}ms'),
                _buildInfoRow('Min Latency', '${state.latencyStats!.minMs.toStringAsFixed(2)}ms'),
                _buildInfoRow('Max Latency', '${state.latencyStats!.maxMs.toStringAsFixed(2)}ms'),
                _buildInfoRow('Samples', '${state.latencyStats!.sampleCount}'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildResultCard('Inputs', [
            _buildJsonView(state.inputs),
          ]),
          const SizedBox(height: 16),
          if (state.outputs != null)
            _buildResultCard('Outputs', [
              _buildJsonView(state.outputs!),
            ]),
          if (state.reasoning != null) ...[
            const SizedBox(height: 16),
            _buildResultCard('AI Reasoning', [
              _buildJsonView(state.reasoning!),
            ]),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildResultCard('Error', [
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildJsonView(Map<String, dynamic> json) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        _formatJson(json),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  void _executeNode(BuildContext context) {
    try {
      final inputs = Map<String, dynamic>.from(
        const JsonDecoder().convert(_inputsController.text),
      );

      context.read<AISandboxBloc>().add(
            ExecuteNode(
              nodeType: _nodeTypeController.text,
              nodeName: _nodeNameController.text,
              inputs: inputs,
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON: $e')),
      );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Sandbox Help'),
        content: const SingleChildScrollView(
          child: Text(
            'The AI Sandbox allows you to test individual nodes in isolation.\n\n'
            '1. Configure the node type (e.g., AI_GENERATE)\n'
            '2. Set the node name\n'
            '3. Provide inputs as JSON\n'
            '4. Click Execute to test\n\n'
            'You can inspect:\n'
            '- Inputs and outputs\n'
            '- AI reasoning (tokens, model info)\n'
            '- Execution latency\n'
            '- Performance statistics',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

