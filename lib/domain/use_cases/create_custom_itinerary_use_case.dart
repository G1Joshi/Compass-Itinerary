import '../../core/utils/result.dart';
import '../../data/models/destination.dart';
import '../../data/models/itinerary.dart';
import '../../data/repositories/booking_repository.dart';
import 'book_itinerary_use_case.dart';

class ItineraryCustomDraft {
  const ItineraryCustomDraft({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.guestsCount,
    required this.selectedActivityNames,
    this.notes = '',
  });

  final Destination destination;
  final DateTime startDate;
  final DateTime endDate;
  final int guestsCount;
  final List<String> selectedActivityNames;
  final String notes;
}

/// Domain Use Case that assembles an itinerary schedule and delegates booking.
class CreateCustomItineraryUseCase {
  CreateCustomItineraryUseCase({
    required this.bookingRepository,
    required this.bookUseCase,
  });

  final BookingRepository bookingRepository;
  final BookItineraryUseCase bookUseCase;

  Future<Result<Itinerary>> call(ItineraryCustomDraft draft) async {
    final nights = draft.endDate.difference(draft.startDate).inDays;
    final totalDays = nights <= 0 ? 1 : nights;

    // Generate day-by-day scheduled activities
    final activities = <ItineraryActivity>[];
    var currentDay = 1;

    for (final actName in draft.selectedActivityNames) {
      activities.add(
        ItineraryActivity(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}_$currentDay',
          dayNumber: currentDay,
          timeSlot: currentDay.isOdd ? '10:00 AM' : '02:30 PM',
          title: actName,
          description: 'Curated experience in ${draft.destination.location}',
          location: '${draft.destination.name} Grounds',
          cost: 65.0,
          category: draft.destination.category,
        ),
      );
      if (currentDay < totalDays) {
        currentDay++;
      }
    }

    final request = BookingRequest(
      destinationId: draft.destination.id,
      destinationName: draft.destination.name,
      destinationLocation:
          '${draft.destination.location}, ${draft.destination.country}',
      imageUrl: draft.destination.imageUrl,
      startDate: draft.startDate,
      endDate: draft.endDate,
      guestsCount: draft.guestsCount,
      pricePerNight: draft.destination.pricePerNight,
      activities: activities,
      notes: draft.notes,
    );

    return await bookUseCase(request);
  }
}
