import 'package:flutter/foundation.dart';

import '../../../core/utils/command.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/itinerary.dart';
import '../../../data/repositories/destination_repository.dart';
import '../../../domain/use_cases/book_itinerary_use_case.dart';

class DestinationDetailViewModel extends ChangeNotifier {
  DestinationDetailViewModel({
    required this.destinationId,
    required this.destinationRepository,
    required this.bookUseCase,
  }) {
    loadDetails = Command0(_loadDetails)..execute();
    bookTrip = Command1(_bookTrip);

    _startDate = DateTime.now().add(const Duration(days: 10));
    _endDate = DateTime.now().add(const Duration(days: 15));
  }

  final String destinationId;
  final DestinationRepository destinationRepository;
  final BookItineraryUseCase bookUseCase;

  late final Command0<void> loadDetails;
  late final Command1<Itinerary, BookingRequest> bookTrip;

  Destination? _destination;
  Destination? get destination => _destination;

  late DateTime _startDate;
  late DateTime _endDate;
  int _guestsCount = 2;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get guestsCount => _guestsCount;

  int get nights => _endDate.difference(_startDate).inDays;
  double get estimatedTotalCost {
    final price = _destination?.pricePerNight ?? 0.0;
    return (nights <= 0 ? 1 : nights) * price;
  }

  Future<Result<void>> _loadDetails() async {
    final result = await destinationRepository.getDestinationById(
      destinationId,
    );
    switch (result) {
      case Ok(:final value):
        _destination = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<Itinerary>> _bookTrip(BookingRequest request) async {
    return await bookUseCase(request);
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
}
