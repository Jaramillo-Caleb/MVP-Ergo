import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../models/auth_response_model.dart';

import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/core/di/injection_container.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: '730846430623-nt59lme9ggdkn6qt6lv1ctgdu86513eb.apps.googleusercontent.com',
      scopes: ['email', 'profile']);

  AuthService(this._dio);

  Future<AuthResponseModel?> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponseModel.fromJson(response.data);
        await _saveSession(authData.token, authData.userId, authData.fullName);
        return authData;
      }
    } catch (e) {
      debugPrint("Error Login: $e");
    }
    return null;
  }

  Future<AuthResponseModel?> register(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponseModel.fromJson(response.data);
        await _saveSession(authData.token, authData.userId, authData.fullName);
        return authData;
      }
    } on DioException catch (e) {
      debugPrint("Error Register: ${e.response?.data}");
    }
    return null;
  }

  Future<AuthResponseModel?> loginWithGoogle() async {
    const String clientId = '730846430623-nt59lme9ggdkn6qt6lv1ctgdu86513eb.apps.googleusercontent.com';
    const String redirectUri = "http://localhost:3000/callback";

    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'email profile',
    });

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: "http://localhost:3000",
      );
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return null;
      return await _sendSocialTokenToBackend(provider: "google", token: code);
    } catch (e) {
      debugPrint("Error Google Auth Windows: $e");
      return null;
    }
  }

  Future<AuthResponseModel?> loginWithGitHub() async {
    const String clientId = "Ov23liPTuGbMCFzMTPX1";
    const String redirectUri = "http://localhost:3000/callback";

    final url = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'read:user user:email',
    });

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: "http://localhost:3000/callback",
      );
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return null;
      return await _sendSocialTokenToBackend(provider: "github", token: code);
    } catch (e) {
      debugPrint("Error GitHub Auth: $e");
      return null;
    }
  }

  Future<AuthResponseModel?> _sendSocialTokenToBackend({required String provider, required String token}) async {
    try {
      final response = await _dio.post('/api/auth/social-login', data: {
        "provider": provider,
        "token": token,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponseModel.fromJson(response.data);
        await _saveSession(authData.token, authData.userId, authData.fullName);
        return authData;
      }
    } on DioException catch (e) {
      debugPrint("Error Backend Social: ${e.response?.data}");
    }
    return null;
  }

  Future<void> _saveSession(String token, String userId, [String? fullName]) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id', value: userId);
    if (fullName != null) {
      await _storage.write(key: 'user_name', value: fullName);
    }

    // Prefetch settings for Pomodoro
    sl<WorkSessionService>().prefetchSettings(userId);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    sl<WorkSessionService>().clearCache();
    try {
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      }
    } catch (e) {
      debugPrint("Error signing out from Google: $e");
    }
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
}
