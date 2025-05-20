import 'package:flutter/material.dart';

class LevelPage extends StatelessWidget {
  final List<Map<String, String>> exams = [
    {'year': '2024', 'month': '7月'},
    {'year': '2024', 'month': '12月'},
    {'year': '2023', 'month': '7月'},
    {'year': '2023', 'month': '12月'},
    {'year': '2022', 'month': '7月'},
    {'year': '2022', 'month': '12月'},
  ];

  final List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBEA),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF176), Color(0xFFFFEB3B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_outline,
                            size: 40, color: Colors.teal),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'SakuraAikoharui',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: levels.map((level) {
                  bool isSelected = level == 'N5';
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.yellow[700] : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Text(
                          exams[index]['year']!,
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${exams[index]['year']}年${exams[index]['month']}',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
