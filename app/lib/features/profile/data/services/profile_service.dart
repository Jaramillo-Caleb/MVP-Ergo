import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class ProfileService {
  final AppDatabase _db;

  ProfileService({required AppDatabase db}) : _db = db;

  Future<User?> getProfile() async {
    try {
      final query = _db.select(_db.users)..limit(1);
      return await query.getSingleOrNull();
    } catch (e) {
      debugPrint("Error al obtener perfil local: $e");
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

      if (await newFile.exists()) {
        await newFile.delete();
      }

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

      final entry = UsersCompanion(
        id: const Value('me'),
        fullName: Value(fullName),
        email: const Value('user@local'), // Default for local profile
        birthDate: Value(DateTime.tryParse(birthDate) ?? DateTime.now()),
        gender: Value(gender),
        location: Value(location),
        occupation: Value(occupation),
        avatarPath: Value(localImagePath),
        createdAt: Value(DateTime.now()),
      );

      await _db.into(_db.users).insertOnConflictUpdate(entry);

      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil local: $e");
      return false;
    }
  }
}
