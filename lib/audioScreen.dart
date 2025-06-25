import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlpt_quiz/history.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioQuizScreen extends StatefulWidget {
  const AudioQuizScreen(
      {super.key,
      required String year,
      required String month,
      required String level,
      required String examType});

  @override
  State<AudioQuizScreen> createState() => _AudioQuizScreenState();
}

class _AudioQuizScreenState extends State<AudioQuizScreen> {
  final PageController _pageController = PageController();
  final AudioPlayer _player = AudioPlayer();
  List<DurationRange> _audioParts = [];
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  final int totalQuestions = 4;
  final Map<int, int> _userAnswers = {};
  bool _isPlaying = false;

  // Timer UI (not functional)
  int _countdownSeconds = 20;
  final int _totalQuizSeconds = 20;
  Timer? _timer;

  final List<Map<String, dynamic>> questions = [
    {
      'groupTitle': '問題１',
      'passage': '',
      'subQuestion': 'What does audio say?',
      'answers': [
        'Modes of getting to school',
        'The capital of France is Paris',
        'Gender Equality and Women\'s Rights',
        'Impact of Global Pandemics on Society'
      ],
    },
    {
      'groupTitle': '問題２',
      'passage': '',
      'subQuestion': 'Guess the topic?',
      'answers': [
        'Mountains of Asia',
        'Tokyo is the capital of Japan',
        'Types of insects',
        'European countries'
      ],
    },
    {
      'groupTitle': '問題３',
      'passage': '',
      'subQuestion': 'Guess the topic?',
      'answers': [
        'Mountains of Asia',
        'Tokyo is the capital of Japan',
        'Types of insects',
        'European countries'
      ],
    },
    {
      'groupTitle': '問題４',
      'passage': '',
      'subQuestion': 'Guess the topic?',
      'answers': [
        'Mountains of Asia',
        'Tokyo is the capital of Japan',
        'Types of insects',
        'European countries'
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAudio();
    _startTimer();
  }

  Future<void> _loadAudio() async {
    final byteData = await rootBundle.load("assets/audio/CD.mp3");
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/CD.mp3');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await _player.setFilePath(file.path);
    final totalDuration = await _player.durationFuture ?? Duration(seconds: 60);
    final partDuration = totalDuration.inSeconds ~/ totalQuestions;

    _audioParts = List.generate(totalQuestions, (i) {
      final start = Duration(seconds: i * partDuration);
      final end = Duration(seconds: (i + 1) * partDuration);
      return DurationRange(start: start, end: end);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        _navigateToHistory();
      }
    });
  }

  void _togglePlayPause() async {
    if (_audioParts.isEmpty) return;
    final range = _audioParts[_currentQuestionIndex];

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.seek(range.start);
      await _player.play();
      setState(() => _isPlaying = true);

      Future.delayed(range.end - range.start, () {
        if (_player.playing) {
          _player.pause();
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  void _navigateToHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[_currentQuestionIndex];
    final answers = question['answers'] as List<String>;
    final displayQuestionNumber = _currentQuestionIndex + 1;
    final minutes = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdownSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: Container(
        color: Colors.yellow,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        value: _countdownSeconds / _totalQuizSeconds,
                        strokeWidth: 4,
                        backgroundColor: Colors.white,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text("$minutes:$seconds",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Tap to Play Audio',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(question['subQuestion'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...answers.asMap().entries.map((entry) {
                final index = entry.key;
                final text = entry.value;
                final isSelected = _selectedAnswerIndex == index;
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: const Color.fromARGB(235, 245, 239, 239),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(text,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          _selectedAnswerIndex = val == true ? index : -1;
                        });
                      },
                      activeColor: Colors.deepPurple,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAnswerIndex =
                            (_selectedAnswerIndex == index) ? -1 : index;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        _userAnswers[_currentQuestionIndex] =
                            _selectedAnswerIndex;
                        setState(() {
                          _currentQuestionIndex--;
                          _selectedAnswerIndex =
                              _userAnswers[_currentQuestionIndex] ?? -1;
                          _isPlaying = false;
                        });
                        _player.pause();
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
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _userAnswers[_currentQuestionIndex] =
                          _selectedAnswerIndex;
                      if (_currentQuestionIndex < totalQuestions - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                          _selectedAnswerIndex =
                              _userAnswers[_currentQuestionIndex] ?? -1;
                          _isPlaying = false;
                        });
                        _player.pause();
                      } else {
                        _navigateToHistory();
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
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class DurationRange {
  final Duration start;
  final Duration end;

  DurationRange({required this.start, required this.end});
}
