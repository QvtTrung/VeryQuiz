import '../models/achievement.dart';
import 'pocketbase_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  Future<void> createAchievement(String userId) async {
    try {
      final client = await getPocketbaseInstance();
      await client.collection('achievements').create(body: {
        'userId': userId,
        'questionsPlayed': 0,
        'correctAnswers': 0,
        'incorrectAnswers': 0,
        'dateAchieved': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating achievement: $e');
    }
  }

  Future<Achievement?> loadAchievements(String userId) async {
    try {
      final client = await getPocketbaseInstance();
      final records = await client.collection('achievements').getFullList(
            filter: 'userId = "$userId"',
          );
      if (records.isNotEmpty) {
        return Achievement.fromMap(records.first.toJson());
      } else {
        // Create a new achievement record if none exists
        await createAchievement(userId);
        final newRecords = await client.collection('achievements').getFullList(
              filter: 'userId = "$userId"',
            );
        if (newRecords.isNotEmpty) {
          return Achievement.fromMap(newRecords.first.toJson());
        }
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
    return null;
  }

  Future<void> updateAchievements(String userId,
      {int? questionsPlayed,
      int? correctAnswers,
      int? incorrectAnswers}) async {
    try {
      final client = await getPocketbaseInstance();
      final achievements = await loadAchievements(userId);
      if (achievements != null) {
        achievements.update(
          questionsPlayed: questionsPlayed,
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
        );
        await client.collection('achievements').update(
              achievements.id,
              body: achievements.toMap(),
            );
      }
    } catch (e) {
      print('Error updating achievements: $e');
    }
  }
}
