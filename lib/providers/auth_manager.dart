// lib/providers/auth_manager.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/achievement_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  User? _loggedInUser;

  AuthManager() {
    _authService = AuthService(onAuthChange: (User? user) {
      _loggedInUser = user;
      notifyListeners();
    });

    tryAutoLogin();
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(String email, String password) {
    return _authService.signup(email, password);
  }

  Future<User> login(String email, String password) async {
    final user = await _authService.login(email, password);
    _loggedInUser = user;
    await AchievementService().loadAchievements(user.id); // Load achievements
    notifyListeners();
    return user;
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (user != null) {
      _loggedInUser = user;
      await AchievementService().loadAchievements(user.id);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _loggedInUser = null;
    notifyListeners();
  }
}
