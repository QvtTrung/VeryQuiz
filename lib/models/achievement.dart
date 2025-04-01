class Achievement {
  final String id;
  final String userId;
  int questionsPlayed;
  int correctAnswers;
  int incorrectAnswers;
  final DateTime dateAchieved;

  Achievement({
    required this.id,
    required this.userId,
    required this.questionsPlayed,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.dateAchieved,
  });

  Achievement.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        questionsPlayed = map['questionsPlayed'],
        correctAnswers = map['correctAnswers'],
        incorrectAnswers = map['incorrectAnswers'],
        dateAchieved = DateTime.parse(map['dateAchieved']);

  void update({
    int? questionsPlayed,
    int? correctAnswers,
    int? incorrectAnswers,
  }) {
    if (questionsPlayed != null) {
      this.questionsPlayed += questionsPlayed;
    }
    if (correctAnswers != null) {
      this.correctAnswers += correctAnswers;
    }
    if (incorrectAnswers != null) {
      this.incorrectAnswers += incorrectAnswers;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'questionsPlayed': questionsPlayed,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'dateAchieved': dateAchieved.toIso8601String(),
    };
  }
}
