// models/user.dart
class User {
  final int? id; // Add id field
  final String? fullName; // Make fullName optional
  final String username;
  final String email;
  final String? avatar; // Add avatar field
  final String? password; // Make password optional
  final String? passwordConfirm; // Add passwordConfirm

  User({
    this.id,
    this.fullName,
    required this.username,
    required this.email,
    this.avatar,
    this.password,
    this.passwordConfirm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Map id from JSON
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'], // Map avatar from JSON
      password: json['password'],
      passwordConfirm: json['password_confirm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Add id to JSON
      if (fullName != null) 'full_name': fullName,
      'username': username,
      'email': email,
      if (avatar != null) 'avatar': avatar, // Add avatar to JSON
      if (password != null) 'password': password,
      if (passwordConfirm != null) 'password_confirm': passwordConfirm,
    };
  }
}
