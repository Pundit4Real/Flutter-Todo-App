import 'package:flutter/material.dart';
import 'package:todo_master/models/user.dart';
import 'package:todo_master/services/api_service.dart';
import 'package:todo_master/widgets/custom_scaffold.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;

  UpdateProfileScreen({required this.user});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  File? _avatarFile; // File to hold the picked image
  int _currentIndex = 1; // Set to 1 for Profile

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      User updatedUser = User(
        id: widget.user.id,
        fullName: _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
        username: _usernameController.text,
        email: _emailController.text,
        avatar: widget.user.avatar,
      );

      bool success = await ApiService.updateUserProfile(updatedUser, _avatarFile);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/todo-list');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Feather.chevron_left,
            size: 30,
          ),
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: null,
        flexibleSpace: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Update ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Profile',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white60,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : (widget.user.avatar != null
                                    ? NetworkImage(widget.user.avatar!)
                                    : null),
                            child: _avatarFile == null && widget.user.avatar == null
                                ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                                : null,
                          ),
                        ),
                        if (_avatarFile == null && widget.user.avatar != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.lightBlue,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      // No validation for full name since it's optional
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text('Update Profile'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
