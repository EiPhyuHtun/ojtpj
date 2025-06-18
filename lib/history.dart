import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/user_attempt.dart';

class HistoryScreen extends StatefulWidget {
  final int? correct;
  final int? incorrect;
  final int? unanswered;
  final int? scorePercent;
  final List<UserAttempt> attemptList;

  const HistoryScreen({
    super.key,
    this.correct,
    this.incorrect,
    this.unanswered,
    this.scorePercent,
    this.attemptList = const [],
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen purple background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Card (Congratulations Card) with its own padding
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(top: 50.0),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 60.0, 20.0, 20.0),
                            child: Column(
                              children: [
                                const Text(
                                  'おめでとう！',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '計算得点 ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '${widget.scorePercent ?? 0} points',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, thickness: 1),
                                // Statistics Section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      icon: Icons.lightbulb_outline,
                                      value: '${widget.unanswered ?? 0}',
                                      label: '中止',
                                      iconColor: Colors.grey,
                                    ),
                                    _buildStatColumn(
                                      icon: Icons.check_circle_outline,
                                      value: '${widget.correct ?? 0}',
                                      label: '正解',
                                      iconColor: Colors.green,
                                    ),
                                    _buildStatColumn(
                                      icon: Icons.error_outline,
                                      value: '${widget.incorrect ?? 0}',
                                      label: '警告',
                                      iconColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Trophy Image positioned relative to the Card
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/images/trophy.png',
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 8,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20), // Rounded top corners
                        bottom: Radius.circular(0), // No rounding on bottom
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '年月日',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '試験タイプ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '得点',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),

                        // List
                        widget.attemptList.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.attemptList.length,
                                itemBuilder: (context, index) {
                                  final attempt = widget.attemptList[index];
                                  final totalQuestions = attempt.correctScore +
                                      attempt.incorrectScore +
                                      attempt.incompleteScore;

                                  final scorePercent = totalQuestions > 0
                                      ? ((attempt.correctScore /
                                                  totalQuestions) *
                                              100)
                                          .round()
                                      : 0;

                                  final formattedDate = DateFormat('yyyy年M月d日')
                                      .format(
                                          DateTime.parse(attempt.createdAt));
                                  String getJapaneseExamType(
                                      String englishType) {
                                    switch (englishType) {
                                      case 'Reading':
                                        return '読解';
                                      case 'Kanji/Vocab':
                                        return '文字';
                                      case 'Listening':
                                        return '聴解';
                                      default:
                                        return englishType; // fallback
                                    }
                                  }

                                  return FutureBuilder<Uint8List?>(
                                    future: DatabaseHelper.instance
                                        .getUserImageById(attempt.userId),
                                    builder: (context, snapshot) {
                                      Uint8List? userImage = snapshot.data;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(formattedDate,
                                                  style: const TextStyle(
                                                      color: Colors.black87)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: userImage != null
                                                  ? CircleAvatar(
                                                      radius: 16,
                                                      backgroundImage:
                                                          MemoryImage(
                                                              userImage),
                                                    )
                                                  : const CircleAvatar(
                                                      radius: 16,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/profile.png'),
                                                    ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                  getJapaneseExamType(
                                                      attempt.quizType),
                                                  style: const TextStyle(
                                                      color: Colors.black87)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text('$scorePercent%',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '履歴が見つかりませんでした。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: iconColor),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem({
    required String date,
    required Uint8List? userImage,
    required String testType,
    required String score,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Date Column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Quiz Type Column
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userImage != null
                      ? MemoryImage(userImage) // ✅ Show DB image
                      : const AssetImage('assets/images/profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    testType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Score Column
          Expanded(
            flex: 2,
            child: Text(
              score,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
