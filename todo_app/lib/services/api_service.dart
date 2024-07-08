import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_master/models/user.dart';
import 'package:todo_master/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "https://todo4mpedigree.pythonanywhere.com/";

  // User registration
static Future<Map<String, dynamic>> registerUser(User user) async {
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
      return {'success': true};
    } else {
      // Parse and log the response body for debugging
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print('Failed to register user: $responseBody');

      // Extract and clean up the error messages
      String rawErrorMessage =
          responseBody['error'] ?? responseBody.toString();
      String cleanedErrorMessage = rawErrorMessage
          .replaceAll("{'non_field_errors': [ErrorDetail(string='", '')
          .replaceAll("', code='invalid')]}", '')
          .replaceAll("{'username': [ErrorDetail(string='", '')
          .replaceAll("', code=unique')]}", '')
          .replaceAll("{'email': [ErrorDetail(string='", '')
          .replaceAll("', code='unique')]}", '');

      // Return the cleaned error message
      return {'success': false, 'error': cleanedErrorMessage};
    }
  } on SocketException catch (_) {
    print('No Internet connection');
    return {
      'success': false,
      'error': 'No Internet connection. Please check your network and try again.'
    };
  } catch (e) {
    print('Error occurred: $e');
    return {
      'success': false,
      'error': 'An error occurred. Please try again.'
    };
  }
}

  // Verify Email
  static Future<Map<String, dynamic>> verifyEmail(String email, String verificationCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email/'),
        body: jsonEncode({'email': email, 'verification_code': verificationCode}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Email verified successfully'};
      } else {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'An unknown error occurred';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error occurred: $e');
      return {'success': false, 'message': 'An error occurred. Please try again.'};
    }
  }

  // Resend Verification Code
  static Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-v-email/'),
        body: jsonEncode({'email': email}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Verification code resent successfully'};
      } else {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'An unknown error occurred';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error occurred: $e');
      return {'success': false, 'message': 'An error occurred. Please try again.'};
    }
  }

 // User login
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
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
        // Capture the error message from the response body
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['detail'] ?? 'Login failed';
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection and try again.');
    } catch (e) {
      print('Error during login: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

// Change password
static Future<bool> changePassword(
  String oldPassword, String newPassword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');

  if (accessToken == null) {
    throw Exception('No authentication token found');
  }

  final response = await http.post(
    Uri.parse('$baseUrl/auth/change-password/'),
    body: jsonEncode(
        {'old_password': oldPassword, 'new_password': newPassword}),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 401) {
    throw Exception('Unauthorized: Invalid token or expired');
  } else if (response.statusCode == 400) {
    throw Exception('Bad Request: Check old and new passwords');
  } else {
    throw Exception('Failed to change password: ${response.reasonPhrase}');
  }
}

// Forgot password
static Future<Map<String, dynamic>> forgotPassword(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/forgot-password/'),
    body: jsonEncode({'email': email}),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return {'success': true};
  } else {
    final responseData = jsonDecode(response.body);
    return {
      'success': false,
      'error': responseData['detail'] ?? 'Failed to send reset code',
    };
  }
}

  // Reset password
static Future<Map<String, dynamic>> resetPassword(
    String email, String resetCode, String newPassword) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password/'),
      body: jsonEncode({
        'email': email,
        'reset_code': resetCode,
        'new_password': newPassword
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      String rawErrorMessage = response.body;
      return {'success': false, 'error': 'Failed to reset password: $rawErrorMessage'};
    }
  } on SocketException catch (_) {
    print('No Internet connection');
    return {
      'success': false,
      'error': 'No Internet connection. Please check your network and try again.'
    };
  } catch (e) {
    print('Error occurred: $e');
    return {
      'success': false,
      'error': 'An error occurred. Please try again.'
    };
  }
}


  // Fetch user profile
  static Future<User> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<dynamic> resultsJson = jsonData['results'];
      if (resultsJson.isNotEmpty) {
        return User.fromJson(resultsJson[0]);
      } else {
        throw Exception('No user profile found in the response');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access. Please log in again.');
    } else {
      throw Exception('Failed to load user profile: ${response.reasonPhrase}');
    }
  }

  // Update user profile with optional avatar file
  static Future<void> updateUserProfile(User user, File? avatarFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Access token is null');
    }

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/update-profile/'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';

      // Adding form fields
      request.fields['full_name'] = user.fullName ?? '';
      request.fields['username'] = user.username;
      request.fields['email'] = user.email;
      request.fields['phone'] = user.phone ?? '';  
      request.fields['country'] = user.country ?? '';  

      // Adding the avatar file if it's provided
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
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
      throw Exception(
          'Failed to create task. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  }

  // Update a task
  static Future<void> updateTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Access token is null');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/todo/tasks/${task.id}/'),
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

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.reasonPhrase}');
    }
  }
  
  // Delete a task
  static Future<bool> deleteTask(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/todo/tasks/$id/delete/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return response.statusCode == 204;
  }

//Feedback
  static Future<bool> submitFeedback(String username, String email, String message, String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Access token is null');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/todo/send-feedback/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to submit feedback: ${response.reasonPhrase}');
    }
  }
}
