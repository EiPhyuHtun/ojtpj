import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlpt_quiz/database/database_helper.dart';
import 'package:jlpt_quiz/level.dart';
import 'package:jlpt_quiz/model/user.dart';
import 'package:jlpt_quiz/profileEditScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Initialize your database helper
  final dbHelper = DatabaseHelper.instance;
  User? _currentUser;
  @override
  void initState() {
    super.initState();
    _loadUser(); // Attempt to load user data when the screen initializes
  }

  // Method to load the user from the database
  Future<void> _loadUser() async {
    final List<Map<String, dynamic>> maps = await dbHelper.getUsers();
    if (maps.isNotEmpty) {
      setState(() {
        _currentUser =
            User.fromMap(maps.first); // Assuming only one user for profile
      });
    } else {
      setState(() {
        _currentUser = null; // No user found
      });
    }
  }

  // Callback for when a user is successfully created (from signup)
  void _onUserCreated() {
    _loadUser(); // Reload user to switch to edit mode
    // Navigate to LevelPage after successful creation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LevelPage()),
    );
  }

  // Callback for when a user is successfully updated (from edit)
  void _onProfileUpdated() {
    _loadUser(); // Reload user to refresh UI (optional, but good for consistency)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Updated Successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If _currentUser is null, show the signup form
    // If _currentUser has data, show the profile edit form
    return _currentUser == null
        ? _SignupContent(onUserCreated: _onUserCreated)
        : ProfileEditScreen(
            // Now using the separate ProfileEditScreen
            currentUser: _currentUser!, // Pass the current user
            onProfileUpdated: _onProfileUpdated,
          );
  }
}

// --- START: Existing Widget for Signup Content (remains in this file) ---
class _SignupContent extends StatefulWidget {
  final VoidCallback onUserCreated;

  const _SignupContent({Key? key, required this.onUserCreated})
      : super(key: key);

  @override
  _SignupContentState createState() => _SignupContentState();
}

class _SignupContentState extends State<_SignupContent> {
  final dbHelper = DatabaseHelper.instance;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final nameController = TextEditingController();
  Uint8List? _selectedImageBytes;

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

  Future<void> _insertUser() async {
    if (_selectedImageBytes != null && nameController.text.isNotEmpty) {
      await dbHelper.insertUser(
          User(userName: nameController.text, userImage: _selectedImageBytes!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Created Successfully')),
      );
      widget.onUserCreated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an image and enter a title.')),
      );
    }
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
      imagePreview = const Row(
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
            const SizedBox(height: 24),
            const Text('サインアップ',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("名前",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                print('Insert Data');
                _insertUser();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("サインアップ", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
