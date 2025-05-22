import 'package:flutter/material.dart';

class ExamDetailScreen extends StatelessWidget {
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
            SizedBox(height: 30),
            Padding(
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
                  Container(
                    height: 90,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'User1',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
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
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _examTypeBox('文字', '30分', Colors.orange, Colors.black),
                _examTypeBox('読解', '60分', Colors.cyan, Colors.black),
                _examTypeBox('聴解', '40分', Colors.lightBlue, Colors.black),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '歴史'),
        ],
      ),
    );
  }

  Widget _examTypeBox(
      String title, String duration, Color bgColor, Color textColor) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(duration, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
