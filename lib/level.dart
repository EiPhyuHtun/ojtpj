import 'package:flutter/material.dart';
import 'exam_detail.dart';

class LevelPage extends StatefulWidget {
  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final List<Map<String, String>> exams = [
    {'year': '2024', 'month': '7月'},
    {'year': '2024', 'month': '12月'},
    {'year': '2023', 'month': '7月'},
    {'year': '2023', 'month': '12月'},
    {'year': '2022', 'month': '7月'},
    {'year': '2022', 'month': '12月'},
  ];

  final List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  String selectedLevel = 'N5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 210,
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
                  top: 170,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFBEA),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: Offset(0, -30),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor:
                                const Color.fromARGB(255, 245, 193, 193),
                            child: Icon(Icons.person_outline,
                                size: 40, color: Colors.white),
                          ),
                        ),
                        Text(
                          'User1',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: levels.map((level) {
                  bool isSelected = level == selectedLevel;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLevel = level;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.yellow[700]
                            : Colors.transparent,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamDetailScreen(
                              year: exams[index]['year']!,
                              month: exams[index]['month']!,
                              level: selectedLevel,
                            ),
                          ),
                        );
                      },
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
