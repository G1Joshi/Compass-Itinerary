import '../../data/models/destination.dart';

class FilterDestinationsUseCase {
  const FilterDestinationsUseCase();

  List<Destination> call({
    required List<Destination> destinations,
    String searchQuery = '',
    String? selectedCategory,
    double? maxPrice,
    bool onlyFavorites = false,
  }) {
    return destinations.where((destination) {
      if (onlyFavorites && !destination.isFavorite) return false;

      if (selectedCategory != null &&
          selectedCategory != 'All' &&
          destination.category.toLowerCase() !=
              selectedCategory.toLowerCase()) {
        return false;
      }

      if (maxPrice != null && destination.pricePerNight > maxPrice) {
        return false;
      }

      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final matchName = destination.name.toLowerCase().contains(query);
        final matchLocation = destination.location.toLowerCase().contains(
          query,
        );
        final matchCountry = destination.country.toLowerCase().contains(query);
        final matchHighlights = destination.highlights.any(
          (h) => h.toLowerCase().contains(query),
        );

        if (!matchName && !matchLocation && !matchCountry && !matchHighlights) {
          return false;
        }
      }

      return true;
    }).toList()..sort((a, b) => b.rating.compareTo(a.rating));
  }
}
