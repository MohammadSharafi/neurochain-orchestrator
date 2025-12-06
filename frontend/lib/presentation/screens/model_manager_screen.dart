import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/model_manager/model_manager_bloc.dart';
import '../../domain/entities/model_info.dart';

class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ModelManagerBloc>().add(LoadModels());
            },
          ),
        ],
      ),
      body: BlocBuilder<ModelManagerBloc, ModelManagerState>(
        builder: (context, state) {
          if (state is ModelManagerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ModelManagerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ModelManagerBloc>().add(LoadModels());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ModelManagerLoaded) {
            if (state.models.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.model_training, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Models Installed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Install models to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showInstallDialog(context);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Install Model'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.models.length,
              itemBuilder: (context, index) {
                final model = state.models[index];
                return _ModelCard(model: model);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showInstallDialog(context);
        },
        icon: const Icon(Icons.download),
        label: const Text('Install Model'),
      ),
    );
  }

  void _showInstallDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: 'e.g., llama-7b',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Model URL',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                context.read<ModelManagerBloc>().add(
                      InstallModel(nameController.text, urlController.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final ModelInfo model;

  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.model_training, size: 40),
        title: Text(model.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Size: ${_formatBytes(model.sizeBytes)}'),
            Text('Path: ${model.path}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.speed),
              tooltip: 'Benchmark',
              onPressed: () {
                context.read<ModelManagerBloc>().add(BenchmarkModel(model.name));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Remove',
              onPressed: () {
                _showDeleteDialog(context, model);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _showDeleteDialog(BuildContext context, ModelInfo model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Model'),
        content: Text('Are you sure you want to remove ${model.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ModelManagerBloc>().add(RemoveModel(model.name));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

