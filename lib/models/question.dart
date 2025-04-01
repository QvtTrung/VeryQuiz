import 'package:html_unescape/html_unescape.dart';

class Question {
  final String id;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String category;

  Question({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var incorrectAnswersList = <String>[];
    if (json['incorrect_answers'] is String) {
      incorrectAnswersList = (json['incorrect_answers'] as String).split(',');
    } else if (json['incorrect_answers'] is List) {
      incorrectAnswersList = List<String>.from(json['incorrect_answers']);
    }

    return Question(
      id: json['id'],
      question: HtmlUnescape().convert(json['question']),
      correctAnswer: json['correct_answer'],
      incorrectAnswers: incorrectAnswersList,
      category: json['category'],
    );
  }
}
