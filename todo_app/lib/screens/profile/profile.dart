// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<User>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            User user = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name: ${user.fullName}'),
                  Text('Username: ${user.username}'),
                  Text('Email: ${user.email}'),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to update profile screen
                    },
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}