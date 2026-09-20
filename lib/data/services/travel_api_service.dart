import 'dart:async';

import '../../core/utils/exceptions.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';

/// Stateless API Service.
///
/// Wraps remote HTTP communications and isolates data loading.
/// Contains configurable latency and error simulation for architectural chaos testing.
class TravelApiService {
  TravelApiService({
    this.networkLatency = const Duration(milliseconds: 500),
    this.shouldSimulateErrors = false,
  });

  Duration networkLatency;
  bool shouldSimulateErrors;

  void configureNetworkSimulation({Duration? latency, bool? simulateErrors}) {
    if (latency != null) networkLatency = latency;
    if (simulateErrors != null) shouldSimulateErrors = simulateErrors;
  }

  Future<void> _simulateNetworkCall() async {
    if (networkLatency > Duration.zero) {
      await Future.delayed(networkLatency);
    }
    if (shouldSimulateErrors) {
      throw const NetworkException('Simulated 500 Network Failure / Timeout');
    }
  }

  Future<List<Destination>> fetchDestinations() async {
    await _simulateNetworkCall();
    return _mockDestinations;
  }

  Future<Destination> fetchDestinationById(String id) async {
    await _simulateNetworkCall();
    final item = _mockDestinations.cast<Destination?>().firstWhere(
      (d) => d?.id == id,
      orElse: () => null,
    );
    if (item == null) {
      throw NotFoundException('Destination with ID $id not found.');
    }
    return item;
  }

  Future<Itinerary> createBooking(BookingRequest request) async {
    await _simulateNetworkCall();

    if (request.endDate.isBefore(request.startDate) ||
        request.endDate.isAtSameMomentAs(request.startDate)) {
      throw const ValidationException(
        'Check-out date must be after check-in date.',
      );
    }

    final newBooking = Itinerary(
      id: 'itn_${DateTime.now().millisecondsSinceEpoch}',
      destinationId: request.destinationId,
      destinationName: request.destinationName,
      destinationLocation: request.destinationLocation,
      imageUrl: request.imageUrl,
      startDate: request.startDate,
      endDate: request.endDate,
      guestsCount: request.guestsCount,
      totalCost: request.totalCost,
      status: BookingStatus.confirmed,
      bookedAt: DateTime.now(),
      activities: request.activities,
      notes: request.notes,
    );

    return newBooking;
  }

  Future<bool> cancelBooking(String bookingId) async {
    await _simulateNetworkCall();
    return true;
  }

  Future<bool> updateFavoriteOnServer(
    String destinationId,
    bool isFavorite,
  ) async {
    await _simulateNetworkCall();
    return isFavorite;
  }

  static const List<Destination> _mockDestinations = [
    Destination(
      id: 'dest_01',
      name: 'Amalfi Coast Haven',
      location: 'Positano',
      country: 'Italy',
      category: 'Beach',
      rating: 4.95,
      reviewsCount: 420,
      pricePerNight: 390,
      imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800&q=80',
      description: 'Terraced cliffside villas cascading toward crystal-clear Tyrrhenian waters, framed by fragrant lemon orchards and colorful coastal villages.',
      highlights: [
        'Private Sunset Boat Tour',
        'Limoncello Workshop',
        'Path of the Gods Hike',
      ],
    ),
    Destination(
      id: 'dest_02',
      name: 'Kyoto Bamboo Sanctuary',
      location: 'Arashiyama',
      country: 'Japan',
      category: 'Cultural',
      rating: 4.98,
      reviewsCount: 560,
      pricePerNight: 260,
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
      description: 'Historic Ryokan with tatami suites, cedar hot spring baths, and direct walking access to peaceful morning bamboo paths and Zen rock gardens.',
      highlights: [
        'Tea Ceremony Masterclass',
        'Private Onsen Bath',
        'Kiyomizu-dera Dawn Walk',
      ],
    ),
    Destination(
      id: 'dest_03',
      name: 'Zermatt Matterhorn Chalet',
      location: 'Valais',
      country: 'Switzerland',
      category: 'Mountain',
      rating: 4.91,
      reviewsCount: 310,
      pricePerNight: 480,
      imageUrl: 'https://images.unsplash.com/photo-1502784444187-359ac186c5bb?w=800&q=80',
      description: 'Alpine ski chalet facing the Matterhorn peak. Featuring heated stone floors, Finnish sauna, fondue dining, and ski-in / ski-out access.',
      highlights: [
        'Matterhorn Sunrise View',
        'Glacier Palace Tour',
        'Helicopter Alpine Flight',
      ],
    ),
    Destination(
      id: 'dest_04',
      name: 'Santorini Caldera Cliff',
      location: 'Oia',
      country: 'Greece',
      category: 'Beach',
      rating: 4.96,
      reviewsCount: 680,
      pricePerNight: 430,
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80',
      description: 'Whitewashed volcanic cave suite with private heated infinity pool suspended 300 meters above the Aegean Sea.',
      highlights: [
        'Caldera Catamaran Cruise',
        'Wine Tasting Tour',
        'Sunset Dining Experience',
      ],
    ),
    Destination(
      id: 'dest_05',
      name: 'Banff Glacier Mountain Lodge',
      location: 'Alberta',
      country: 'Canada',
      category: 'Adventure',
      rating: 4.88,
      reviewsCount: 230,
      pricePerNight: 320,
      imageUrl: 'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?w=800&q=80',
      description: 'Log lodge bordering turquoise glacial lakes and pine valleys in the heart of Banff National Park.',
      highlights: [
        'Lake Moraine Canoeing',
        'Grizzly Bear Safari',
        'Hot Springs Evening',
      ],
    ),
    Destination(
      id: 'dest_06',
      name: 'Reykjavik Aurora Geodome',
      location: 'Golden Circle',
      country: 'Iceland',
      category: 'Adventure',
      rating: 4.92,
      reviewsCount: 340,
      pricePerNight: 370,
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      description: 'Glass dome retreat designed for unobstructed 360-degree stargazing and viewing the Aurora Borealis from bed.',
      highlights: [
        'Northern Lights Tracking',
        'Geothermal Spa Day',
        'Silfra Fissure Snorkeling',
      ],
    ),
  ];
}
