class AuthResponseModel {
  final String token;
  final String email;
  final String userId;
  final String fullName;

  AuthResponseModel({
    required this.token,
    required this.email,
    required this.userId,
    required this.fullName,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}
