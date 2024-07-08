// models/user.dart
class User {
  final int? id; 
  final String? fullName;
  final String username;
  final String email;
  final String? avatar; 
  final String? password; 
  final String? passwordConfirm;
  final String? phone; // New field
  final String? country; // New field

  User({
    this.id,
    this.fullName,
    required this.username,
    required this.email,
    this.avatar,
    this.password,
    this.passwordConfirm,
    this.phone,  // Initialize the new field
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], 
      fullName: json['full_name'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'], 
      password: json['password'],
      passwordConfirm: json['password_confirm'],
      phone: json['phone'], 
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      if (fullName != null) 'full_name': fullName,
      'username': username,
      'email': email,
      if (avatar != null) 'avatar': avatar,
      if (password != null) 'password': password,
      if (passwordConfirm != null) 'password_confirm': passwordConfirm,
    };
  }
}
