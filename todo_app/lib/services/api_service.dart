// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_app/models/user.dart';
import 'package:todo_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://todo4mpedigree.pythonanywhere.com/";


// User registration
  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        body: jsonEncode({
          'full_name': user.fullName,
          'username': user.username,
          'email': user.email,
          'password': user.password,
          'password_confirm': user.passwordConfirm,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // Log the response body for debugging
        print('Failed to register user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }


// services/api_service.dart

// Verify email
static Future<bool> verifyEmail(String email, String verificationCode) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/verify-email/'),
    body: jsonEncode({'email': email, 'verification_code': verificationCode}),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

// User login
static Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Print the response body for debugging purposes
      print('Login failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to login user: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error during login: $e');
    throw Exception('Failed to login user: $e');
  }
}


  // Change password
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password/'),
      body: jsonEncode({'old_password': oldPassword, 'new_password': newPassword}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to change password');
    }
  }

  // Forgot password
  static Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/'),
      body: jsonEncode({'email': email}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to send reset code');
    }
  }

  // Reset password
  static Future<bool> resetPassword(String email, String resetCode, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/'),
      body: jsonEncode({'email': email, 'reset_code': resetCode, 'new_password': newPassword}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to reset password');
    }
  }

  // Fetch user profile
  static Future<User> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-profile/'),
      body: jsonEncode({
        'full_name': user.fullName,
        'username': user.username,
        'email': user.email,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update user profile');
    }
  }

 // Fetch tasks
  static Future<List<Task>> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todo/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> tasksJson = jsonData['results'];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Failed to load tasks. Please try again later.');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }
 // Create a task
  static Future<Task> createTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/todo/tasks/create/'),
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'completed': task.completed,
        'due_date': task.dueDate.toIso8601String(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  }


  // Update a task
  static Future<void> updateTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    final response = await http.put(
      Uri.parse('$baseUrl/todo/tasks/${task.id}/'),
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'completed': task.completed,
        'due_date': task.dueDate.toIso8601String(), // Send due_date in ISO 8601 format
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',  // Add Authorization header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  // Delete a task
  static Future<bool> deleteTask(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/todo/tasks/$id/delete/'),
      headers: {
        'Authorization': 'Bearer $accessToken',  // Add Authorization header
      },
    );

    return response.statusCode == 204;
  }
}
