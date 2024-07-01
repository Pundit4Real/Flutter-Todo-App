// models/user.dart
class User {
  final String? fullName; // Make fullName optional
  final String username;
  final String email;
  final String? password; // Make password optional
  final String? passwordConfirm; // Add passwordConfirm

  User({
    this.fullName,
    required this.username,
    required this.email,
    this.password,
    this.passwordConfirm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      passwordConfirm: json['password_confirm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
      if (passwordConfirm != null) 'password_confirm': passwordConfirm,
    };
  }
}
