import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AccountService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

/*
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: '730846430623-nt59lme9ggdkn6qt6lv1ctgdu86513eb.apps.googleusercontent.com',
      scopes: ['email', 'profile']);
*/
  AccountService(this._dio);

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/api/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Error al obtener perfil: ${e.response?.data}");
      return null;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response =
          await _dio.post('/api/auth/forgot-password', data: {"email": email});
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error al solicitar reset: $e");
      return false;
    }
  }

  Future<bool> resetPassword(
      String email, String code, String newPassword) async {
    try {
      final response = await _dio.post('/api/auth/reset-password', data: {
        "email": email,
        "code": code,
        "newPassword": newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error al resetear contraseña: $e");
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String birthDate,
    required String gender,
    required String location,
    required String occupation,
    String? imagePath,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Usamos FormData por si en el futuro decides enviar la imagen
      FormData formData = FormData.fromMap({
        "FullName": fullName,
        "BirthDate": birthDate,
        "Gender": gender,
        "Location": location,
        "Occupation": occupation
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          "profileImage",
          await MultipartFile.fromFile(imagePath,
              filename: imagePath.split('/').last),
        ));
      }

      final response = await _dio.put(
        '/api/auth/profile',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error al actualizar perfil: ${e.response?.data}");
      return false;
    }
  }
}
