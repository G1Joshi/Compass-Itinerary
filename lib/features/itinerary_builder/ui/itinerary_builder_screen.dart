import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'itinerary_builder_view_model.dart';

class ItineraryBuilderScreen extends StatefulWidget {
  const ItineraryBuilderScreen({
    super.key,
    required this.viewModel,
    required this.onItineraryCreated,
  });

  final ItineraryBuilderViewModel viewModel;
  final VoidCallback onItineraryCreated;

  @override
  State<ItineraryBuilderScreen> createState() => _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState extends State<ItineraryBuilderScreen> {
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    widget.viewModel.buildItinerary.addListener(_onBuildStateChanged);
  }

  @override
  void dispose() {
    widget.viewModel.buildItinerary.removeListener(_onBuildStateChanged);
    super.dispose();
  }

  void _onBuildStateChanged() {
    final cmd = widget.viewModel.buildItinerary;
    if (cmd.completed && mounted) {
      final trip = cmd.value;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.flight_takeoff_rounded,
            color: Colors.teal,
            size: 52,
          ),
          title: const Text('Itinerary Scheduled!'),
          content: Text(
            'Your custom multi-day itinerary for ${trip?.destinationName} with ${trip?.activities.length} planned activities has been booked.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onItineraryCreated();
              },
              child: const Text('View in Itineraries'),
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
      appBar: AppBar(title: const Text('Custom Itinerary Builder')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final destinations = widget.viewModel.destinations;
          final selectedDest = widget.viewModel.selectedDestination;

          if (destinations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '1. Select Destination',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    final isSelected = dest.id == selectedDest?.id;

                    return InkWell(
                      onTap: () => widget.viewModel.selectDestination(dest),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withAlpha(20)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                dest.imageUrl,
                                height: 60,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Container(color: Colors.grey.shade300),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dest.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '\$${dest.pricePerNight.toInt()}/night',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                '2. Choose Travel Dates & Travelers',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text(
                          'Travel Period',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        subtitle: Text(
                          '${_dateFormat.format(widget.viewModel.startDate)} – ${_dateFormat.format(widget.viewModel.endDate)} (${widget.viewModel.nights} nights)',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                        onTap: () => _pickDateRange(context),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Number of Travelers',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () => widget.viewModel.updateGuests(
                                  widget.viewModel.guestsCount - 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '${widget.viewModel.guestsCount}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => widget.viewModel.updateGuests(
                                  widget.viewModel.guestsCount + 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                '3. Add Experiences to Daily Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select activities to be automatically placed in your daily timeline:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),

              if (selectedDest != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedDest.highlights.map((activity) {
                    final isChecked = widget.viewModel.selectedActivities
                        .contains(activity);
                    return FilterChip(
                      label: Text(activity),
                      selected: isChecked,
                      onSelected: (_) =>
                          widget.viewModel.toggleActivity(activity),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isChecked ? Colors.white : Colors.black87,
                        fontWeight: isChecked
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Trip Notes
              Text(
                '4. Special Requests or Trip Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: widget.viewModel.updateNotes,
                decoration: InputDecoration(
                  hintText: 'e.g. Vegetarian meals, quiet room requested...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 100),
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
                      'ESTIMATED BUDGET',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '\$${widget.viewModel.estimatedCost.toInt()}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: widget.viewModel.buildItinerary,
                builder: (context, _) {
                  final isBuilding = widget.viewModel.buildItinerary.running;
                  return ElevatedButton(
                    onPressed: isBuilding
                        ? null
                        : () => widget.viewModel.buildItinerary.execute(),
                    child: isBuilding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Itinerary'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: widget.viewModel.startDate,
        end: widget.viewModel.endDate,
      ),
    );
    if (picked != null) {
      widget.viewModel.updateDates(picked.start, picked.end);
    }
  }
}
