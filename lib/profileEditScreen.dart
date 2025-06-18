import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlpt_quiz/database/database_helper.dart'; // Adjust path if necessary
import 'package:jlpt_quiz/model/user.dart'; // Adjust path if necessary
import 'dart:typed_data';

class ProfileEditScreen extends StatefulWidget {
  final User currentUser; // Pass the user data to this widget
  final VoidCallback onProfileUpdated; // Callback to notify parent

  const ProfileEditScreen({
    Key? key,
    required this.currentUser,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final dbHelper = DatabaseHelper.instance;
  XFile? _imageFile; // For newly picked image
  final ImagePicker _picker = ImagePicker();
  late TextEditingController
      nameController; // Use late to initialize in initState
  Uint8List?
      _selectedImageBytes; // Stores the image bytes (either current or new)

  @override
  void initState() {
    super.initState();
    // Initialize controller with current user's name
    nameController = TextEditingController(text: widget.currentUser.userName);
    // Initialize _selectedImageBytes with current user's image
    _selectedImageBytes = widget.currentUser.userImage;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile; // Store the XFile for web/file display
        _selectedImageBytes = bytes; // Store bytes for database and MemoryImage
      });
    }
  }

  Future<void> _updateUser() async {
    // Ensure we have a valid image (either existing or newly picked) and a name
    if (_selectedImageBytes != null && nameController.text.isNotEmpty) {
      // Create a new User object with updated data and the existing ID
      final updatedUser = User(
        id: widget.currentUser.id, // Crucial: keep the same ID for update
        userName: nameController.text,
        userImage: _selectedImageBytes!, // Use the potentially new bytes
      );

      await dbHelper.updateUser(updatedUser);

      widget.onProfileUpdated(); // Notify the parent ProfileScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を選択して名前を入力してください。')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image to display in the CircleAvatar
    ImageProvider? displayImage;
    if (_imageFile != null) {
      // If a new image is picked, use its path (for web/file)
      displayImage = (kIsWeb
          ? NetworkImage(_imageFile!.path)
          : FileImage(io.File(_imageFile!.path))) as ImageProvider<Object>?;
    } else if (_selectedImageBytes != null) {
      // Otherwise, use the bytes (either original or newly picked)
      displayImage = MemoryImage(_selectedImageBytes!);
    }
    // If displayImage is still null, it means no image is available, and the child icon will show.

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text('プロフィールを編集',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60, // Slightly larger for edit screen
                backgroundColor: const Color.fromARGB(255, 245, 193, 193),
                backgroundImage:
                    displayImage, // Use the determined image provider
                child: displayImage ==
                        null // Show icon only if no image provider is set
                    ? const Icon(Icons.person_outline,
                        size: 50, color: Colors.white)
                    : null,
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
              onPressed: _updateUser,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("プロフィールを更新", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
