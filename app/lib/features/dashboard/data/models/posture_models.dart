enum AppMode { idle, calibrating, monitoring, pausedMonitoring }
enum PostureStatus { unknown, correct, incorrect, userNotFound, verifying }

class PostureReferenceModel {
  final String id;
  final String alias;
  final bool isPersistent;
  final DateTime createdAt;
  final String? vector;

  PostureReferenceModel({
    required this.id,
    required this.alias,
    required this.isPersistent,
    required this.createdAt,
    this.vector,
  });

  List<double> get vectorList {
    if (vector == null || vector!.isEmpty) return [];
    return vector!.split(',').map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  factory PostureReferenceModel.fromJson(Map<String, dynamic> json) {
    return PostureReferenceModel(
      id: json['id'] ?? '',
      alias: json['alias'] ?? '',
      isPersistent: json['isPersistent'] ?? true,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      vector: json['vector'],
    );
  }
}

class CreatePostureRequest {
  final String alias;
  final List<double> vector;
  final bool isPersistent;

  CreatePostureRequest({
    required this.alias,
    required this.vector,
    required this.isPersistent,
  });

  Map<String, dynamic> toJson() => {
        "alias": alias,
        "vector": vector,
        "isPersistent": isPersistent,
      };
}
