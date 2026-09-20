import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/destination_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/travel_api_service.dart';
import 'domain/use_cases/book_itinerary_use_case.dart';
import 'domain/use_cases/create_custom_itinerary_use_case.dart';
import 'domain/use_cases/filter_destinations_use_case.dart';
import 'features/architecture_inspector/ui/architecture_inspector_sheet.dart';
import 'features/architecture_inspector/ui/architecture_view_model.dart';
import 'features/bookings/ui/bookings_screen.dart';
import 'features/bookings/ui/bookings_view_model.dart';
import 'features/explore/ui/explore_screen.dart';
import 'features/explore/ui/explore_view_model.dart';
import 'features/home/ui/home_screen.dart';
import 'features/home/ui/home_view_model.dart';
import 'features/itinerary_builder/ui/itinerary_builder_screen.dart';
import 'features/itinerary_builder/ui/itinerary_builder_view_model.dart';

/// The root application widget.
///
/// Implements Dependency Injection with MultiProvider as officially recommended.
class TravelItineraryApp extends StatelessWidget {
  const TravelItineraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Services (Stateless data loaders)
        Provider<TravelApiService>(create: (_) => TravelApiService()),
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),

        // 2. Repositories (Single Source of Truth)
        Provider<DestinationRepository>(
          create: (context) => DestinationRepositoryImpl(
            apiService: context.read(),
            storageService: context.read(),
          ),
        ),
        Provider<BookingRepository>(
          create: (context) => BookingRepositoryImpl(
            apiService: context.read(),
            storageService: context.read(),
          ),
        ),
        ChangeNotifierProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(),
        ),

        // 3. Domain Use Cases
        Provider<FilterDestinationsUseCase>(
          create: (_) => const FilterDestinationsUseCase(),
        ),
        Provider<BookItineraryUseCase>(
          create: (context) =>
              BookItineraryUseCase(bookingRepository: context.read()),
        ),
        Provider<CreateCustomItineraryUseCase>(
          create: (context) => CreateCustomItineraryUseCase(
            bookingRepository: context.read(),
            bookUseCase: context.read(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Compass Itinerary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final HomeViewModel _homeViewModel;
  late final ItineraryBuilderViewModel _builderViewModel;
  late final ExploreViewModel _exploreViewModel;
  late final BookingsViewModel _bookingsViewModel;
  late final ArchitectureViewModel _architectureViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeViewModel = HomeViewModel(
      bookingRepository: context.read(),
      userRepository: context.read(),
    );

    _builderViewModel = ItineraryBuilderViewModel(
      destinationRepository: context.read(),
      createCustomItineraryUseCase: context.read(),
    );

    _exploreViewModel = ExploreViewModel(
      destinationRepository: context.read(),
      filterUseCase: context.read(),
    );

    _bookingsViewModel = BookingsViewModel(bookingRepository: context.read());

    _architectureViewModel = ArchitectureViewModel(
      apiService: context.read(),
      destinationRepository: context.read(),
      userRepository: context.read(),
    );
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    _builderViewModel.dispose();
    _exploreViewModel.dispose();
    _bookingsViewModel.dispose();
    _architectureViewModel.dispose();
    super.dispose();
  }

  void _onItineraryCreated() {
    _bookingsViewModel.loadBookings.execute();
    _homeViewModel.loadHome.execute();
    setState(() => _currentIndex = 3); // Switch to Itineraries tab
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        viewModel: _homeViewModel,
        onNavigateToBuilder: () => setState(() => _currentIndex = 1),
        onNavigateToExplore: () => setState(() => _currentIndex = 2),
      ),
      ItineraryBuilderScreen(
        viewModel: _builderViewModel,
        onItineraryCreated: _onItineraryCreated,
      ),
      ExploreScreen(viewModel: _exploreViewModel),
      BookingsScreen(viewModel: _bookingsViewModel),
      ArchitectureInspectorSheet(viewModel: _architectureViewModel),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined),
            selectedIcon: Icon(Icons.edit_calendar_rounded),
            label: 'Plan Trip',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage_rounded),
            label: 'Itineraries',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub_rounded),
            label: 'Architecture',
          ),
        ],
      ),
    );
  }
}
