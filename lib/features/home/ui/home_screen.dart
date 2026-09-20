import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../../data/models/itinerary.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.onNavigateToBuilder,
    required this.onNavigateToExplore,
  });

  final HomeViewModel viewModel;
  final VoidCallback onNavigateToBuilder;
  final VoidCallback onNavigateToExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass Itinerary'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel.loadHome,
        builder: (context, child) {
          if (viewModel.loadHome.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.loadHome.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load trips: ${viewModel.loadHome.errorException}',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadHome.execute(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final user = viewModel.user;
            final bookings = viewModel.bookings;
            final confirmed = bookings
                .where((b) => b.status == BookingStatus.confirmed)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // User Profile Header Card
                Card(
                  color: theme.colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white24,
                          foregroundImage: NetworkImage(user.avatarUrl),
                          onForegroundImageError: (_, _) {},
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.membershipTier.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Quick Statistics Row
                Row(
                  children: [
                    _StatTile(
                      label: 'ACTIVE ITINERARIES',
                      value: '${viewModel.activeTripsCount}',
                      icon: Icons.flight_takeoff_rounded,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      label: 'LOYALTY POINTS',
                      value: '${user.loyaltyPoints}',
                      icon: Icons.stars_rounded,
                      color: Colors.amber.shade800,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Primary CTA to Build Itinerary
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        const Color(0xFFD87314),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Plan a New Itinerary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Customize destinations, dates, and scheduled activities.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: onNavigateToBuilder,
                              child: const Text('Start Itinerary Planner'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.map_rounded,
                        size: 64,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Upcoming Trips Carousel / List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Itineraries',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToExplore,
                      child: const Text('Explore Catalog'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (confirmed.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.luggage_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No upcoming trips yet',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap the button above to build your first itinerary.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...confirmed.map((trip) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            trip.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        title: Text(
                          trip.destinationName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)} • ${trip.activities.length} activities',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '\$${trip.totalCost.toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of Compass?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              viewModel.logout.execute();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out of session.')),
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(icon, size: 18, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
