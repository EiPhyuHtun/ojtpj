import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/question.dart';

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
  final int _totalQuestions = 10;
  Question? _currentQuestion;
  bool _isLoadingQuestion = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuestion(1); // Load sub_question when screen initializes
  }

  void _loadQuestion(int questionId) async {
    setState(() {
      _isLoadingQuestion = true; // Set loading state
      _selectedAnswerIndex = null; // Clear selected answer for new question
    });
    try {
      // Fetch the question using its ID. In a real app, you'd map PageIndex to Question IDs.
      // For demonstration, let's assume question IDs are sequential from 1.
      // You might have a list of question IDs or fetch all questions for a quiz upfront.
      final Question? fetchedQuestion =
          await DatabaseHelper.instance.getQuestionById(questionId);

      if (mounted) {
        setState(() {
          _currentQuestion = fetchedQuestion;
          _isLoadingQuestion = false; // Clear loading state
        });
      }
    } catch (e) {
      print("Error loading question: $e");
      if (mounted) {
        setState(() {
          _currentQuestion = null; // Indicate error or no question found
          _isLoadingQuestion = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> answerOptions = [
      "Modes of getting to school",
      "The capital of France is Paris",
      "Gender Equality and Women's Rights",
      "Impact of Global Pandemics on Society",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.level} ${widget.year}年${widget.month} ${widget.examType}試験'),
        backgroundColor: Colors.yellow,
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _totalQuestions,
          onPageChanged: (newPageIndex) {
            setState(() {
              _selectedAnswerIndex = null;
            });
          },
          itemBuilder: (context, questionIndex) {
            final int displayQuestionNumber = questionIndex + 1;

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
                                Icon(Icons.person_outline),
                                SizedBox(width: 5),
                                Text(
                                    "$displayQuestionNumber of $_totalQuestions"),
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
                                  "$displayQuestionNumber of $_totalQuestions",
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: 0.25,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: 0.5,
                              strokeWidth: 6,
                              backgroundColor: Colors.white,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text("20",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                                _currentQuestion?.subQuestion ??
                                    "Question not available.",
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
                          ...answerOptions.asMap().entries.map((entry) {
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
                              if (_selectedAnswerIndex != null) {
                                print(
                                    'User confirmed choice: $_selectedAnswerIndex');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please select an answer!')),
                                );
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
                            child: const Text("次へ",
                                style: TextStyle(
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
