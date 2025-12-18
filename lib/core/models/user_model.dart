class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' hoặc 'user'

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  // Chuyển từ Firestore JSON sang Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // Mặc định là user nếu không có role
    );
  }

  // Chuyển từ Object sang JSON để lưu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}