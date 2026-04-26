import 'package:flutter/foundation.dart';
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

  Future<bool> updateProfile({
    required String fullName,
    required String birthDate,
    required String gender,
    required String location,
    required String occupation,
    Uint8List? photoBytes,
  }) async {
    try {
      final entry = UsersCompanion(
        id: const Value('me'),
        fullName: Value(fullName),
        email: const Value('user@local'), // Default for local profile
        birthDate: Value(DateTime.tryParse(birthDate) ?? DateTime.now()),
        gender: Value(gender),
        location: Value(location),
        occupation: Value(occupation),
        photo: Value(photoBytes),
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
