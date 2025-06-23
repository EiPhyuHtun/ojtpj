import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/question.dart';
import 'dart:async'; // Import for Timer
import 'package:jlpt_quiz/history.dart';
import 'package:jlpt_quiz/model/user_attempt.dart';
import 'package:jlpt_quiz/passageScreen.dart'; // Import HistoryScreen

class Questionscreen extends StatefulWidget {
  final String year;
  final String month;
  final String level;
  final String examType; // This will now also influence the timer

  const Questionscreen({
    Key? key,
    required this.year,
    required this.month,
    required this.level,
    required this.examType,
  }) : super(key: key);

  @override
  State<Questionscreen> createState() => _QuestionscreenState();
}

class _QuestionscreenState extends State<Questionscreen> {
  int? _selectedAnswerIndex;
  late PageController _pageController;
  List<Question> _questions = []; // List to hold fetched questions
  int _currentQuestionIndex = 0; // Track current question index in the list
  bool _isLoadingQuestions = true; // State for loading questions

  Timer? _timer;
  int _countdownSeconds =
      0; // Will be set dynamically based on level and examType
  int _totalQuizSeconds =
      0; // Will store initial total for progress calculation

  int _correctAnswersCount = 0;
  int _incorrectAnswersCount = 0;
  int _noAnswerCount = 0;

  final Map<int, int?> _userAnswers = {};

  final int _currentLoggedInUserId =
      1; // **IMPORTANT: Replace with actual user ID**

  int? _currentQuizId;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuestions();
  }

  int _getExamTypeDurationInSeconds(String level, String examType) {
    switch (level.toUpperCase()) {
      case 'N1':
        switch (examType) {
          case 'Kanji/Vocab':
            return 50 * 60;
          case 'Reading':
            return 60 * 60;
          case 'Listening':
            return 60 * 60;
          case 'Total': // If a 'Total' exam type is specifically selected
            return 170 * 60;
          default:
            print(
                "Warning: Unknown exam type '$examType' for N1, defaulting to total time.");
            return 170 * 60; // Fallback for N1
        }
      case 'N2':
        switch (examType) {
          case 'Kanji/Vocab':
            return 50 * 60;
          case 'Reading':
            return 55 * 60;
          case 'Listening':
            return 50 * 60;
          case 'Total': // If a 'Total' exam type is specifically selected
            return 155 * 60;
          default:
            print(
                "Warning: Unknown exam type '$examType' for N2, defaulting to total time.");
            return 155 * 60; // Fallback for N2
        }
      case 'N3':
        switch (examType) {
          case 'Kanji/Vocab':
          case 'Reading':
          case 'Listening':
          case 'Total':
            return 125 * 60; // N3 total time
          default:
            print(
                "Warning: Unknown exam type '$examType' for N3, defaulting to total time.");
            return 125 * 60;
        }
      case 'N4':
        switch (examType) {
          case 'Kanji/Vocab':
          case 'Reading':
          case 'Listening':
          case 'Total':
            return 105 * 60; // N4 total time
          default:
            print(
                "Warning: Unknown exam type '$examType' for N4, defaulting to total time.");
            return 105 * 60;
        }
      case 'N5':
        switch (examType) {
          case 'Kanji/Vocab':
          case 'Reading':
          case 'Listening':
          case 'Total':
            return 80 * 60; // N5 total time
          default:
            print(
                "Warning: Unknown exam type '$examType' for N5, defaulting to total time.");
            return 80 * 60;
        }
      default:
        print(
            "Warning: Unknown level '$level', defaulting to 80 minutes (N5 Total).");
        return 80 * 60; // Default fallback if level is unknown
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) {
          setState(() {
            _countdownSeconds--;
          });
        }
      } else {
        _timer?.cancel();
        print("Quiz time's up! Calculating results and navigating.");
        _calculateResultsAndNavigate();
      }
    });
  }

  void _calculateResultsAndNavigate() async {
    _timer?.cancel();
    _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex;

    _calculateResults();
    await _saveUserAttempt();
    int currentUserId = 1;

    List<UserAttempt> attempts =
        await DatabaseHelper.instance.getUserAttemptHistory(currentUserId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          correct: _correctAnswersCount,
          incorrect: _incorrectAnswersCount,
          unanswered: _noAnswerCount,
          scorePercent: _questions.isNotEmpty
              ? ((_correctAnswersCount / _questions.length) * 100).round()
              : 0, // Handle division by zero
          attemptList: attempts,
        ),
      ),
    );
  }

  void _calculateResults() {
    _correctAnswersCount = 0;
    _incorrectAnswersCount = 0;
    _noAnswerCount = 0;

    final int totalQuestions = _questions.length;

    for (int i = 0; i < _questions.length; i++) {
      final Question question = _questions[i];
      final int? userAnswer = _userAnswers[i];

      if (userAnswer == null) {
        _noAnswerCount++;
      } else if (question.correctAnswer != null &&
          userAnswer == question.correctAnswer) {
        _correctAnswersCount++;
      } else {
        _incorrectAnswersCount++;
      }
    }

    print("\n--- Quiz Results ---");
    print("Correct Answers: $_correctAnswersCount");
    print("Incorrect Answers: $_incorrectAnswersCount");
    print("Unanswered Questions: $_noAnswerCount");
    print("---------------------\n");
  }

  // Loads questions from the database based on quiz parameters
  void _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _questions = []; // Clear previous questions
      _currentQuestionIndex = 0; // Reset index
      _selectedAnswerIndex = null; // Clear selected answer
      _userAnswers.clear(); // Clear previous answers
      _correctAnswersCount = 0; // Reset scores
      _incorrectAnswersCount = 0;
      _noAnswerCount = 0;
      _currentQuizId = null; // Reset quiz ID
      _timer?.cancel(); // Ensure any existing timer is cancelled
    });
    try {
      final List<Question> fetchedQuestions =
          await DatabaseHelper.instance.getQuestionsByQuizParameters(
        widget.year,
        widget.month,
        widget.level,
        widget.examType,
      );

      if (mounted) {
        setState(() {
          _questions = fetchedQuestions;
          _isLoadingQuestions = false;
          if (_questions.isEmpty) {
            print("No questions found for the selected criteria.");
            // Optionally, show a dialog or navigate back here
          } else {
            // Initialize _userAnswers map for all questions as null (unanswered)
            for (int i = 0; i < _questions.length; i++) {
              _userAnswers[i] = null;
            }
            // Capture the quiz_id from the first question.
            // This assumes all questions loaded belong to the same quiz.
            if (_questions.isNotEmpty) {
              _currentQuizId = _questions.first.quizId;
            }

            _totalQuizSeconds =
                _getExamTypeDurationInSeconds(widget.level, widget.examType);
            _countdownSeconds = _totalQuizSeconds; // Initialize countdown

            _startTimer(); // Start the global timer only when questions are loaded
          }
        });
      }
    } catch (e) {
      print("Error loading questions: $e");
      if (mounted) {
        setState(() {
          _questions = []; // Clear questions on error
          _isLoadingQuestions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('質問を読み込めませんでした: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _saveUserAttempt() async {
    if (_currentQuizId == null) {
      print("Error: Cannot save user attempt, quiz ID is null.");
      // Optionally show an error to the user
      return;
    }

    try {
      await DatabaseHelper.instance.insertUserAttempt(
        _currentLoggedInUserId, // Use the actual user ID
        _currentQuizId!, // Use the captured quiz ID
        _correctAnswersCount,
        _incorrectAnswersCount,
        _noAnswerCount,
      );
      print("User attempt saved to database successfully!");
    } catch (e) {
      print("Error saving user attempt: $e");
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('クイズの結果を保存できませんでした: ${e.toString()}'),
        ),
      );
    }
  }

  Question? get _currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Crucial to cancel the timer when the widget is disposed
    super.dispose();
  }

  String? _getHintText() {
    final Question? question = _currentQuestion;
    if (question == null) return null;

    String? correctAnswerText;
    switch (question.correctAnswer) {
      case 1:
        correctAnswerText = question.answer1;
        break;
      case 2:
        correctAnswerText = question.answer2;
        break;
      case 3:
        correctAnswerText = question.answer3;
        break;
      case 4:
        correctAnswerText = question.answer4;
        break;
      default:
        correctAnswerText = null;
    }

    if (correctAnswerText != null && correctAnswerText.isNotEmpty) {
      if (correctAnswerText.length >= 2) {
        return 'ヒント: ${correctAnswerText.substring(0, 2)}。。。';
      } else {
        return 'ヒント: ${correctAnswerText}。。。';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text('${widget.level} ${widget.year}年${widget.month} 日本語クイズテスト'),
          backgroundColor: Colors.yellow,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text('${widget.level}-${widget.year}年${widget.month} 日本語クイズテスト'),
          backgroundColor: Colors.yellow,
        ),
        body: const Center(
          child: Text('この選択に使用できる質問はありません。'),
        ),
      );
    }

    final Question? currentQuestion = _currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text('${widget.level}-${widget.year}年${widget.month} 日本語クイズテスト'),
          backgroundColor: Colors.yellow,
        ),
        body: const Center(
          child: Text('Error: Current question data is missing.'),
        ),
      );
    }

    final List<String> answerOptions = [
      currentQuestion.answer1 ?? 'Answer 1 (N/A)',
      currentQuestion.answer2 ?? 'Answer 2 (N/A)',
      currentQuestion.answer3 ?? 'Answer 3 (N/A)',
      currentQuestion.answer4 ?? 'Answer 4 (N/A)',
    ];

    final int totalQuestions = _questions.length;
    final int displayQuestionNumber = _currentQuestionIndex + 1;

    String minutes = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    String seconds = (_countdownSeconds % 60).toString().padLeft(2, '0');

    final ScrollController _cardScrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.level}-${widget.year}年${widget.month}月 日本語クイズテスト (${widget.examType})'),
        backgroundColor: Colors.yellow,
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalQuestions,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (newPageIndex) {
            setState(() {
              _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex;
              _currentQuestionIndex = newPageIndex;
              _selectedAnswerIndex = _userAnswers[newPageIndex];
              _showHint = false;
            });
          },
          itemBuilder: (context, questionIndex) {
            final Question? question = _questions[questionIndex];

            if (question == null) {
              return const Center(child: Text('エラー: 質問データがありません。'));
            }

            final List<String> answers = [
              question.answer1 ?? 'Answer 1 missing',
              question.answer2 ?? 'Answer 2 missing',
              question.answer3 ?? 'Answer 3 missing',
              question.answer4 ?? 'Answer 4 missing',
            ];

            return Container(
              color: Colors.yellow,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: progress and countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline),
                            const SizedBox(width: 5),
                            Text("$displayQuestionNumber of $totalQuestions"),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Text(
                            "$displayQuestionNumber of $totalQuestions",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (displayQuestionNumber / totalQuestions),
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: CircularProgressIndicator(
                              value: _countdownSeconds /
                                  _totalQuizSeconds.toDouble(),
                              strokeWidth: 4,
                              backgroundColor: Colors.white,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            "$minutes:$seconds",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Hint and Passage Section
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showHint = !_showHint;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: Colors.orange),
                                SizedBox(width: 5),
                                Text("ヒント",
                                    style: TextStyle(color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (question.groupTitle?.isNotEmpty ?? false)
                              Text(
                                question.groupTitle!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (question.passage?.isNotEmpty ?? false)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question.passage!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    249, 252, 241, 180), // pale yellow
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    " ${displayQuestionNumber.toString().padLeft(2, '0')})",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      question.subQuestion ?? "質問テキストが利用できません。",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_showHint)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  ' ${_getHintText() ?? '利用できるヒントがありません。'}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.blue),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Answer Options
                    ...answers.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final String text = entry.value;
                      bool isSelected = (_selectedAnswerIndex == index + 1);

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: const Color.fromARGB(235, 245, 239, 239),
                        shadowColor: const Color.fromARGB(255, 250, 245, 245),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedAnswerIndex =
                                    value == true ? index + 1 : null;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedAnswerIndex =
                                  (_selectedAnswerIndex == index + 1)
                                      ? null
                                      : index + 1;
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_currentQuestionIndex > 0)
                          ElevatedButton(
                            onPressed: () {
                              _userAnswers[_currentQuestionIndex] =
                                  _selectedAnswerIndex;
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                            ),
                            child: const Text("前へ",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            _userAnswers[_currentQuestionIndex] =
                                _selectedAnswerIndex;
                            if (_currentQuestionIndex < totalQuestions - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              _calculateResultsAndNavigate();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                          ),
                          child: Text(
                              _currentQuestionIndex == totalQuestions - 1
                                  ? "仕上げる"
                                  : "次へ",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
