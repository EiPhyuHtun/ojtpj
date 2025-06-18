import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/question.dart';
import 'dart:async'; // Import for Timer
import 'package:jlpt_quiz/history.dart';
import 'package:jlpt_quiz/model/user_attempt.dart'; // Import HistoryScreen

class Questionscreen extends StatefulWidget {
  final String year;
  final String month;
  final String level;
  final String examType;

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

  // Timer related variables
  Timer? _timer;
  int _countdownSeconds = 180; // 3 minutes = 180 seconds for the entire quiz
  final int _totalQuizSeconds =
      180; // Store initial total for progress calculation

  // Quiz result tracking
  int _correctAnswersCount = 0;
  int _incorrectAnswersCount = 0;
  int _noAnswerCount = 0;

  // Map to store user's selected answer for each question (key: questionIndex, value: selectedAnswerIndex or null)
  final Map<int, int?> _userAnswers = {};

  // Dummy userId for now. In a real app, this would come from user login/session.
  final int _currentLoggedInUserId =
      1; // **IMPORTANT: Replace with actual user ID**

  // This will hold the quiz_id of the current set of questions.
  // Assuming all questions loaded for a specific set of parameters belong to one quiz.
  int? _currentQuizId;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuestions();
  }

  // Starts the global quiz timer
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer before starting a new one
    _countdownSeconds =
        _totalQuizSeconds; // Reset to 3 minutes for the whole quiz
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) {
          // Ensure widget is still mounted before calling setState
          setState(() {
            _countdownSeconds--;
          });
        }
      } else {
        // Timer has run out
        _timer?.cancel(); // Stop the timer
        print("Quiz time's up! Calculating results and navigating.");
        _calculateResultsAndNavigate(); // Call new method
      }
    });
  }

  void _calculateResultsAndNavigate() async {
    _timer?.cancel();

    _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex;

    _calculateResults();

    await _saveUserAttempt();

    // Assuming you have currentUserId stored somewhere
    int currentUserId = 1; // Replace with your actual user ID fetch logic

    List<UserAttempt> attempts =
        await DatabaseHelper.instance.getUserAttemptHistory(currentUserId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          correct: _correctAnswersCount,
          incorrect: _incorrectAnswersCount,
          unanswered: _noAnswerCount,
          scorePercent:
              ((_correctAnswersCount / _questions.length) * 100).round(),
          attemptList: attempts,
        ),
      ),
    );
  }

  // Calculates the correct, incorrect, and unanswered counts
  void _calculateResults() {
    _correctAnswersCount = 0;
    _incorrectAnswersCount = 0;
    _noAnswerCount = 0;
    // Get the total number of questions. This is crucial for percentage calculation.
    final int totalQuestions =
        _questions.length; // <--- This is your "total answer" (total questions)

    for (int i = 0; i < _questions.length; i++) {
      final Question question = _questions[i];
      final int? userAnswer =
          _userAnswers[i]; // Get user's answer for this question

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

  // Saves the user's attempt results to the database
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

  // Helper to get the current question based on index
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

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.level}-${widget.year}年${widget.month}月 日本語クイズテスト'),
        backgroundColor: Colors.yellow,
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalQuestions,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (newPageIndex) {
            setState(() {
              // Save the selected answer for the current question before moving
              _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex;
              _currentQuestionIndex = newPageIndex;
              // Load the previously selected answer for the new question
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

            return Column(
              children: [
                Container(
                  color: Colors.yellow,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline),
                                const SizedBox(width: 5),
                                Text(
                                    "$displayQuestionNumber of $totalQuestions"),
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
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: (displayQuestionNumber /
                              totalQuestions), // Dynamic progress
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: _countdownSeconds /
                                  _totalQuizSeconds
                                      .toDouble(), // Dynamic progress for 3 minutes
                              strokeWidth: 6,
                              backgroundColor: Colors.white,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            "$minutes:$seconds", // Display countdown as MM:SS
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showHint = !_showHint;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
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
                              Center(
                                child: Text(
                                    "問題 ${displayQuestionNumber.toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  question.subQuestion ?? "質問テキストが利用できません。",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_showHint)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'ヒント: ${_getHintText() ?? '利用できるヒントがありません。'}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.blue),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFFDF4F6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          ...answers.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final String text = entry.value;
                            bool isSelected =
                                (_selectedAnswerIndex == index + 1);

                            return Card(
                              elevation: isSelected ? 4 : 1,
                              color: const Color.fromARGB(235, 245, 239, 239),
                              shadowColor:
                                  const Color.fromARGB(255, 250, 245, 245),
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
                                tileColor:
                                    const Color.fromARGB(239, 247, 237, 237),
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
                                      if (value == true) {
                                        _selectedAnswerIndex = index + 1;
                                      } else if (_selectedAnswerIndex ==
                                          index + 1) {
                                        _selectedAnswerIndex = null;
                                      }
                                      print(
                                          'Selected answer: $_selectedAnswerIndex');
                                    });
                                  },
                                  activeColor: Colors.deepPurple,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (_selectedAnswerIndex == index + 1) {
                                      _selectedAnswerIndex = null; // Deselect
                                    } else {
                                      _selectedAnswerIndex =
                                          index + 1; // Select this one
                                    }
                                    print(
                                        'Selected answer: $_selectedAnswerIndex');
                                  });
                                },
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Save the selected answer for the current question
                              _userAnswers[_currentQuestionIndex] =
                                  _selectedAnswerIndex;

                              if (_currentQuestionIndex < totalQuestions - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              } else {
                                // All questions have been answered or "Finish" button pressed
                                print(
                                    "All questions answered! Calculating results and navigating.");
                                _calculateResultsAndNavigate();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 130),
                            ),
                            child: Text(
                                _currentQuestionIndex == totalQuestions - 1
                                    ? "仕上げる"
                                    : "次へ", // "Next" or "Finish" button text
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
