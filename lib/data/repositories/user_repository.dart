import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/result.dart';
import '../models/user_profile.dart';

abstract class UserRepository extends ChangeNotifier {
  UserProfile get currentUser;
  Future<Result<UserProfile>> refreshProfile();
  Future<Result<void>> logout();
}

class UserRepositoryImpl extends ChangeNotifier implements UserRepository {
  UserRepositoryImpl({UserProfile? initialUser})
    : _currentUser = initialUser ?? UserProfile.defaultUser();

  UserProfile _currentUser;

  @override
  UserProfile get currentUser => _currentUser;

  @override
  Future<Result<UserProfile>> refreshProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = _currentUser.copyWith(
      loyaltyPoints: _currentUser.loyaltyPoints + 100,
    );
    notifyListeners();
    return Result.ok(_currentUser);
  }

  @override
  Future<Result<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulated session reset
    notifyListeners();
    return const Result.ok(null);
  }
}
