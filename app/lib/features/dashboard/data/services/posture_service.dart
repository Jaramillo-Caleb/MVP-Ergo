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
        );
      }).toList();
    } catch (e, stackTrace) {
      logger.e("Error fetching local postures", error: e, stackTrace: stackTrace);
    }
    return [];
  }

  Future<PostureReferenceModel?> createPosture(String alias, List<double> vector) async {
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
      );
    } catch (e, stackTrace) {
      logger.e("Error creating local posture", error: e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<bool> deletePosture(String postureId) async {
    try {
      final count = await (_db.delete(_db.referencePoses)..where((t) => t.id.equals(postureId))).go();
      return count > 0;
    } catch (e, stackTrace) {
      logger.e("Error deleting local posture", error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<List<double>?> computeCalibration(List<Uint8List> imagesBytes) async {
    return null; 
  }

  Future<bool?> monitorPosture(List<double> referenceVector, List<int> frame) async {
    try {
      final result = _bridge.processFrame(referenceVector, frame);
      return !result.$2; 
    } catch (e) {
      logger.e("Error en monitoreo nativo", error: e);
    }
    return null;
  }
}
