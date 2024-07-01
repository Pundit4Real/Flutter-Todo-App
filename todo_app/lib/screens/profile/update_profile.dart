// screens/update_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/services/api_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    User user = await ApiService.getUserProfile();
    setState(() {
      _fullNameController.text = user.fullName ?? '';
      _usernameController.text = user.username;
      _emailController.text = user.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                // No validation for full name since it's optional
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User updatedUser = User(
                      fullName: _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
                      username: _usernameController.text,
                      email: _emailController.text,
                    );
                    bool success = await ApiService.updateUserProfile(updatedUser);
                    if (success) {
                      // Show success message and navigate back
                    } else {
                      // Show error message
                    }
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
