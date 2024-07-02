// screens/update_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/services/api_service.dart';

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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  print("Update Profile button pressed"); // Logging button press
                  if (_formKey.currentState!.validate()) {
                    print("Form validated"); // Logging form validation
                    User updatedUser = User(
                      id: widget.user.id,
                      fullName: _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
                      username: _usernameController.text,
                      email: _emailController.text,
                      avatar: widget.user.avatar,
                    );
                    print("Updated user data prepared: ${updatedUser.toJson()}"); // Logging user data

                    bool success = await ApiService.updateUserProfile(updatedUser);
                    print("API call success: $success"); // Logging API call result

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully')),
                      );
                      Navigator.pop(context); // Go back to ProfileScreen
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile')),
                      );
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
