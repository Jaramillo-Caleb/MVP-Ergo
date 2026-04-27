import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/posture_models.dart';
import 'package:logger/logger.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/native/native_bridge.dart';
import 'package:uuid/uuid.dart';

class PostureService {
  final AppDatabase _db;
  final NativeBridge _bridge;
  final logger = Logger();
  final _uuid = const Uuid();

  PostureService({required AppDatabase db, required NativeBridge bridge})
      : _db = db,
        _bridge = bridge;

  Future<List<PostureReferenceModel>> getPostures() async {
    try {
      final rows = await _db.select(_db.referencePoses).get();

      return rows.map((e) {
        return PostureReferenceModel(
          id: e.id,
          alias: e.alias,
          isPersistent: e.isPersistent,
          createdAt: e.createdAt,
          vector: e.vector,
        );
      }).toList();
    } catch (e, stackTrace) {
      logger.e("Error fetching local postures",
          error: e, stackTrace: stackTrace);
    }
    return [];
  }

  Future<PostureReferenceModel?> createPosture(
      String alias, List<double> vector) async {
    try {
      final id = _uuid.v4();
      final vectorStr = vector.join(',');
      final now = DateTime.now();

      final entry = ReferencePosesCompanion(
        id: Value(id),
        alias: Value(alias),
        vector: Value(vectorStr),
        isPersistent: const Value(true),
        createdAt: Value(now),
      );

      await _db.into(_db.referencePoses).insert(entry);

      return PostureReferenceModel(
        id: id,
        alias: alias,
        isPersistent: true,
        createdAt: now,
        vector: vectorStr,
      );
    } catch (e, stackTrace) {
      logger.e("Error creating local posture",
          error: e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<bool> deletePosture(String postureId) async {
    try {
      final count = await (_db.delete(_db.referencePoses)
            ..where((t) => t.id.equals(postureId)))
          .go();
      return count > 0;
    } catch (e, stackTrace) {
      logger.e("Error deleting local posture",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> updatePosture(String id, String alias) async {
    try {
      final count = await (_db.update(_db.referencePoses)
            ..where((t) => t.id.equals(id)))
          .write(ReferencePosesCompanion(alias: Value(alias)));
      return count > 0;
    } catch (e, stackTrace) {
      logger.e("Error updating local posture",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> updatePostureVector(String id, List<double> vector) async {
    try {
      final vectorStr = vector.join(',');
      final count = await (_db.update(_db.referencePoses)
            ..where((t) => t.id.equals(id)))
          .write(ReferencePosesCompanion(vector: Value(vectorStr)));
      return count > 0;
    } catch (e, stackTrace) {
      logger.e("Error updating posture vector",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<List<double>?> computeCalibration(List<Uint8List> imagesBytes) async {
    if (imagesBytes.isEmpty) return null;

    try {
      final vectors = _bridge.extractMultipleVectors(imagesBytes);
      if (vectors.isEmpty) return null;

      // Calcular el promedio de los vectores extraídos
      final List<double> averageVector = List<double>.filled(15, 0.0);
      for (final v in vectors) {
        for (int i = 0; i < 15; i++) {
          averageVector[i] += v[i];
        }
      }

      for (int i = 0; i < 15; i++) {
        averageVector[i] /= vectors.length;
      }

      return averageVector;
    } catch (e) {
      logger.e("Error en calibración nativa", error: e);
    }
    return null;
  }

  Future<bool> getShowCalibrationInstructions() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'calibration_show_instr.txt'));
      if (!await file.exists()) return true;
      final content = await file.readAsString();
      return content.trim() != 'false';
    } catch (e) {
      return true;
    }
  }

  Future<void> setShowCalibrationInstructions(bool show) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'calibration_show_instr.txt'));
      await file.writeAsString(show.toString());
    } catch (e) {
      debugPrint("Error saving calibration instructions preference: $e");
    }
  }

  Future<bool?> monitorPosture(
      List<double> referenceVector, List<int> frame) async {
    try {
      final result = _bridge.processFrame(referenceVector, frame);
      return !result.$2;
    } catch (e) {
      logger.e("Error en monitoreo nativo", error: e);
    }
    return null;
  }
}
