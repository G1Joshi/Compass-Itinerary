import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../destination_detail/ui/destination_detail_screen.dart';
import '../../destination_detail/ui/destination_detail_view_model.dart';
import 'explore_view_model.dart';
import 'widgets/category_chips.dart';
import 'widgets/destination_card.dart';
import 'widgets/search_filter_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.viewModel});

  final ExploreViewModel viewModel;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _categories = [
    'All',
    'Beach',
    'Mountain',
    'Cultural',
    'Adventure',
  ];

  @override
  void initState() {
    super.initState();
    widget.viewModel.toggleFavorite.addListener(_onToggleFavoriteChanged);
  }

  @override
  void dispose() {
    widget.viewModel.toggleFavorite.removeListener(_onToggleFavoriteChanged);
    super.dispose();
  }

  void _onToggleFavoriteChanged() {
    final cmd = widget.viewModel.toggleFavorite;
    if (cmd.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update favorite: ${cmd.errorException}. Rolled back.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      cmd.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations & Escapes'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => widget.viewModel.loadDestinations.execute(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadDestinations,
        builder: (context, child) {
          if (widget.viewModel.loadDestinations.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.loadDestinations.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 54,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load destinations: ${widget.viewModel.loadDestinations.errorException}',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          widget.viewModel.loadDestinations.execute(),
                      child: const Text('Retry Command'),
                    ),
                  ],
                ),
              ),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final destinations = widget.viewModel.destinations;

            return RefreshIndicator(
              onRefresh: () => widget.viewModel.loadDestinations.execute(),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: SearchFilterBar(
                      onSearchChanged: (q) =>
                          widget.viewModel.search.execute(q),
                      onlyFavorites: widget.viewModel.onlyFavorites,
                      onToggleFavorites: widget.viewModel.toggleFavoritesFilter,
                      favoritesCount: widget.viewModel.favoritesCount,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: CategoryChips(
                      categories: _categories,
                      selectedCategory: widget.viewModel.selectedCategory,
                      onSelected: widget.viewModel.selectCategory,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (destinations.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No destinations match your filters.'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final dest = destinations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DestinationCard(
                              destination: dest,
                              onTap: () => _openDetail(dest.id),
                              onFavoriteToggle: () => widget
                                  .viewModel
                                  .toggleFavorite
                                  .execute(dest.id),
                            ),
                          );
                        }, childCount: destinations.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => DestinationDetailScreen(
          viewModel: DestinationDetailViewModel(
            destinationId: id,
            destinationRepository: ctx.read(),
            bookUseCase: ctx.read(),
          ),
        ),
      ),
    );
  }
}
