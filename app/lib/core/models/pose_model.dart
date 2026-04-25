import 'dart:convert';
import 'package:equatable/equatable.dart';

class ReferencePose extends Equatable {
  final String id;
  final String alias;
  final List<double> vector;
  final bool isPersistent;
  final DateTime createdAt;

  const ReferencePose({
    required this.id,
    required this.alias,
    required this.vector,
    required this.isPersistent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alias': alias,
        'vector': jsonEncode(vector),
        'is_persistent': isPersistent ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReferencePose.fromMap(Map<String, dynamic> map) => ReferencePose(
        id: map['id'],
        alias: map['alias'],
        vector: List<double>.from(jsonDecode(map['vector'])),
        isPersistent: map['is_persistent'] == 1,
        createdAt: DateTime.parse(map['created_at']),
      );

  @override
  List<Object?> get props => [id, alias, vector];
}
