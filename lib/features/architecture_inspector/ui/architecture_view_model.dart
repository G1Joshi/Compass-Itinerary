import 'package:flutter/foundation.dart';

import '../../../data/repositories/destination_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/travel_api_service.dart';

class ArchitectureViewModel extends ChangeNotifier {
  ArchitectureViewModel({
    required this.apiService,
    required this.destinationRepository,
    required this.userRepository,
  });

  final TravelApiService apiService;
  final DestinationRepository destinationRepository;
  final UserRepository userRepository;

  bool get isSimulatingErrors => apiService.shouldSimulateErrors;
  bool get isSlowNetwork => apiService.networkLatency.inMilliseconds >= 2000;
  int get cachedDestinationsCount =>
      destinationRepository.cachedDestinations.length;
  String get userTier => userRepository.currentUser.membershipTier;

  void toggleErrorSimulation(bool value) {
    apiService.configureNetworkSimulation(simulateErrors: value);
    notifyListeners();
  }

  void toggleSlowNetwork(bool value) {
    apiService.configureNetworkSimulation(
      latency: value
          ? const Duration(milliseconds: 2500)
          : const Duration(milliseconds: 400),
    );
    notifyListeners();
  }
}
