import '../models/posture_models.dart';
import 'package:logger/logger.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/native/native_bridge.dart';
import '../../../pomodoro/data/services/work_session_service.dart';
import '../../../pomodoro/data/models/work_session_model.dart';
import 'package:uuid/uuid.dart';

class PostureService {
  final AppDatabase _db;
  final NativeBridge _bridge;
  final logger = Logger();
  final _uuid = const Uuid();

  PostureService({required AppDatabase db, required NativeBridge bridge})
      : _db = db,
        _bridge = bridge;

  WorkSessionService get _sessionService =>
      GetIt.instance<WorkSessionService>();

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
    final vectors = _bridge.extractMultipleVectors(imagesBytes);
    if (vectors.isEmpty) return null;

    // Descartar outliers: quedarse con los vectores más cercanos al centroide
    final int vectorSize = vectors.first.length;
    final List<double> centroid = List<double>.filled(vectorSize, 0.0);

    for (final v in vectors) {
      for (int i = 0; i < vectorSize; i++) {
        centroid[i] += v[i];
      }
    }
    for (int i = 0; i < vectorSize; i++) {
      centroid[i] /= vectors.length;
    }

    // Calcular distancia de cada vector al centroide
    double dist(List<double> a, List<double> b) {
      double s = 0;
      for (int i = 0; i < a.length; i++) {
        s += (a[i] - b[i]) * (a[i] - b[i]);
      }
      return s;
    }

    // Ordenar por cercanía al centroide y usar solo los 3 mejores
    final sorted = [...vectors]
      ..sort((a, b) => dist(a, centroid).compareTo(dist(b, centroid)));
    final best = sorted.take(3).toList();

    final List<double> result = List<double>.filled(vectorSize, 0.0);
    for (final v in best) {
      for (int i = 0; i < vectorSize; i++) {
        result[i] += v[i];
      }
    }
    for (int i = 0; i < vectorSize; i++) {
      result[i] /= best.length;
    }

    return result;
  }

  Future<bool> getShowCalibrationInstructions() async {
    final settings = await _sessionService.getSettings();
    return settings?.showCalibrationInstructions ?? true;
  }

  Future<void> setShowCalibrationInstructions(bool show) async {
    final current = await _sessionService.getSettings() ?? const AppSettings();
    await _sessionService
        .updateSettings(current.copyWith(showCalibrationInstructions: show));
  }

  Future<String> getMonitoringIntensity() async {
    final settings = await _sessionService.getSettings();
    return settings?.monitoringIntensity ?? 'Medio';
  }

  Future<void> setMonitoringIntensity(String intensity) async {
    final current = await _sessionService.getSettings() ?? const AppSettings();
    await _sessionService
        .updateSettings(current.copyWith(monitoringIntensity: intensity));
  }

  double _mapIntensityToThreshold(String intensity) {
    switch (intensity) {
      case 'Alto':
        return 0.80;
      case 'Bajo':
        return 0.60;
      case 'Medio':
      default:
        return 0.70;
    }
  }

  Future<bool?> monitorPosture(
      List<double> referenceVector, List<int> frame) async {
    try {
      final intensity = await getMonitoringIntensity();
      final threshold = _mapIntensityToThreshold(intensity);

      final result = _bridge.processFrame(referenceVector, frame, threshold);

      final double score = result.$1;
      final bool alert = result.$2;

      // Score exactamente 1.0 = sin usuario o frame inválido, ignorar
      if (score >= 0.999) return null; // null = no hay datos, no es alerta

      return !alert;
    } catch (e) {
      logger.e("Error en monitoreo nativo", error: e);
    }
    return null;
  }
}
