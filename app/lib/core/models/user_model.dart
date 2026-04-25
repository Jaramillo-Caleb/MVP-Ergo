import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final DateTime birthDate;
  final String? gender;
  final String? location;
  final String? occupation;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.birthDate,
    this.gender,
    this.location,
    this.occupation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'birth_date': birthDate.toIso8601String(),
        'gender': gender,
        'location': location,
        'occupation': occupation,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        email: map['email'],
        fullName: map['full_name'],
        birthDate: DateTime.parse(map['birth_date']),
        gender: map['gender'],
        location: map['location'],
        occupation: map['occupation'],
        createdAt: DateTime.parse(map['created_at']),
      );

  @override
  List<Object?> get props => [id, email, fullName];
}
