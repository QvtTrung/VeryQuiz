import 'package:pocketbase/pocketbase.dart';

import '../models/user.dart';

import 'pocketbase_service.dart';
import 'achievement_service.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        });
      });
    }
  }

  Future<User> signup(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final record = await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });
      final user = User.fromJson(record.toJson());
      await AchievementService()
          .createAchievement(user.id); // Create achievements for new user
      return user;
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      final user = User.fromJson(authRecord.record.toJson());
      await AchievementService().loadAchievements(user.id);
      print("Token after login: ${pb.authStore.token}"); // Kiểm tra token
      return user;
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred: $error');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.record;

    if (model == null) {
      return null;
    }

    return User.fromJson(model.toJson());
  }
}
