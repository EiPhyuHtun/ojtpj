import 'package:flutter/material.dart';

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

  final List<Widget> _pages = [
    const ExamDetailTab(),
    const SignupScreen(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  void _onTabTapped(int index) {
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
                child: Image.asset('assets/images/home.jpg'),
              ),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/images/profile.jpg'),
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

class ExamDetailTab extends StatelessWidget {
  const ExamDetailTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'assets/images/girl.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color.fromARGB(255, 245, 193, 193),
                    child: Icon(Icons.person_outline,
                        size: 40, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'User1',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ExamTypeBox('文字', '30分', Colors.orange, Colors.black),
                _ExamTypeBox('読解', '60分', Colors.cyan, Colors.black),
                _ExamTypeBox('聴解', '40分', Colors.lightBlue, Colors.black),
              ],
            ),
          ],
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
  const _ExamTypeBox(this.title, this.duration, this.bgColor, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Signup Screen (Blank)', style: TextStyle(fontSize: 20)),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('History Screen (Blank)', style: TextStyle(fontSize: 20)),
    );
  }
}
