// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _occupationMeta =
      const VerificationMeta('occupation');
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
      'occupation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
      'photo', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fullName, birthDate, gender, location, occupation, photo, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('occupation')) {
      context.handle(
          _occupationMeta,
          occupation.isAcceptableOrUnknown(
              data['occupation']!, _occupationMeta));
    }
    if (data.containsKey('photo')) {
      context.handle(
          _photoMeta, photo.isAcceptableOrUnknown(data['photo']!, _photoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      occupation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}occupation']),
      photo: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}photo']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String? gender;
  final String? location;
  final String? occupation;
  final Uint8List? photo;
  final DateTime createdAt;
  const User(
      {required this.id,
      required this.fullName,
      required this.birthDate,
      this.gender,
      this.location,
      this.occupation,
      this.photo,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || occupation != null) {
      map['occupation'] = Variable<String>(occupation);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      birthDate: Value(birthDate),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      occupation: occupation == null && nullToAbsent
          ? const Value.absent()
          : Value(occupation),
      photo:
          photo == null && nullToAbsent ? const Value.absent() : Value(photo),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      gender: serializer.fromJson<String?>(json['gender']),
      location: serializer.fromJson<String?>(json['location']),
      occupation: serializer.fromJson<String?>(json['occupation']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'gender': serializer.toJson<String?>(gender),
      'location': serializer.toJson<String?>(location),
      'occupation': serializer.toJson<String?>(occupation),
      'photo': serializer.toJson<Uint8List?>(photo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {String? id,
          String? fullName,
          DateTime? birthDate,
          Value<String?> gender = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> occupation = const Value.absent(),
          Value<Uint8List?> photo = const Value.absent(),
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        birthDate: birthDate ?? this.birthDate,
        gender: gender.present ? gender.value : this.gender,
        location: location.present ? location.value : this.location,
        occupation: occupation.present ? occupation.value : this.occupation,
        photo: photo.present ? photo.value : this.photo,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      location: data.location.present ? data.location.value : this.location,
      occupation:
          data.occupation.present ? data.occupation.value : this.occupation,
      photo: data.photo.present ? data.photo.value : this.photo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('location: $location, ')
          ..write('occupation: $occupation, ')
          ..write('photo: $photo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, birthDate, gender, location,
      occupation, $driftBlobEquality.hash(photo), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.location == this.location &&
          other.occupation == this.occupation &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<DateTime> birthDate;
  final Value<String?> gender;
  final Value<String?> location;
  final Value<String?> occupation;
  final Value<Uint8List?> photo;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.location = const Value.absent(),
    this.occupation = const Value.absent(),
    this.photo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String fullName,
    required DateTime birthDate,
    this.gender = const Value.absent(),
    this.location = const Value.absent(),
    this.occupation = const Value.absent(),
    this.photo = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        birthDate = Value(birthDate),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<String>? location,
    Expression<String>? occupation,
    Expression<Uint8List>? photo,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (location != null) 'location': location,
      if (occupation != null) 'occupation': occupation,
      if (photo != null) 'photo': photo,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<DateTime>? birthDate,
      Value<String?>? gender,
      Value<String?>? location,
      Value<String?>? occupation,
      Value<Uint8List?>? photo,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('location: $location, ')
          ..write('occupation: $occupation, ')
          ..write('photo: $photo, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferencePosesTable extends ReferencePoses
    with TableInfo<$ReferencePosesTable, ReferencePose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferencePosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<String> vector = GeneratedColumn<String>(
      'vector', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPersistentMeta =
      const VerificationMeta('isPersistent');
  @override
  late final GeneratedColumn<bool> isPersistent = GeneratedColumn<bool>(
      'is_persistent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_persistent" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, alias, vector, isPersistent, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_poses';
  @override
  VerificationContext validateIntegrity(Insertable<ReferencePose> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(_vectorMeta,
          vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta));
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    if (data.containsKey('is_persistent')) {
      context.handle(
          _isPersistentMeta,
          isPersistent.isAcceptableOrUnknown(
              data['is_persistent']!, _isPersistentMeta));
    } else if (isInserting) {
      context.missing(_isPersistentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferencePose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferencePose(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      vector: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vector'])!,
      isPersistent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_persistent'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReferencePosesTable createAlias(String alias) {
    return $ReferencePosesTable(attachedDatabase, alias);
  }
}

class ReferencePose extends DataClass implements Insertable<ReferencePose> {
  final String id;
  final String alias;
  final String vector;
  final bool isPersistent;
  final DateTime createdAt;
  const ReferencePose(
      {required this.id,
      required this.alias,
      required this.vector,
      required this.isPersistent,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['alias'] = Variable<String>(alias);
    map['vector'] = Variable<String>(vector);
    map['is_persistent'] = Variable<bool>(isPersistent);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReferencePosesCompanion toCompanion(bool nullToAbsent) {
    return ReferencePosesCompanion(
      id: Value(id),
      alias: Value(alias),
      vector: Value(vector),
      isPersistent: Value(isPersistent),
      createdAt: Value(createdAt),
    );
  }

  factory ReferencePose.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferencePose(
      id: serializer.fromJson<String>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      vector: serializer.fromJson<String>(json['vector']),
      isPersistent: serializer.fromJson<bool>(json['isPersistent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alias': serializer.toJson<String>(alias),
      'vector': serializer.toJson<String>(vector),
      'isPersistent': serializer.toJson<bool>(isPersistent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReferencePose copyWith(
          {String? id,
          String? alias,
          String? vector,
          bool? isPersistent,
          DateTime? createdAt}) =>
      ReferencePose(
        id: id ?? this.id,
        alias: alias ?? this.alias,
        vector: vector ?? this.vector,
        isPersistent: isPersistent ?? this.isPersistent,
        createdAt: createdAt ?? this.createdAt,
      );
  ReferencePose copyWithCompanion(ReferencePosesCompanion data) {
    return ReferencePose(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      vector: data.vector.present ? data.vector.value : this.vector,
      isPersistent: data.isPersistent.present
          ? data.isPersistent.value
          : this.isPersistent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferencePose(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('vector: $vector, ')
          ..write('isPersistent: $isPersistent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alias, vector, isPersistent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferencePose &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.vector == this.vector &&
          other.isPersistent == this.isPersistent &&
          other.createdAt == this.createdAt);
}

class ReferencePosesCompanion extends UpdateCompanion<ReferencePose> {
  final Value<String> id;
  final Value<String> alias;
  final Value<String> vector;
  final Value<bool> isPersistent;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReferencePosesCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.vector = const Value.absent(),
    this.isPersistent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferencePosesCompanion.insert({
    required String id,
    required String alias,
    required String vector,
    required bool isPersistent,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        alias = Value(alias),
        vector = Value(vector),
        isPersistent = Value(isPersistent),
        createdAt = Value(createdAt);
  static Insertable<ReferencePose> custom({
    Expression<String>? id,
    Expression<String>? alias,
    Expression<String>? vector,
    Expression<bool>? isPersistent,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (vector != null) 'vector': vector,
      if (isPersistent != null) 'is_persistent': isPersistent,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferencePosesCompanion copyWith(
      {Value<String>? id,
      Value<String>? alias,
      Value<String>? vector,
      Value<bool>? isPersistent,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ReferencePosesCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      vector: vector ?? this.vector,
      isPersistent: isPersistent ?? this.isPersistent,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (vector.present) {
      map['vector'] = Variable<String>(vector.value);
    }
    if (isPersistent.present) {
      map['is_persistent'] = Variable<bool>(isPersistent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferencePosesCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('vector: $vector, ')
          ..write('isPersistent: $isPersistent, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkSessionsTable extends WorkSessions
    with TableInfo<$WorkSessionsTable, WorkSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
      'mode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scoreAverageMeta =
      const VerificationMeta('scoreAverage');
  @override
  late final GeneratedColumn<double> scoreAverage = GeneratedColumn<double>(
      'score_average', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, startTime, endTime, mode, scoreAverage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('score_average')) {
      context.handle(
          _scoreAverageMeta,
          scoreAverage.isAcceptableOrUnknown(
              data['score_average']!, _scoreAverageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mode'])!,
      scoreAverage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score_average']),
    );
  }

  @override
  $WorkSessionsTable createAlias(String alias) {
    return $WorkSessionsTable(attachedDatabase, alias);
  }
}

class WorkSession extends DataClass implements Insertable<WorkSession> {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int mode;
  final double? scoreAverage;
  const WorkSession(
      {required this.id,
      required this.startTime,
      this.endTime,
      required this.mode,
      this.scoreAverage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['mode'] = Variable<int>(mode);
    if (!nullToAbsent || scoreAverage != null) {
      map['score_average'] = Variable<double>(scoreAverage);
    }
    return map;
  }

  WorkSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkSessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      mode: Value(mode),
      scoreAverage: scoreAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreAverage),
    );
  }

  factory WorkSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkSession(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      mode: serializer.fromJson<int>(json['mode']),
      scoreAverage: serializer.fromJson<double?>(json['scoreAverage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'mode': serializer.toJson<int>(mode),
      'scoreAverage': serializer.toJson<double?>(scoreAverage),
    };
  }

  WorkSession copyWith(
          {String? id,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          int? mode,
          Value<double?> scoreAverage = const Value.absent()}) =>
      WorkSession(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        mode: mode ?? this.mode,
        scoreAverage:
            scoreAverage.present ? scoreAverage.value : this.scoreAverage,
      );
  WorkSession copyWithCompanion(WorkSessionsCompanion data) {
    return WorkSession(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      mode: data.mode.present ? data.mode.value : this.mode,
      scoreAverage: data.scoreAverage.present
          ? data.scoreAverage.value
          : this.scoreAverage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkSession(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('scoreAverage: $scoreAverage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startTime, endTime, mode, scoreAverage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkSession &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.mode == this.mode &&
          other.scoreAverage == this.scoreAverage);
}

class WorkSessionsCompanion extends UpdateCompanion<WorkSession> {
  final Value<String> id;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> mode;
  final Value<double?> scoreAverage;
  final Value<int> rowid;
  const WorkSessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.mode = const Value.absent(),
    this.scoreAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkSessionsCompanion.insert({
    required String id,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required int mode,
    this.scoreAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startTime = Value(startTime),
        mode = Value(mode);
  static Insertable<WorkSession> custom({
    Expression<String>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? mode,
    Expression<double>? scoreAverage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (mode != null) 'mode': mode,
      if (scoreAverage != null) 'score_average': scoreAverage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkSessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int>? mode,
      Value<double?>? scoreAverage,
      Value<int>? rowid}) {
    return WorkSessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      scoreAverage: scoreAverage ?? this.scoreAverage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (scoreAverage.present) {
      map['score_average'] = Variable<double>(scoreAverage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('scoreAverage: $scoreAverage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workDurationMeta =
      const VerificationMeta('workDuration');
  @override
  late final GeneratedColumn<int> workDuration = GeneratedColumn<int>(
      'work_duration', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _breakDurationMeta =
      const VerificationMeta('breakDuration');
  @override
  late final GeneratedColumn<int> breakDuration = GeneratedColumn<int>(
      'break_duration', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _autoStartMeta =
      const VerificationMeta('autoStart');
  @override
  late final GeneratedColumn<bool> autoStart = GeneratedColumn<bool>(
      'auto_start', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("auto_start" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _taskSortStrategyMeta =
      const VerificationMeta('taskSortStrategy');
  @override
  late final GeneratedColumn<String> taskSortStrategy = GeneratedColumn<String>(
      'task_sort_strategy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("Prioridad"));
  static const VerificationMeta _monitoringIntensityMeta =
      const VerificationMeta('monitoringIntensity');
  @override
  late final GeneratedColumn<String> monitoringIntensity =
      GeneratedColumn<String>('monitoring_intensity', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant("Medio"));
  static const VerificationMeta _showCalibrationInstructionsMeta =
      const VerificationMeta('showCalibrationInstructions');
  @override
  late final GeneratedColumn<bool> showCalibrationInstructions =
      GeneratedColumn<bool>('show_calibration_instructions', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("show_calibration_instructions" IN (0, 1))'),
          defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        workDuration,
        breakDuration,
        autoStart,
        repetitions,
        taskSortStrategy,
        monitoringIntensity,
        showCalibrationInstructions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('work_duration')) {
      context.handle(
          _workDurationMeta,
          workDuration.isAcceptableOrUnknown(
              data['work_duration']!, _workDurationMeta));
    }
    if (data.containsKey('break_duration')) {
      context.handle(
          _breakDurationMeta,
          breakDuration.isAcceptableOrUnknown(
              data['break_duration']!, _breakDurationMeta));
    }
    if (data.containsKey('auto_start')) {
      context.handle(_autoStartMeta,
          autoStart.isAcceptableOrUnknown(data['auto_start']!, _autoStartMeta));
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    if (data.containsKey('task_sort_strategy')) {
      context.handle(
          _taskSortStrategyMeta,
          taskSortStrategy.isAcceptableOrUnknown(
              data['task_sort_strategy']!, _taskSortStrategyMeta));
    }
    if (data.containsKey('monitoring_intensity')) {
      context.handle(
          _monitoringIntensityMeta,
          monitoringIntensity.isAcceptableOrUnknown(
              data['monitoring_intensity']!, _monitoringIntensityMeta));
    }
    if (data.containsKey('show_calibration_instructions')) {
      context.handle(
          _showCalibrationInstructionsMeta,
          showCalibrationInstructions.isAcceptableOrUnknown(
              data['show_calibration_instructions']!,
              _showCalibrationInstructionsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      workDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_duration'])!,
      breakDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}break_duration'])!,
      autoStart: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_start'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      taskSortStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}task_sort_strategy'])!,
      monitoringIntensity: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}monitoring_intensity'])!,
      showCalibrationInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}show_calibration_instructions'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String userId;
  final int workDuration;
  final int breakDuration;
  final bool autoStart;
  final int repetitions;
  final String taskSortStrategy;
  final String monitoringIntensity;
  final bool showCalibrationInstructions;
  const Setting(
      {required this.userId,
      required this.workDuration,
      required this.breakDuration,
      required this.autoStart,
      required this.repetitions,
      required this.taskSortStrategy,
      required this.monitoringIntensity,
      required this.showCalibrationInstructions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['work_duration'] = Variable<int>(workDuration);
    map['break_duration'] = Variable<int>(breakDuration);
    map['auto_start'] = Variable<bool>(autoStart);
    map['repetitions'] = Variable<int>(repetitions);
    map['task_sort_strategy'] = Variable<String>(taskSortStrategy);
    map['monitoring_intensity'] = Variable<String>(monitoringIntensity);
    map['show_calibration_instructions'] =
        Variable<bool>(showCalibrationInstructions);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      userId: Value(userId),
      workDuration: Value(workDuration),
      breakDuration: Value(breakDuration),
      autoStart: Value(autoStart),
      repetitions: Value(repetitions),
      taskSortStrategy: Value(taskSortStrategy),
      monitoringIntensity: Value(monitoringIntensity),
      showCalibrationInstructions: Value(showCalibrationInstructions),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      userId: serializer.fromJson<String>(json['userId']),
      workDuration: serializer.fromJson<int>(json['workDuration']),
      breakDuration: serializer.fromJson<int>(json['breakDuration']),
      autoStart: serializer.fromJson<bool>(json['autoStart']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      taskSortStrategy: serializer.fromJson<String>(json['taskSortStrategy']),
      monitoringIntensity:
          serializer.fromJson<String>(json['monitoringIntensity']),
      showCalibrationInstructions:
          serializer.fromJson<bool>(json['showCalibrationInstructions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'workDuration': serializer.toJson<int>(workDuration),
      'breakDuration': serializer.toJson<int>(breakDuration),
      'autoStart': serializer.toJson<bool>(autoStart),
      'repetitions': serializer.toJson<int>(repetitions),
      'taskSortStrategy': serializer.toJson<String>(taskSortStrategy),
      'monitoringIntensity': serializer.toJson<String>(monitoringIntensity),
      'showCalibrationInstructions':
          serializer.toJson<bool>(showCalibrationInstructions),
    };
  }

  Setting copyWith(
          {String? userId,
          int? workDuration,
          int? breakDuration,
          bool? autoStart,
          int? repetitions,
          String? taskSortStrategy,
          String? monitoringIntensity,
          bool? showCalibrationInstructions}) =>
      Setting(
        userId: userId ?? this.userId,
        workDuration: workDuration ?? this.workDuration,
        breakDuration: breakDuration ?? this.breakDuration,
        autoStart: autoStart ?? this.autoStart,
        repetitions: repetitions ?? this.repetitions,
        taskSortStrategy: taskSortStrategy ?? this.taskSortStrategy,
        monitoringIntensity: monitoringIntensity ?? this.monitoringIntensity,
        showCalibrationInstructions:
            showCalibrationInstructions ?? this.showCalibrationInstructions,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      userId: data.userId.present ? data.userId.value : this.userId,
      workDuration: data.workDuration.present
          ? data.workDuration.value
          : this.workDuration,
      breakDuration: data.breakDuration.present
          ? data.breakDuration.value
          : this.breakDuration,
      autoStart: data.autoStart.present ? data.autoStart.value : this.autoStart,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      taskSortStrategy: data.taskSortStrategy.present
          ? data.taskSortStrategy.value
          : this.taskSortStrategy,
      monitoringIntensity: data.monitoringIntensity.present
          ? data.monitoringIntensity.value
          : this.monitoringIntensity,
      showCalibrationInstructions: data.showCalibrationInstructions.present
          ? data.showCalibrationInstructions.value
          : this.showCalibrationInstructions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('userId: $userId, ')
          ..write('workDuration: $workDuration, ')
          ..write('breakDuration: $breakDuration, ')
          ..write('autoStart: $autoStart, ')
          ..write('repetitions: $repetitions, ')
          ..write('taskSortStrategy: $taskSortStrategy, ')
          ..write('monitoringIntensity: $monitoringIntensity, ')
          ..write('showCalibrationInstructions: $showCalibrationInstructions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      workDuration,
      breakDuration,
      autoStart,
      repetitions,
      taskSortStrategy,
      monitoringIntensity,
      showCalibrationInstructions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.userId == this.userId &&
          other.workDuration == this.workDuration &&
          other.breakDuration == this.breakDuration &&
          other.autoStart == this.autoStart &&
          other.repetitions == this.repetitions &&
          other.taskSortStrategy == this.taskSortStrategy &&
          other.monitoringIntensity == this.monitoringIntensity &&
          other.showCalibrationInstructions ==
              this.showCalibrationInstructions);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> userId;
  final Value<int> workDuration;
  final Value<int> breakDuration;
  final Value<bool> autoStart;
  final Value<int> repetitions;
  final Value<String> taskSortStrategy;
  final Value<String> monitoringIntensity;
  final Value<bool> showCalibrationInstructions;
  final Value<int> rowid;
  const SettingsCompanion({
    this.userId = const Value.absent(),
    this.workDuration = const Value.absent(),
    this.breakDuration = const Value.absent(),
    this.autoStart = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.taskSortStrategy = const Value.absent(),
    this.monitoringIntensity = const Value.absent(),
    this.showCalibrationInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String userId,
    this.workDuration = const Value.absent(),
    this.breakDuration = const Value.absent(),
    this.autoStart = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.taskSortStrategy = const Value.absent(),
    this.monitoringIntensity = const Value.absent(),
    this.showCalibrationInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<Setting> custom({
    Expression<String>? userId,
    Expression<int>? workDuration,
    Expression<int>? breakDuration,
    Expression<bool>? autoStart,
    Expression<int>? repetitions,
    Expression<String>? taskSortStrategy,
    Expression<String>? monitoringIntensity,
    Expression<bool>? showCalibrationInstructions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (workDuration != null) 'work_duration': workDuration,
      if (breakDuration != null) 'break_duration': breakDuration,
      if (autoStart != null) 'auto_start': autoStart,
      if (repetitions != null) 'repetitions': repetitions,
      if (taskSortStrategy != null) 'task_sort_strategy': taskSortStrategy,
      if (monitoringIntensity != null)
        'monitoring_intensity': monitoringIntensity,
      if (showCalibrationInstructions != null)
        'show_calibration_instructions': showCalibrationInstructions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? userId,
      Value<int>? workDuration,
      Value<int>? breakDuration,
      Value<bool>? autoStart,
      Value<int>? repetitions,
      Value<String>? taskSortStrategy,
      Value<String>? monitoringIntensity,
      Value<bool>? showCalibrationInstructions,
      Value<int>? rowid}) {
    return SettingsCompanion(
      userId: userId ?? this.userId,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      autoStart: autoStart ?? this.autoStart,
      repetitions: repetitions ?? this.repetitions,
      taskSortStrategy: taskSortStrategy ?? this.taskSortStrategy,
      monitoringIntensity: monitoringIntensity ?? this.monitoringIntensity,
      showCalibrationInstructions:
          showCalibrationInstructions ?? this.showCalibrationInstructions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (workDuration.present) {
      map['work_duration'] = Variable<int>(workDuration.value);
    }
    if (breakDuration.present) {
      map['break_duration'] = Variable<int>(breakDuration.value);
    }
    if (autoStart.present) {
      map['auto_start'] = Variable<bool>(autoStart.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (taskSortStrategy.present) {
      map['task_sort_strategy'] = Variable<String>(taskSortStrategy.value);
    }
    if (monitoringIntensity.present) {
      map['monitoring_intensity'] = Variable<String>(monitoringIntensity.value);
    }
    if (showCalibrationInstructions.present) {
      map['show_calibration_instructions'] =
          Variable<bool>(showCalibrationInstructions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('userId: $userId, ')
          ..write('workDuration: $workDuration, ')
          ..write('breakDuration: $breakDuration, ')
          ..write('autoStart: $autoStart, ')
          ..write('repetitions: $repetitions, ')
          ..write('taskSortStrategy: $taskSortStrategy, ')
          ..write('monitoringIntensity: $monitoringIntensity, ')
          ..write('showCalibrationInstructions: $showCalibrationInstructions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, priority, date, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String description;
  final int priority;
  final DateTime date;
  final int status;
  final DateTime createdAt;
  const Task(
      {required this.id,
      required this.title,
      required this.description,
      required this.priority,
      required this.date,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['priority'] = Variable<int>(priority);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      priority: Value(priority),
      date: Value(date),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      priority: serializer.fromJson<int>(json['priority']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'priority': serializer.toJson<int>(priority),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith(
          {String? id,
          String? title,
          String? description,
          int? priority,
          DateTime? date,
          int? status,
          DateTime? createdAt}) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        date: date ?? this.date,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, priority, date, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.date == this.date &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> priority;
  final Value<DateTime> date;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required String description,
    required int priority,
    required DateTime date,
    required int status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        priority = Value(priority),
        date = Value(date),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<DateTime>? date,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<int>? priority,
      Value<DateTime>? date,
      Value<int>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ReferencePosesTable referencePoses = $ReferencePosesTable(this);
  late final $WorkSessionsTable workSessions = $WorkSessionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, referencePoses, workSessions, settings, tasks];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String fullName,
  required DateTime birthDate,
  Value<String?> gender,
  Value<String?> location,
  Value<String?> occupation,
  Value<Uint8List?> photo,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> fullName,
  Value<DateTime> birthDate,
  Value<String?> gender,
  Value<String?> location,
  Value<String?> occupation,
  Value<Uint8List?> photo,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get photo => $composableBuilder(
      column: $table.photo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<DateTime> birthDate = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> occupation = const Value.absent(),
            Value<Uint8List?> photo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            fullName: fullName,
            birthDate: birthDate,
            gender: gender,
            location: location,
            occupation: occupation,
            photo: photo,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            required DateTime birthDate,
            Value<String?> gender = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> occupation = const Value.absent(),
            Value<Uint8List?> photo = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            fullName: fullName,
            birthDate: birthDate,
            gender: gender,
            location: location,
            occupation: occupation,
            photo: photo,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$ReferencePosesTableCreateCompanionBuilder = ReferencePosesCompanion
    Function({
  required String id,
  required String alias,
  required String vector,
  required bool isPersistent,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ReferencePosesTableUpdateCompanionBuilder = ReferencePosesCompanion
    Function({
  Value<String> id,
  Value<String> alias,
  Value<String> vector,
  Value<bool> isPersistent,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ReferencePosesTableFilterComposer
    extends Composer<_$AppDatabase, $ReferencePosesTable> {
  $$ReferencePosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vector => $composableBuilder(
      column: $table.vector, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPersistent => $composableBuilder(
      column: $table.isPersistent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReferencePosesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferencePosesTable> {
  $$ReferencePosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vector => $composableBuilder(
      column: $table.vector, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPersistent => $composableBuilder(
      column: $table.isPersistent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReferencePosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferencePosesTable> {
  $$ReferencePosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<bool> get isPersistent => $composableBuilder(
      column: $table.isPersistent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReferencePosesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReferencePosesTable,
    ReferencePose,
    $$ReferencePosesTableFilterComposer,
    $$ReferencePosesTableOrderingComposer,
    $$ReferencePosesTableAnnotationComposer,
    $$ReferencePosesTableCreateCompanionBuilder,
    $$ReferencePosesTableUpdateCompanionBuilder,
    (
      ReferencePose,
      BaseReferences<_$AppDatabase, $ReferencePosesTable, ReferencePose>
    ),
    ReferencePose,
    PrefetchHooks Function()> {
  $$ReferencePosesTableTableManager(
      _$AppDatabase db, $ReferencePosesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferencePosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferencePosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferencePosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> alias = const Value.absent(),
            Value<String> vector = const Value.absent(),
            Value<bool> isPersistent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferencePosesCompanion(
            id: id,
            alias: alias,
            vector: vector,
            isPersistent: isPersistent,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String alias,
            required String vector,
            required bool isPersistent,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferencePosesCompanion.insert(
            id: id,
            alias: alias,
            vector: vector,
            isPersistent: isPersistent,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferencePosesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReferencePosesTable,
    ReferencePose,
    $$ReferencePosesTableFilterComposer,
    $$ReferencePosesTableOrderingComposer,
    $$ReferencePosesTableAnnotationComposer,
    $$ReferencePosesTableCreateCompanionBuilder,
    $$ReferencePosesTableUpdateCompanionBuilder,
    (
      ReferencePose,
      BaseReferences<_$AppDatabase, $ReferencePosesTable, ReferencePose>
    ),
    ReferencePose,
    PrefetchHooks Function()>;
typedef $$WorkSessionsTableCreateCompanionBuilder = WorkSessionsCompanion
    Function({
  required String id,
  required DateTime startTime,
  Value<DateTime?> endTime,
  required int mode,
  Value<double?> scoreAverage,
  Value<int> rowid,
});
typedef $$WorkSessionsTableUpdateCompanionBuilder = WorkSessionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int> mode,
  Value<double?> scoreAverage,
  Value<int> rowid,
});

class $$WorkSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scoreAverage => $composableBuilder(
      column: $table.scoreAverage, builder: (column) => ColumnFilters(column));
}

class $$WorkSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scoreAverage => $composableBuilder(
      column: $table.scoreAverage,
      builder: (column) => ColumnOrderings(column));
}

class $$WorkSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get scoreAverage => $composableBuilder(
      column: $table.scoreAverage, builder: (column) => column);
}

class $$WorkSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkSessionsTable,
    WorkSession,
    $$WorkSessionsTableFilterComposer,
    $$WorkSessionsTableOrderingComposer,
    $$WorkSessionsTableAnnotationComposer,
    $$WorkSessionsTableCreateCompanionBuilder,
    $$WorkSessionsTableUpdateCompanionBuilder,
    (
      WorkSession,
      BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSession>
    ),
    WorkSession,
    PrefetchHooks Function()> {
  $$WorkSessionsTableTableManager(_$AppDatabase db, $WorkSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> mode = const Value.absent(),
            Value<double?> scoreAverage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkSessionsCompanion(
            id: id,
            startTime: startTime,
            endTime: endTime,
            mode: mode,
            scoreAverage: scoreAverage,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            required int mode,
            Value<double?> scoreAverage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkSessionsCompanion.insert(
            id: id,
            startTime: startTime,
            endTime: endTime,
            mode: mode,
            scoreAverage: scoreAverage,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkSessionsTable,
    WorkSession,
    $$WorkSessionsTableFilterComposer,
    $$WorkSessionsTableOrderingComposer,
    $$WorkSessionsTableAnnotationComposer,
    $$WorkSessionsTableCreateCompanionBuilder,
    $$WorkSessionsTableUpdateCompanionBuilder,
    (
      WorkSession,
      BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSession>
    ),
    WorkSession,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String userId,
  Value<int> workDuration,
  Value<int> breakDuration,
  Value<bool> autoStart,
  Value<int> repetitions,
  Value<String> taskSortStrategy,
  Value<String> monitoringIntensity,
  Value<bool> showCalibrationInstructions,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> userId,
  Value<int> workDuration,
  Value<int> breakDuration,
  Value<bool> autoStart,
  Value<int> repetitions,
  Value<String> taskSortStrategy,
  Value<String> monitoringIntensity,
  Value<bool> showCalibrationInstructions,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workDuration => $composableBuilder(
      column: $table.workDuration, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get breakDuration => $composableBuilder(
      column: $table.breakDuration, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoStart => $composableBuilder(
      column: $table.autoStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskSortStrategy => $composableBuilder(
      column: $table.taskSortStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monitoringIntensity => $composableBuilder(
      column: $table.monitoringIntensity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showCalibrationInstructions => $composableBuilder(
      column: $table.showCalibrationInstructions,
      builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workDuration => $composableBuilder(
      column: $table.workDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get breakDuration => $composableBuilder(
      column: $table.breakDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoStart => $composableBuilder(
      column: $table.autoStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskSortStrategy => $composableBuilder(
      column: $table.taskSortStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monitoringIntensity => $composableBuilder(
      column: $table.monitoringIntensity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showCalibrationInstructions => $composableBuilder(
      column: $table.showCalibrationInstructions,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get workDuration => $composableBuilder(
      column: $table.workDuration, builder: (column) => column);

  GeneratedColumn<int> get breakDuration => $composableBuilder(
      column: $table.breakDuration, builder: (column) => column);

  GeneratedColumn<bool> get autoStart =>
      $composableBuilder(column: $table.autoStart, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<String> get taskSortStrategy => $composableBuilder(
      column: $table.taskSortStrategy, builder: (column) => column);

  GeneratedColumn<String> get monitoringIntensity => $composableBuilder(
      column: $table.monitoringIntensity, builder: (column) => column);

  GeneratedColumn<bool> get showCalibrationInstructions => $composableBuilder(
      column: $table.showCalibrationInstructions, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int> workDuration = const Value.absent(),
            Value<int> breakDuration = const Value.absent(),
            Value<bool> autoStart = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<String> taskSortStrategy = const Value.absent(),
            Value<String> monitoringIntensity = const Value.absent(),
            Value<bool> showCalibrationInstructions = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            userId: userId,
            workDuration: workDuration,
            breakDuration: breakDuration,
            autoStart: autoStart,
            repetitions: repetitions,
            taskSortStrategy: taskSortStrategy,
            monitoringIntensity: monitoringIntensity,
            showCalibrationInstructions: showCalibrationInstructions,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<int> workDuration = const Value.absent(),
            Value<int> breakDuration = const Value.absent(),
            Value<bool> autoStart = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<String> taskSortStrategy = const Value.absent(),
            Value<String> monitoringIntensity = const Value.absent(),
            Value<bool> showCalibrationInstructions = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            userId: userId,
            workDuration: workDuration,
            breakDuration: breakDuration,
            autoStart: autoStart,
            repetitions: repetitions,
            taskSortStrategy: taskSortStrategy,
            monitoringIntensity: monitoringIntensity,
            showCalibrationInstructions: showCalibrationInstructions,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  required String description,
  required int priority,
  required DateTime date,
  required int status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> priority,
  Value<DateTime> date,
  Value<int> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            priority: priority,
            date: date,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required int priority,
            required DateTime date,
            required int status,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            priority: priority,
            date: date,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ReferencePosesTableTableManager get referencePoses =>
      $$ReferencePosesTableTableManager(_db, _db.referencePoses);
  $$WorkSessionsTableTableManager get workSessions =>
      $$WorkSessionsTableTableManager(_db, _db.workSessions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
