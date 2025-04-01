import 'package:pocketbase/pocketbase.dart';
import '../models/question.dart';
import 'pocketbase_service.dart';

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();

  factory QuestionService() {
    return _instance;
  }

  QuestionService._internal();

  Future<List<RecordModel>> getQuestions() async {
    try {
      final client = await getPocketbaseInstance();
      final records = await client.collection('questions').getFullList();
      return records;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<List<Question>> getRandomQuestionsByCategory(String category) async {
    try {
      final client = await getPocketbaseInstance();
      final ResultList result = await client.collection('questions').getList(
            page: 1,
            perPage: 500,
            filter: 'category ~ "$category"',
          );

      if (result.items.isEmpty) {
        print('No questions found for category: $category');
        return [];
      }

      final questions = result.items.map((record) {
        final data = record.toJson();
        data['id'] = record.toJson()['id'].toString();
        return Question.fromJson(data);
      }).toList();

      questions.shuffle();
      return questions.take(10).toList();
    } catch (e, stackTrace) {
      print('Error fetching questions by category: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
