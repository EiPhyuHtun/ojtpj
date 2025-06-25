// lib/screens/reading_paragraph_screen.dart
import 'package:flutter/material.dart';
import 'package:jlpt_quiz/questionScreen.dart'; // Make sure this path is correct

class ReadingParagraphScreen extends StatelessWidget {
  final String year;
  final String month;
  final String level;
  final String examType;
  final String paragraphContent; // To pass the paragraph text

  const ReadingParagraphScreen({
    Key? key,
    required this.year,
    required this.month,
    required this.level,
    required this.examType,
    required this.paragraphContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('読解 (Reading)'),
        backgroundColor: Colors.cyan, // Matching the ExamTypeBox color
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe left (positive delta.dx indicates swipe right, negative for left)
          if (details.primaryVelocity! < 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Questionscreen(
                  year: year,
                  month: month,
                  level: level,
                  examType: examType,
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '読解の段落',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                paragraphContent,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 30),
              const Text(
                '左にスワイプして質問に進みます',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
