import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vector_store/vector_store_bloc.dart';
import '../../domain/entities/vector_store.dart';

class VectorStoreScreen extends StatelessWidget {
  const VectorStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vector Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VectorStoreBloc>().add(LoadVectorStores());
            },
          ),
        ],
      ),
      body: BlocBuilder<VectorStoreBloc, VectorStoreState>(
        builder: (context, state) {
            if (state is VectorStoreLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VectorStoreError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VectorStoreBloc>().add(LoadVectorStores());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is VectorStoreLoaded) {
              if (state.stores.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storage, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No Vector Stores',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a vector store to store embeddings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Store'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: state.stores.length,
                itemBuilder: (context, index) {
                  final store = state.stores[index];
                  return _VectorStoreCard(store: store);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Store'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Vector Store'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Store Name',
            hintText: 'e.g., Knowledge Base',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<VectorStoreBloc>().add(
                      CreateVectorStore(nameController.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _VectorStoreCard extends StatelessWidget {
  final VectorStore store;

  const _VectorStoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.storage, size: 40),
        title: Text(store.name),
        subtitle: Text('${store.documentCount} documents'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () {
                // TODO: Navigate to search screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Document',
              onPressed: () {
                _showAddDocumentDialog(context, store);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: () {
                _showDeleteDialog(context, store);
              },
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to store details
        },
      ),
    );
  }

  void _showAddDocumentDialog(BuildContext context, VectorStore store) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Document'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Document Text',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                context.read<VectorStoreBloc>().add(
                      AddDocument(
                        storeId: store.id,
                        text: textController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VectorStore store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vector Store'),
        content: Text('Are you sure you want to delete "${store.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VectorStoreBloc>().add(DeleteVectorStore(store.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

