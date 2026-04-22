import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/users/me');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("Usuario no encontrado (404).");
      } else {
        debugPrint("Error al obtener perfil: ${e.response?.data}");
      }
      return null;
    }
  }

  Future<String?> _persistImageLocally(String originalPath) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final profileImagesDir =
          Directory(p.join(appDocDir.path, 'ergo_desktop', 'profile_images'));

      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      final extension = p.extension(originalPath);
      final newPath =
          p.join(profileImagesDir.path, 'profile_current$extension');
      final newFile = File(newPath);

      // Remove old files to keep directory clean
      if (await newFile.exists()) {
        await newFile.delete();
      }

      // If there's an existing one with different extension (rare but possible), clear it
      await for (final file in profileImagesDir.list()) {
        if (file is File) await file.delete();
      }

      final savedFile = await File(originalPath).copy(newPath);
      return savedFile.path;
    } catch (e) {
      debugPrint("Error persisting image: $e");
      return originalPath;
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
      String? localImagePath = imagePath;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.contains('ergo_desktop')) {
        localImagePath = await _persistImageLocally(imagePath);
      }

      FormData formData = FormData.fromMap({
        "FullName": fullName,
        "BirthDate": birthDate,
        "Gender": gender,
        "Location": location,
        "Occupation": occupation
      });

      if (localImagePath != null && localImagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          "AvatarFile",
          await MultipartFile.fromFile(localImagePath,
              filename: p.basename(localImagePath)),
        ));
      }

      final response = await _dio.post(
        '/users/profile',
        data: formData,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error al actualizar perfil: ${e.response?.data}");
      return false;
    }
  }
}
