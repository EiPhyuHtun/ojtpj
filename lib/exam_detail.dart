import 'package:flutter/material.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/model/user.dart';
import 'package:jlpt_quiz/model/user_attempt.dart';
import 'package:jlpt_quiz/profileScreen.dart';
import 'history.dart';
import 'questionScreen.dart';

class ExamDetailScreen extends StatefulWidget {
  final String year;
  final String month;
  final String level;

  const ExamDetailScreen({
    Key? key,
    required this.year,
    required this.month,
    required this.level,
  }) : super(key: key);

  @override
  _ExamDetailScreenState createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  List<UserAttempt> _userAttempts = [];
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabTapped(_tabController.index);
      }
    });
  }

  Future<void> _loadHistory() async {
    final userList = await DatabaseHelper.instance.getUsers();
    if (userList.isNotEmpty) {
      final userId = userList.first['id'] as int;
      final history =
          await DatabaseHelper.instance.getUserAttemptHistory(userId);
      setState(() {
        _userAttempts = history;
        _historyLoaded = true;
      });
    }
  }

  void _onTabTapped(int index) async {
    if (index == 2 && !_historyLoaded) {
      await _loadHistory();
    }

    setState(() {
      _currentIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ExamDetailTab(
          year: widget.year, month: widget.month, level: widget.level),
      const ProfileScreen(),
      HistoryScreen(attemptList: _userAttempts),
    ];
    return Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/home.png'),
              ),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/profile.png'),
              ),
              label: 'プロフィール',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/history.png'),
              ),
              label: '歴史',
            ),
          ],
        ));
  }
}

class ExamDetailTab extends StatefulWidget {
  final String year;
  final String month;
  final String level;
  const ExamDetailTab({
    Key? key,
    required this.year,
    required this.month,
    required this.level,
  }) : super(key: key);
  @override
  State<ExamDetailTab> createState() => _ExamDetailTabState();
}

class _ExamDetailTabState extends State<ExamDetailTab> {
  User? _currentUser; // To store the fetched user data
  final dbHelper = DatabaseHelper.instance; // Get an instance of your DB helper

  @override
  void initState() {
    super.initState();
    _loadUser(); // Load user data when the widget initializes
  }

  Future<void> _loadUser() async {
    final List<Map<String, dynamic>> maps = await dbHelper.getUsers();
    if (maps.isNotEmpty) {
      setState(() {
        _currentUser =
            User.fromMap(maps.first); // Assuming you want the first user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/girl.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _currentUser != null
                        ? CircleAvatar(
                            radius: 45,
                            backgroundColor:
                                const Color.fromARGB(255, 245, 193, 193),
                            backgroundImage:
                                MemoryImage(_currentUser!.userImage!),
                          )
                        : const CircleAvatar(
                            radius: 45,
                            backgroundColor:
                                const Color.fromARGB(255, 245, 193, 193),
                            child: Icon(Icons.person_outline,
                                size: 40, color: Colors.white),
                          ),
                    const SizedBox(width: 20),
                    Text(
                      _currentUser != null ? _currentUser!.userName : '名前未設定 ',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      '試験タイプ',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ExamTypeBox('文字', '30分', Colors.orange, Colors.black,
                      onTap: () {
                    print("Exam type tapped");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Questionscreen(
                          year: widget.year,
                          month: widget.month,
                          level: widget.level,
                          examType: 'Kanji/Vocab',
                        ),
                      ),
                    );
                  }),
                  _ExamTypeBox(
                    '読解',
                    '60分',
                    Colors.cyan,
                    Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Questionscreen(
                            year: widget.year,
                            month: widget.month,
                            level: widget.level,
                            examType: 'Reading',
                          ),
                        ),
                      );
                    },
                  ),
                  _ExamTypeBox(
                    '聴解',
                    '40分',
                    Colors.lightBlue,
                    Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Questionscreen(
                            year: widget.year,
                            month: widget.month,
                            level: widget.level,
                            examType: 'Listening',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamTypeBox extends StatelessWidget {
  final String title;
  final String duration;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  const _ExamTypeBox(
    this.title,
    this.duration,
    this.bgColor,
    this.textColor, {
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: bgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(duration,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
