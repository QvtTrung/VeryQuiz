import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../services/audio_service.dart';
import 'package:html_unescape/html_unescape.dart';
import './result_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_manager.dart';
import '../services/achievement_service.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game';
  final String category;

  const GameScreen({super.key, required this.category});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Question> _questions = [];
  List<String> _currentAnswers = [];
  final _unescape = HtmlUnescape();
  bool _hasAnswered = false;
  String? _selectedAnswer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _currentEmoji = '🤔';

  @override
  void initState() {
    super.initState();
    _currentEmoji = '🤔';
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadQuestions();
    AudioService().playMusic();
  }

  @override
  void dispose() {
    _animationController.dispose();
    AudioService().stopMusic();
    AudioService().dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    print('Loading questions for category: ${widget.category}');
    _questionsFuture =
        QuestionService().getRandomQuestionsByCategory(widget.category);

    // Debug print the loaded questions
    final questions = await _questionsFuture;
    print('Loaded ${questions.length} questions');
    if (questions.isNotEmpty) {
      print('First question: ${questions[0].question}');
      setState(() {
        _questions = questions;
        _currentAnswers = _getAllAnswers(_questions[0]);
      });
    }
  }

  List<String> _getAllAnswers(Question question) {
    List<String> allAnswers = question.incorrectAnswers
        .map((answer) => _unescape.convert(answer))
        .toList();
    allAnswers.add(_unescape.convert(question.correctAnswer));
    allAnswers.shuffle();
    return allAnswers;
  }

  void _handleAnswerSelected(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;

      if (answer ==
          _unescape.convert(_questions[_currentQuestionIndex].correctAnswer)) {
        _score++;
        _currentEmoji = '😄';
        AudioService().playCorrectAnswerSound();
      } else {
        _currentEmoji = '😢';
        AudioService().playWrongAnswerSound();
      }
    });

    _animationController.forward(from: 0);
    final navigator = Navigator.of(context);
    // Wait before moving to next question
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (_currentQuestionIndex < 9) {
        setState(() {
          _currentQuestionIndex++;
          _hasAnswered = false;
          _selectedAnswer = null;
          _currentAnswers = _getAllAnswers(_questions[_currentQuestionIndex]);
          _currentEmoji = '🤔';
        });
      } else {
        // Update achievements if user is authenticated
        final authManager = context.read<AuthManager>();
        if (authManager.isAuth) {
          final totalQuestions = _questions.length;
          final incorrectAnswers = totalQuestions - _score;

          AchievementService().updateAchievements(
            authManager.user!.id,
            questionsPlayed: totalQuestions,
            correctAnswers: _score,
            incorrectAnswers: incorrectAnswers,
          );
        }
        await AudioService().stopMusic();
        AudioService().playQuizCompleteSound();
        await Future.delayed(Duration(seconds: 1));
        // Navigate to result screen
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              category: widget.category,
            ),
          ),
        );
      }
    });
  }

  Color _getButtonColor(String answer) {
    if (!_hasAnswered) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }

    final correctAnswer =
        _unescape.convert(_questions[_currentQuestionIndex].correctAnswer);

    if (answer == correctAnswer) {
      return Colors.green.shade100;
    } else if (answer == _selectedAnswer) {
      return Colors.red.shade100;
    } else {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.category,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: FutureBuilder<List<Question>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('Error in FutureBuilder: ${snapshot.error}');
                return Center(
                    child: Text('Error loading questions: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print(
                    'No questions available for category: ${widget.category}');
                return const Center(
                    child: Text('No questions available for this category'));
              }

              _questions = snapshot.data!;
              final currentQuestion = _questions[_currentQuestionIndex];

              if (_currentAnswers.isEmpty) {
                _currentAnswers = _getAllAnswers(currentQuestion);
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (_currentQuestionIndex + 1) / 10,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        // Question card
                        SizedBox(
                          height: 200,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.tertiaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Question ${_currentQuestionIndex + 1}/10',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                        Text(
                                          'Score: $_score',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _unescape
                                          .convert(currentQuestion.question),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ScaleTransition(
                          scale: _animation,
                          child: Text(
                            _currentEmoji,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ],
                    ),
                    // Answer buttons
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentAnswers.length,
                        itemBuilder: (context, index) {
                          final answer = _currentAnswers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton(
                              onPressed: _hasAnswered
                                  ? null
                                  : () {
                                      _handleAnswerSelected(answer);
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                backgroundColor: _getButtonColor(answer),
                                disabledBackgroundColor:
                                    _getButtonColor(answer),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                answer,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: _hasAnswered
                                          ? Colors.black87
                                          : colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
