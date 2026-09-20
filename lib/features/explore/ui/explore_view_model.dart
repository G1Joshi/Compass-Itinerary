import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/utils/command.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/destination.dart';
import '../../../data/repositories/destination_repository.dart';
import '../../../domain/use_cases/filter_destinations_use_case.dart';

class ExploreViewModel extends ChangeNotifier {
  ExploreViewModel({
    required this.destinationRepository,
    this.filterUseCase = const FilterDestinationsUseCase(),
  }) {
    loadDestinations = Command0(_loadDestinations)..execute();
    toggleFavorite = Command1(_toggleFavorite);
    search = Command1(_search);
  }

  final DestinationRepository destinationRepository;
  final FilterDestinationsUseCase filterUseCase;

  late final Command0<void> loadDestinations;
  late final Command1<void, String> toggleFavorite;
  late final Command1<void, String> search;

  List<Destination> _allDestinations = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _onlyFavorites = false;

  UnmodifiableListView<Destination> get destinations {
    final filtered = filterUseCase(
      destinations: _allDestinations,
      searchQuery: _searchQuery,
      selectedCategory: _selectedCategory,
      onlyFavorites: _onlyFavorites,
    );
    return UnmodifiableListView(filtered);
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get onlyFavorites => _onlyFavorites;
  int get totalCount => _allDestinations.length;
  int get favoritesCount => _allDestinations.where((d) => d.isFavorite).length;

  Future<Result<void>> _loadDestinations() async {
    final result = await destinationRepository.getDestinations(
      forceRefresh: true,
    );
    switch (result) {
      case Ok(:final value):
        _allDestinations = List.of(value);
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _toggleFavorite(String destinationId) async {
    final index = _allDestinations.indexWhere((d) => d.id == destinationId);
    if (index != -1) {
      final item = _allDestinations[index];
      _allDestinations[index] = item.copyWith(isFavorite: !item.isFavorite);
      notifyListeners();
    }

    final result = await destinationRepository.toggleFavorite(destinationId);
    if (result is Error) {
      if (index != -1) {
        final item = _allDestinations[index];
        _allDestinations[index] = item.copyWith(isFavorite: !item.isFavorite);
        notifyListeners();
      }
      return result;
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _search(String query) async {
    _searchQuery = query;
    notifyListeners();
    return const Result.ok(null);
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
