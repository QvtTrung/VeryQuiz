import 'package:flutter/material.dart';

class LevelScreen extends StatelessWidget {
  static const routeName = '/levels';

  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Choose Topic',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildTopicCard(
              context, 'Science', Icons.science, colorScheme.primary),
          _buildTopicCard(
              context, 'History', Icons.history_edu, colorScheme.secondary),
          _buildTopicCard(
              context, 'Geography', Icons.public, colorScheme.tertiary),
          _buildTopicCard(context, 'Sports', Icons.sports, colorScheme.error),
          _buildTopicCard(context, 'Art', Icons.palette, colorScheme.primary),
          _buildTopicCard(
              context, 'Music', Icons.music_note, colorScheme.secondary),
          _buildTopicCard(context, 'Film', Icons.movie, colorScheme.tertiary),
          _buildTopicCard(
              context, 'Books', Icons.menu_book, colorScheme.primary),
          _buildTopicCard(
              context, 'Mythology', Icons.auto_awesome, colorScheme.secondary),
          _buildTopicCard(
              context, 'Vehicle', Icons.directions_car, colorScheme.tertiary),
          _buildTopicCard(
              context, 'Animals', Icons.pets, colorScheme.error),
          _buildTopicCard(
              context, 'Politics', Icons.account_balance, colorScheme.primary),
          _buildTopicCard(
              context, 'Celebrities', Icons.star, colorScheme.secondary),
          _buildTopicCard(
              context, 'Anime', Icons.face, colorScheme.tertiary),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            "/game",
            arguments: title,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
