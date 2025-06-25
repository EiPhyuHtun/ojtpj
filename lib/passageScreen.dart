import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';

class PassageScreen extends StatefulWidget {
  final int quizId;
  final String year;
  final String month;
  final String level;
  final String examType;

  const PassageScreen({
    super.key,
    required this.year,
    required this.month,
    required this.level,
    required this.examType,
    required this.quizId, // Keep required if you’ll validate later
  });

  @override
  State<PassageScreen> createState() => _PassageScreenState();
}

class _PassageScreenState extends State<PassageScreen> {
  List<Map<String, dynamic>> groupedPassages = [];

  @override
  void initState() {
    super.initState();
    _loadPassages();
  }

  Future<void> _loadPassages() async {
    final data =
        await DatabaseHelper.instance.getPassageWithQuestions(widget.quizId);
    setState(() {
      groupedPassages = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("読解パッセージ"),
        backgroundColor: Colors.deepPurple,
      ),
      body: groupedPassages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groupedPassages.length,
              itemBuilder: (context, index) {
                final passage = groupedPassages[index];
                final List<dynamic> questions = passage['questions'];

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          passage['paragraph'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        ...questions.map((q) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("【${q['sub_question']}】"),
                              const SizedBox(height: 4),
                              Text("1. ${q['answer1']}"),
                              Text("2. ${q['answer2']}"),
                              Text("3. ${q['answer3']}"),
                              Text("4. ${q['answer4']}"),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
