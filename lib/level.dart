import 'package:flutter/material.dart';
import 'exam_detail.dart';
import 'package:jlpt_quiz/database/database_helper.dart'; // Import your DatabaseHelper
import 'package:jlpt_quiz/model/user.dart'; // Import your User model
import 'dart:typed_data';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});
  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> with WidgetsBindingObserver {
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
  User? _currentUser;
  final dbHelper = DatabaseHelper.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // This method is called when the app's lifecycle state changes.
    // We want to reload user data when the app comes back to the foreground (resumed).
    if (state == AppLifecycleState.resumed) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    final List<Map<String, dynamic>> maps = await dbHelper.getUsers();
    if (maps.isNotEmpty) {
      setState(() {
        _currentUser = User.fromMap(maps.first);
      });
    } else {
      // Handle case where user might have been deleted or not created yet
      setState(() {
        _currentUser = null;
      });
    }
  }

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
                          child: _currentUser != null &&
                                  _currentUser!.userImage != null
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
                        ),
                        Text(
                          _currentUser != null
                              ? _currentUser!.userName
                              : 'User1',
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
