import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/level.dart';
import 'package:jlpt_quiz/model/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
   // Initialize your database helper
  final dbHelper = DatabaseHelper.instance;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final nameController = TextEditingController();
  Uint8List? _selectedImageBytes; 
  List<User> _users = [];


    @override
  void initState() {
    super.initState();
    _loadImages();
  }
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageFile = pickedFile;
        _selectedImageBytes = bytes;
      });
    }
  }
  Future<void> insertUser() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (_selectedImageBytes != null && nameController.text.isNotEmpty) {
      await dbHelper.insertUser(User(userName: nameController.text, userImage: _selectedImageBytes!));

      setState(() {
        nameController.clear();
        _selectedImageBytes = null; // Clear selected image
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Created Successfully')),
      ); 
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>  LevelPage()),
  ); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter a title.')),
      );
    }
  }

  Future<void> _loadImages() async {
    final List<Map<String, dynamic>> maps = await dbHelper.getUsers();
    setState(() {
      _users = maps.map((map) => User.fromMap(map)).toList();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  //method insert data in MySql 
  //connect the database

  @override 
  Widget build(BuildContext context) {
    Widget imagePreview;
    if (_imageFile == null) {
      imagePreview = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 28),
          SizedBox(width: 8),
          Text("画像を選択", style: TextStyle(fontSize: 18)),
        ],
      );
    } else if (kIsWeb) {
      imagePreview = Image.network(_imageFile!.path);
    } else {
      imagePreview = Image.file(io.File(_imageFile!.path), fit: BoxFit.cover);
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 80),
            Text("QUIZ 4 ✅", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('サインアップ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: imagePreview),
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("名前", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
               onPressed: () {
                print('Insert Data');
                insertUser();
               },
             
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("サインアップ", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

