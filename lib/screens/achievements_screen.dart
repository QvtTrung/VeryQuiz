import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../providers/auth_manager.dart';

class AchievementsScreen extends StatelessWidget {
  static const routeName = '/achievements';

  const AchievementsScreen({super.key});

  Future<Achievement?> _loadUserAchievements(BuildContext context) async {
    final authManager = context.read<AuthManager>();
    if (authManager.isAuth) {
      return await AchievementService().loadAchievements(authManager.user!.id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        title: Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          if (!authManager.isAuth) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign in now to start tracking your achievement!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Sign In Now',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách thành tích nếu đã đăng nhập
          return FutureBuilder<Achievement?>(
            future: _loadUserAchievements(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                    child:
                        Text('Error loading achievements: ${snapshot.error}'));
              }

              final achievements = snapshot.data;

              final quizzesTaken = (achievements?.questionsPlayed ?? 0) ~/ 10;
              final accuracy = (achievements?.questionsPlayed ?? 0) == 0
                  ? 0.0
                  : ((achievements?.correctAnswers ?? 0) /
                          (achievements?.questionsPlayed ?? 1)) *
                      100;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Quizzes Taken',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$quizzesTaken',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Accuracy',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${accuracy.toStringAsFixed(1)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'Quick Learner',
                    description: 'Complete 5 questions',
                    icon: Icons.speed,
                    progress: achievements?.questionsPlayed ?? 0,
                    total: 5,
                    colorScheme: colorScheme,
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'First step',
                    description: 'Get 1 correct answer',
                    icon: Icons.star,
                    progress: achievements?.correctAnswers ?? 0,
                    total: 1,
                    colorScheme: colorScheme,
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'Knowledge Master',
                    description: 'Complete 50 questions',
                    icon: Icons.school,
                    progress: achievements?.questionsPlayed ?? 0,
                    total: 50,
                    colorScheme: colorScheme,
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'Quiz Enthusiast',
                    description: 'Play 100 quizzes',
                    icon: Icons.quiz,
                    progress: achievements?.questionsPlayed ?? 0,
                    total: 100,
                    colorScheme: colorScheme,
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'Answer Expert',
                    description: 'Answer 200 questions correctly',
                    icon: Icons.check_circle,
                    progress: achievements?.correctAnswers ?? 0,
                    total: 200,
                    colorScheme: colorScheme,
                  ),
                  _buildAchievementCard(
                    context,
                    title: 'Persistent Player',
                    description: 'Answer 300 questions incorrectly',
                    icon: Icons.error,
                    progress: achievements?.incorrectAnswers ?? 0,
                    total: 300,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    totalQuestions: achievements?.questionsPlayed ?? 0,
                    correctAnswers: achievements?.correctAnswers ?? 0,
                    incorrectAnswers: achievements?.incorrectAnswers ?? 0,
                    colorScheme: colorScheme,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required int progress,
    required int total,
    required ColorScheme colorScheme,
  }) {
    final percentage = (progress / total).clamp(0.0, 1.0);
    final isCompleted = progress >= total;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$progress/$total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalQuestions,
    required int correctAnswers,
    required int incorrectAnswers,
    required ColorScheme colorScheme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Questions Played: $totalQuestions',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Correct Answers: $correctAnswers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Incorrect Answers: $incorrectAnswers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
