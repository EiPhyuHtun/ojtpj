import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/question.dart'; // Ensure your Question model is updated to handle nulls
import 'dart:async'; // Import for Timer
import 'package:jlpt_quiz/history.dart'; // Import your HistoryScreen

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
  int _countdownSeconds = 10; // 10-second timer

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuestions();
    _startTimer(); // Load all relevant questions
  }

  void _startTimer() {
    _countdownSeconds =
        10; // Reset timer for each question if needed, or once for the whole quiz
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel(); // Stop the timer
        // Navigate to HistoryScreen when timer ends
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
      }
    });
  }

  void _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _questions = []; // Clear previous questions
      _currentQuestionIndex = 0; // Reset index
      _selectedAnswerIndex = null; // Clear selected answer
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
            content: Text('Failed to load questions: ${e.toString()}'),
          ),
        );
      }
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.level} ${widget.year}年${widget.month} ${widget.examType}試験'),
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
          title: Text(
              '${widget.level} ${widget.year}年${widget.month} ${widget.examType}試験'),
          backgroundColor: Colors.yellow,
        ),
        body: const Center(
          child: Text('No questions available for this selection.'),
        ),
      );
    }

    // Ensure _currentQuestion is not null before proceeding to build the question UI
    final Question? currentQuestion = _currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.level} ${widget.year}年${widget.month} ${widget.examType}試験'),
          backgroundColor: Colors.yellow,
        ),
        body: const Center(
          child: Text('Error: Current question data is missing.'),
        ),
      );
    }

    // Now, answer options are dynamic based on _currentQuestion
    final List<String> answerOptions = [
      currentQuestion.answer1 ?? 'Answer 1 (N/A)',
      currentQuestion.answer2 ?? 'Answer 2 (N/A)',
      currentQuestion.answer3 ?? 'Answer 3 (N/A)',
      currentQuestion.answer4 ?? 'Answer 4 (N/A)',
    ];

    final int totalQuestions = _questions.length;
    final int displayQuestionNumber = _currentQuestionIndex + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.level} ${widget.year}年${widget.month}月 ${widget.examType}試験'),
        backgroundColor: Colors.yellow,
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalQuestions, // Use the actual number of questions
          onPageChanged: (newPageIndex) {
            setState(() {
              _currentQuestionIndex = newPageIndex; // Update current index
              _selectedAnswerIndex =
                  null; // Clear selected answer for new question
            });
          },
          itemBuilder: (context, questionIndex) {
            // Ensure we are displaying the correct question for the current page
            final Question? question = _questions[questionIndex];

            if (question == null) {
              return const Center(
                  child: Text('Error: Question data is missing.'));
            }

            // Using null-aware operators and providing defaults for display
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
                                  10.0, // Dynamic progress for 10 seconds
                              strokeWidth: 6,
                              backgroundColor: Colors.white,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            "$_countdownSeconds", // Display countdown
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
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
                                Text("Hint",
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
                                question.subQuestion ??
                                    "Question text not available.", // Handle null subQuestion
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
                          // Use the 'answers' list which accounts for potential nulls
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
                                trailing: Radio<int>(
                                  value: index + 1,
                                  groupValue: _selectedAnswerIndex,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedAnswerIndex = value;
                                      print(
                                          'Selected answer: $_selectedAnswerIndex');
                                    });
                                  },
                                  activeColor: Colors.deepPurple,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedAnswerIndex = index + 1;
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
                              if (_selectedAnswerIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please select an answer!')),
                                );
                                return; // Exit if no answer is selected
                              }

                              // Check if the selected answer is correct (ensure correctAnswer is not null)
                              if (currentQuestion.correctAnswer != null) {
                                if (_selectedAnswerIndex ==
                                    currentQuestion.correctAnswer) {
                                  print('Correct answer selected!');
                                  // Add logic for correct answer (e.g., score increment)
                                } else {
                                  print('Incorrect answer selected.');
                                  // Add logic for incorrect answer
                                }
                              } else {
                                print(
                                    'Warning: Correct answer not available for this question.');
                              }

                              // Advance to the next question or finish the quiz
                              if (_currentQuestionIndex < totalQuestions - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              } else {
                                // Last question, navigate to results screen or finish quiz
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Quiz Finished!')),
                                );
                                // Implement navigation to results screen here
                                Navigator.pop(
                                    context); // Example: Go back to previous screen
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
                                    ? "Finish"
                                    : "次へ", // "Next" or "Finish" button text
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white)),
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
