import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../../data/models/itinerary.dart';
import 'destination_detail_view_model.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key, required this.viewModel});

  final DestinationDetailViewModel viewModel;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    widget.viewModel.bookTrip.addListener(_onBookTripStateChanged);
  }

  @override
  void dispose() {
    widget.viewModel.bookTrip.removeListener(_onBookTripStateChanged);
    super.dispose();
  }

  void _onBookTripStateChanged() {
    final cmd = widget.viewModel.bookTrip;
    if (cmd.completed && mounted) {
      final itinerary = cmd.value;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 52,
          ),
          title: const Text('Itinerary Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your trip to ${itinerary?.destinationName} is successfully booked.',
              ),
              const SizedBox(height: 10),
              Text(
                'Dates: ${_dateFormat.format(itinerary!.startDate)} - ${_dateFormat.format(itinerary.endDate)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Total Paid: \$${itinerary.totalCost.toInt()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Explore'),
            ),
          ],
        ),
      );
      cmd.clearResult();
    } else if (cmd.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cmd.errorException}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      cmd.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final destination = widget.viewModel.destination;

          if (destination == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'dest_img_${destination.id}',
                        child: Image.network(
                          destination.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(color: Colors.grey.shade400),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(120),
                              Colors.transparent,
                              Colors.black.withAlpha(160),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${destination.location}, ${destination.country}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toStringAsFixed(2),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${destination.pricePerNight.toInt()} / night',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'About Destination',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        destination.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Curated Experiences',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: destination.highlights.map((h) {
                          return Chip(
                            avatar: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text(
                              h,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL ESTIMATE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '\$${widget.viewModel.estimatedTotalCost.toInt()}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: widget.viewModel.bookTrip,
                builder: (context, _) {
                  final isBooking = widget.viewModel.bookTrip.running;

                  return ElevatedButton(
                    onPressed: isBooking ? null : _submitBooking,
                    child: isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Book Itinerary'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitBooking() {
    final dest = widget.viewModel.destination;
    if (dest == null) return;

    final request = BookingRequest(
      destinationId: dest.id,
      destinationName: dest.name,
      destinationLocation: '${dest.location}, ${dest.country}',
      imageUrl: dest.imageUrl,
      startDate: widget.viewModel.startDate,
      endDate: widget.viewModel.endDate,
      guestsCount: widget.viewModel.guestsCount,
      pricePerNight: dest.pricePerNight,
    );

    widget.viewModel.bookTrip.execute(request);
  }
}
