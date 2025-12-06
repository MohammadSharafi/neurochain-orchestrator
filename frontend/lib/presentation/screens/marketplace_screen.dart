import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/marketplace/marketplace_bloc.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MarketplaceBloc>().add(LoadMarketplaceItems());
            },
          ),
        ],
      ),
      body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) => Column(
          children: [
            _buildCategoryFilter(context),
            const Divider(),
            Expanded(child: _buildItemList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'All',
                selected: state.selectedCategory == null,
                onTap: () {
                  context.read<MarketplaceBloc>().add(FilterByCategory(null));
                },
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Plugins',
                selected: state.selectedCategory == 'PLUGIN',
                onTap: () {
                  context.read<MarketplaceBloc>().add(FilterByCategory('PLUGIN'));
                },
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Node Packs',
                selected: state.selectedCategory == 'NODE_PACK',
                onTap: () {
                  context.read<MarketplaceBloc>().add(FilterByCategory('NODE_PACK'));
                },
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: 'Templates',
                selected: state.selectedCategory == 'TEMPLATE',
                onTap: () {
                  context.read<MarketplaceBloc>().add(FilterByCategory('TEMPLATE'));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemList(BuildContext context) {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        if (state is MarketplaceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MarketplaceError) {
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
                    context.read<MarketplaceBloc>().add(LoadMarketplaceItems());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is MarketplaceLoaded) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Items Available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _MarketplaceItemCard(item: item);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item;

  const _MarketplaceItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getCategoryIcon(item.category)),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(item.category),
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 8),
                Text(
                  'v${item.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  'by ${item.author}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: item.installed
            ? const Chip(
                label: Text('Installed'),
                backgroundColor: Colors.green,
              )
            : ElevatedButton(
                onPressed: () {
                  context.read<MarketplaceBloc>().add(InstallItem(item.id));
                },
                child: const Text('Install'),
              ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'PLUGIN':
        return Icons.extension;
      case 'NODE_PACK':
        return Icons.widgets;
      case 'TEMPLATE':
        return Icons.description;
      case 'MODEL_BUNDLE':
        return Icons.model_training;
      default:
        return Icons.category;
    }
  }
}

