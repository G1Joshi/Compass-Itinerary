import 'dart:async';

import '../../core/utils/result.dart';
import '../models/itinerary.dart';
import '../services/local_storage_service.dart';
import '../services/travel_api_service.dart';

abstract class BookingRepository {
  Future<Result<List<Itinerary>>> getItineraries();
  Future<Result<Itinerary>> createBooking(BookingRequest request);
  Future<Result<void>> cancelBooking(String bookingId);
}

/// Single Source of Truth for itineraries and bookings.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    required this.apiService,
    required this.storageService,
  });

  final TravelApiService apiService;
  final LocalStorageService storageService;

  List<Itinerary> _itineraries = [];

  @override
  Future<Result<List<Itinerary>>> getItineraries() async {
    if (_itineraries.isNotEmpty) {
      return Result.ok(List.unmodifiable(_itineraries));
    }

    try {
      final saved = await storageService.getSavedItineraries();
      if (saved.isNotEmpty) {
        _itineraries = saved;
      } else {
        // Seed default active trip with day-by-day activities matching Compass case study
        _itineraries = [
          Itinerary(
            id: 'itn_sample_01',
            destinationId: 'dest_02',
            destinationName: 'Kyoto Bamboo Sanctuary',
            destinationLocation: 'Arashiyama, Kyoto, Japan',
            imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
            startDate: DateTime.now().add(const Duration(days: 12)),
            endDate: DateTime.now().add(const Duration(days: 16)),
            guestsCount: 2,
            totalCost: 1340.0,
            status: BookingStatus.confirmed,
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            notes:
                'Traditional Ryokan reservation with Kaiseki dinners included.',
            activities: [
              const ItineraryActivity(
                id: 'act_01',
                dayNumber: 1,
                timeSlot: '09:30 AM',
                title: 'Morning Arashiyama Bamboo Grove Walk',
                description: 'Private guided photography walk through quiet bamboo trails before crowds.',
                location: 'Arashiyama Grove Entrance',
                cost: 40.0,
                category: 'Sightseeing',
              ),
              const ItineraryActivity(
                id: 'act_02',
                dayNumber: 1,
                timeSlot: '03:00 PM',
                title: 'Authentic Matcha Tea Ceremony',
                description: 'Ceremonial preparation of organic Uji green tea with seasonal wagashi sweets.',
                location: 'Tenryu-ji Temple Annex',
                cost: 65.0,
                category: 'Cultural',
              ),
              const ItineraryActivity(
                id: 'act_03',
                dayNumber: 2,
                timeSlot: '10:00 AM',
                title: 'Kiyomizu-dera & Gion Geisha District Tour',
                description: 'Historical exploration of wooden stage temple and cobblestone geisha streets.',
                location: 'Higashiyama Ward',
                cost: 85.0,
                category: 'Cultural',
              ),
              const ItineraryActivity(
                id: 'act_04',
                dayNumber: 3,
                timeSlot: '05:30 PM',
                title: 'Fushimi Inari Sunset Hike & Street Food',
                description: 'Hike through thousands of vermilion torii gates followed by yakitori tasting.',
                location: 'Fushimi Inari Shrine',
                cost: 50.0,
                category: 'Food & Adventure',
              ),
            ],
          ),
        ];
        await storageService.saveItineraries(_itineraries);
      }
      return Result.ok(List.unmodifiable(_itineraries));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Itinerary>> createBooking(BookingRequest request) async {
    try {
      final newBooking = await apiService.createBooking(request);
      _itineraries.insert(0, newBooking);
      await storageService.saveItineraries(_itineraries);
      return Result.ok(newBooking);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await apiService.cancelBooking(bookingId);
      final index = _itineraries.indexWhere((i) => i.id == bookingId);
      if (index != -1) {
        _itineraries[index] = _itineraries[index].copyWith(
          status: BookingStatus.cancelled,
        );
        await storageService.saveItineraries(_itineraries);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
