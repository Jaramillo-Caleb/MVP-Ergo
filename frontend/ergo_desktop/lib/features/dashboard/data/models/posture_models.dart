class PostureReferenceModel {
  final String id;
  final String alias;
  final bool isPersistent;
  final DateTime createdAt;

  PostureReferenceModel({
    required this.id,
    required this.alias,
    required this.isPersistent,
    required this.createdAt,
  });

  factory PostureReferenceModel.fromJson(Map<String, dynamic> json) {
    return PostureReferenceModel(
      id: json['id'] ?? '',
      alias: json['alias'] ?? '',
      isPersistent: json['isPersistent'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CreatePostureRequest {
  final String userId;
  final String alias;
  final List<double> vector;
  final bool isPersistent;

  CreatePostureRequest({
    required this.userId,
    required this.alias,
    required this.vector,
    required this.isPersistent,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "alias": alias,
        "vector": vector,
        "isPersistent": isPersistent,
      };
}