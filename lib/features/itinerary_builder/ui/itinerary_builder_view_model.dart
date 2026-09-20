import 'package:flutter/foundation.dart';

import '../../../core/utils/command.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/itinerary.dart';
import '../../../data/repositories/destination_repository.dart';
import '../../../domain/use_cases/create_custom_itinerary_use_case.dart';

class ItineraryBuilderViewModel extends ChangeNotifier {
  ItineraryBuilderViewModel({
    required this.destinationRepository,
    required this.createCustomItineraryUseCase,
  }) {
    loadDestinations = Command0(_loadDestinations)..execute();
    buildItinerary = Command0(_buildItinerary);

    _startDate = DateTime.now().add(const Duration(days: 7));
    _endDate = DateTime.now().add(const Duration(days: 12));
  }

  final DestinationRepository destinationRepository;
  final CreateCustomItineraryUseCase createCustomItineraryUseCase;

  late final Command0<void> loadDestinations;
  late final Command0<Itinerary> buildItinerary;

  List<Destination> _destinations = [];
  List<Destination> get destinations => List.unmodifiable(_destinations);

  Destination? _selectedDestination;
  Destination? get selectedDestination => _selectedDestination;

  late DateTime _startDate;
  late DateTime _endDate;
  int _guestsCount = 2;
  final Set<String> _selectedActivities = {};
  String _notes = '';

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get guestsCount => _guestsCount;
  Set<String> get selectedActivities => Set.unmodifiable(_selectedActivities);
  String get notes => _notes;

  int get nights => _endDate.difference(_startDate).inDays;
  double get estimatedCost {
    if (_selectedDestination == null) return 0.0;
    final totalDays = nights <= 0 ? 1 : nights;
    final lodging = totalDays * _selectedDestination!.pricePerNight;
    final activityCost = _selectedActivities.length * 65.0;
    return lodging + activityCost;
  }

  Future<Result<void>> _loadDestinations() async {
    final result = await destinationRepository.getDestinations();
    switch (result) {
      case Ok(:final value):
        _destinations = List.of(value);
        if (_destinations.isNotEmpty && _selectedDestination == null) {
          _selectedDestination = _destinations.first;
          _selectedActivities.addAll(_selectedDestination!.highlights.take(2));
        }
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<Itinerary>> _buildItinerary() async {
    if (_selectedDestination == null) {
      return Result.error(Exception('Please select a destination.'));
    }

    final draft = ItineraryCustomDraft(
      destination: _selectedDestination!,
      startDate: _startDate,
      endDate: _endDate,
      guestsCount: _guestsCount,
      selectedActivityNames: _selectedActivities.toList(),
      notes: _notes,
    );

    return await createCustomItineraryUseCase(draft);
  }

  void selectDestination(Destination dest) {
    _selectedDestination = dest;
    _selectedActivities.clear();
    _selectedActivities.addAll(dest.highlights.take(2));
    notifyListeners();
  }

  void toggleActivity(String activity) {
    if (_selectedActivities.contains(activity)) {
      _selectedActivities.remove(activity);
    } else {
      _selectedActivities.add(activity);
    }
    notifyListeners();
  }

  void updateDates(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void updateGuests(int count) {
    if (count < 1 || count > 10) return;
    _guestsCount = count;
    notifyListeners();
  }

  void updateNotes(String val) {
    _notes = val;
  }
}
