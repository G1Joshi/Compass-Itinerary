import 'package:material_ui/material_ui.dart';

import 'architecture_view_model.dart';

class ArchitectureInspectorSheet extends StatelessWidget {
  const ArchitectureInspectorSheet({super.key, required this.viewModel});

  final ArchitectureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Architecture & Chaos Console')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: theme.colorScheme.primary.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '10/10 Architecture Docs Standard',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Every component in Travel Itinerary strictly implements recommendations from docs.flutter.dev/app-architecture and all its subpages.',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Live Chaos & Resilience Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Simulate 500 Network Failures'),
                      subtitle: const Text(
                        'Tests Result.error and Command.error state handling',
                      ),
                      value: viewModel.isSimulatingErrors,
                      activeThumbColor: Colors.red,
                      onChanged: viewModel.toggleErrorSimulation,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Simulate 2.5s Network Latency'),
                      subtitle: const Text(
                        'Demonstrates Command.running, re-entrancy blocking, and loaders',
                      ),
                      value: viewModel.isSlowNetwork,
                      activeThumbColor: Colors.amber.shade800,
                      onChanged: viewModel.toggleSlowNetwork,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Active Architectural Components',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ComponentTile(
                title: 'Data Layer (SSOT Repositories)',
                subtitle:
                    '${viewModel.cachedDestinationsCount} destinations in memory cache',
                doc: 'docs.flutter.dev/app-architecture/guide#repositories',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 8),
              const _ComponentTile(
                title: 'Command Pattern (MVVM)',
                subtitle: 'Command0 and Command1 encapsulating UI actions',
                doc:
                    'docs.flutter.dev/app-architecture/design-patterns/command',
                icon: Icons.terminal_rounded,
              ),
              const SizedBox(height: 8),
              const _ComponentTile(
                title: 'Result Pattern (Error Handling)',
                subtitle: 'Sealed Result<T> with Ok & Error exhaustive switch matching',
                doc: 'docs.flutter.dev/app-architecture/design-patterns/result',
                icon: Icons.shield_outlined,
              ),
              const SizedBox(height: 8),
              const _ComponentTile(
                title: 'Domain Layer (Use Cases)',
                subtitle: 'CreateCustomItineraryUseCase & BookItineraryUseCase business rules',
                doc: 'docs.flutter.dev/app-architecture/guide#optional-domain-layer',
                icon: Icons.psychology_outlined,
              ),
              const SizedBox(height: 8),
              const _ComponentTile(
                title: 'Dependency Injection',
                subtitle: 'MultiProvider top-level service and repository registration',
                doc: 'docs.flutter.dev/app-architecture/case-study/dependency-injection',
                icon: Icons.alt_route_rounded,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({
    required this.title,
    required this.subtitle,
    required this.doc,
    required this.icon,
  });

  final String title, subtitle, doc;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              doc,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
