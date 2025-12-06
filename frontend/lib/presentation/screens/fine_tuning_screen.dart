import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/fine_tuning/fine_tuning_bloc.dart';

class FineTuningScreen extends StatelessWidget {
  const FineTuningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fine-Tuning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FineTuningBloc>().add(LoadFineTuningJobs());
            },
          ),
        ],
      ),
      body: BlocBuilder<FineTuningBloc, FineTuningState>(
        builder: (context, state) => Column(
          children: [
            _buildJobList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartFineTuningDialog(context),
        icon: const Icon(Icons.train),
        label: const Text('Start Fine-Tuning'),
      ),
    );
  }

  Widget _buildJobList(BuildContext context) {
    return BlocBuilder<FineTuningBloc, FineTuningState>(
      builder: (context, state) {
        if (state is FineTuningLoading) {
          return const Expanded(child: Center(child: CircularProgressIndicator()));
        }

        if (state is FineTuningError) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FineTuningBloc>().add(LoadFineTuningJobs());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is FineTuningLoaded) {
          if (state.jobs.isEmpty) {
            return Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.train, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Fine-Tuning Jobs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a fine-tuning job to train models',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            child: ListView.builder(
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                final job = state.jobs[index];
                return _FineTuningJobCard(job: job);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showStartFineTuningDialog(BuildContext context) {
    final modelController = TextEditingController();
    final dataPathController = TextEditingController();
    String selectedMethod = 'LORA';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Start Fine-Tuning'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'e.g., llama-7b',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dataPathController,
                  decoration: const InputDecoration(
                    labelText: 'Training Data Path',
                    hintText: './data/training',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'LORA', child: Text('LoRA')),
                    DropdownMenuItem(value: 'EMBEDDING', child: Text('Embedding')),
                    DropdownMenuItem(value: 'SUPERVISED', child: Text('Supervised')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedMethod = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (modelController.text.isNotEmpty &&
                    dataPathController.text.isNotEmpty) {
                  context.read<FineTuningBloc>().add(
                        StartFineTuning(
                          modelName: modelController.text,
                          trainingDataPath: dataPathController.text,
                          method: selectedMethod,
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FineTuningJobCard extends StatelessWidget {
  final FineTuningJob job;

  const _FineTuningJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(job.status),
                  color: _getStatusColor(job.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.modelName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(job.status),
                  backgroundColor: _getStatusColor(job.status)?.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Job ID', job.jobId),
            _buildInfoRow('Method', job.method),
            _buildInfoRow('Progress', '${(job.progress * 100).toStringAsFixed(1)}%'),
            if (job.outputModelPath != null)
              _buildInfoRow('Output', job.outputModelPath!),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: job.progress,
              backgroundColor: Colors.grey[300],
            ),
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
            width: 100,
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'RUNNING':
        return Icons.refresh;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  Color? _getStatusColor(String status) {
    switch (status) {
      case 'RUNNING':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

