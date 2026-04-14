import 'package:dio/dio.dart';
import '../models/posture_models.dart';
import 'package:logger/logger.dart';

class PostureService {
  final Dio _dio;
  final logger = Logger();

  PostureService(this._dio);

  Future<List<PostureReferenceModel>> getPostures(String userId) async {
    try {
      final response = await _dio.get('/api/work-session/postures/$userId');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => PostureReferenceModel.fromJson(e))
            .toList();
      }
    } catch (e, stackTrace) {
      logger.e("Error fetching postures", error: e, stackTrace: stackTrace);
    }
    return [];
  }

  Future<PostureReferenceModel?> createPosture(CreatePostureRequest request) async {
    try {
      final response = await _dio.post(
        '/api/work-session/postures',
        data: request.toJson(),
        options: Options(headers: {"X-User-Id": request.userId}),
      );

      if (response.statusCode == 200) {
        return PostureReferenceModel.fromJson(response.data);
      }
    } catch (e, stackTrace) {
      logger.e("Error creating posture", error: e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<bool> deletePosture(String postureId, String userId) async {
    try {
      final response = await _dio.delete(
        '/api/work-session/postures/$postureId',
        options: Options(headers: {"X-User-Id": userId}),
      );
      return response.statusCode == 204;
    } catch (e, stackTrace) {
      logger.e("Error deleting posture", error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<List<double>?> computeCalibration(List<List<int>> imagesBytes) async {
    try {
      final formData = FormData();
      for (var i = 0; i < imagesBytes.length; i++) {
        formData.files.add(MapEntry(
          'images',
          MultipartFile.fromBytes(imagesBytes[i], filename: 'frame_$i.jpg'),
        ));
      }
      final response = await _dio.post(
        '/api/work-session/calibration/calculate',
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> vector = response.data['vector'];
        return vector.map((e) => (e as num).toDouble()).toList();
      }
    } catch (e) {
      logger.e("Error en computeCalibration", error: e);
    }
    return null;
  }

  Future<String?> startSession(
      {required String postureId,
      required String userId,
      required int mode}) async {
    try {
      final response = await _dio.post(
        '/api/work-session/session/start',
        data: {"postureId": postureId, "userId": userId, "mode": mode},
      );
      if (response.statusCode == 200) {
        return response.data['sessionId'] as String;
      }
    } on DioException catch (e) {
      logger.e("Error 400 - Backend rechazó la solicitud: ${e.response?.data}");
    }
    return null;
  }

  Future<bool?> monitorPosture(String sessionId, List<int> imageBytes) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: 'frame.jpg'),
      });

      final response = await _dio.post(
        '/api/work-session/session/$sessionId/monitor',
        data: formData,
      );

      if (response.statusCode == 200) {
        final bool isAlert = response.data['isAlert'] ?? false;
        return !isAlert;
      }
    } catch (e) {
      logger.e("Error en el Heartbeat de monitoreo", error: e);
    }
    return null;
  }
}
