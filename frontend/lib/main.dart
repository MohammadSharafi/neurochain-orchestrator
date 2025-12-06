import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql/graphql_client.dart';
import 'presentation/bloc/model_manager/model_manager_bloc.dart';
import 'presentation/bloc/ai_sandbox/ai_sandbox_bloc.dart';
import 'presentation/bloc/vector_store/vector_store_bloc.dart';
import 'presentation/bloc/fine_tuning/fine_tuning_bloc.dart';
import 'presentation/bloc/marketplace/marketplace_bloc.dart';
import 'presentation/screens/model_manager_screen.dart';
import 'presentation/screens/ai_sandbox_screen.dart';
import 'presentation/screens/vector_store_screen.dart';
import 'presentation/screens/fine_tuning_screen.dart';
import 'presentation/screens/marketplace_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeuroChainApp());
}

class NeuroChainApp extends StatelessWidget {
  const NeuroChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = GraphQLClientProvider.createClient();

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp(
        title: 'NeuroChain Orchestrator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ModelManagerBloc()..add(LoadModels())),
          ],
          child: const HomeScreen(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroChain'),
        elevation: 2,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _FeatureCard(
            title: 'Model Manager',
            icon: Icons.model_training,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ModelManagerScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            title: 'AI Sandbox',
            icon: Icons.science,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AISandboxScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            title: 'Vector Stores',
            icon: Icons.storage,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VectorStoreScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            title: 'Fine-Tuning',
            icon: Icons.train,
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FineTuningScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            title: 'Marketplace',
            icon: Icons.store,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MarketplaceScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            title: 'Workflows',
            icon: Icons.account_tree,
            color: Colors.purple,
            onTap: () {
              // TODO: Navigate to Workflows
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

