import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class ProfileService extends ChangeNotifier {
  final AppDatabase _db;
  User? _cachedProfile;

  ProfileService({required AppDatabase db}) : _db = db;

  User? get profile => _cachedProfile;

  Future<User?> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    try {
      final query = _db.select(_db.users)..where((t) => t.id.equals('me'));
      _cachedProfile = await query.getSingleOrNull();
      return _cachedProfile;
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
        birthDate: Value(DateTime.tryParse(birthDate) ?? DateTime.now()),
        gender: Value(gender),
        location: Value(location),
        occupation: Value(occupation),
        photo: Value(photoBytes),
        createdAt: Value(DateTime.now()),
      );

      await _db.into(_db.users).insertOnConflictUpdate(entry);
      
      _cachedProfile = await (_db.select(_db.users)..where((t) => t.id.equals('me'))).getSingleOrNull();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil local: $e");
      return false;
    }
  }
}
