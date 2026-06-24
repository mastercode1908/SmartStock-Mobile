class UserModel {
  final int userId;
  final String email;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final String roleName;
  final String token;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.roleName,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      roleName: json['roleName'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'roleName': roleName,
      'token': token,
    };
  }
}
