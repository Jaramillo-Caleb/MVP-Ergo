import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import '../native/win_vault.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text().named('full_name')();
  DateTimeColumn get birthDate => dateTime().named('birth_date')();
  TextColumn get gender => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get avatarPath => text().nullable().named('avatar_path')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class ReferencePoses extends Table {
  TextColumn get id => text()();
  TextColumn get alias => text()();
  TextColumn get vector => text()(); // JSON encoded
  BoolColumn get isPersistent => boolean().named('is_persistent')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startTime => dateTime().named('start_time')();
  DateTimeColumn get endTime => dateTime().nullable().named('end_time')();
  IntColumn get mode => integer()();
  RealColumn get scoreAverage => real().nullable().named('score_average')();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get userId => text().named('user_id')();
  IntColumn get workDuration =>
      integer().named('work_duration').withDefault(const Constant(25))();
  IntColumn get breakDuration =>
      integer().named('break_duration').withDefault(const Constant(5))();
  BoolColumn get autoStart =>
      boolean().named('auto_start').withDefault(const Constant(false))();
  IntColumn get repetitions => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {userId};
}

@DriftDatabase(tables: [Users, ReferencePoses, WorkSessions, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Incremented for migration from sqflite

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Basic migration for now, can be expanded if needed
          if (from < 3) {
            // We are migrating from sqflite to Drift.
            // Drift will create the tables if they don't exist.
            // If they already exist (because they were created by sqflite),
            // Drift might complain if schema doesn't match exactly.
            // But since we are changing the entire persistence layer,
            // we might just let it create or handle it.
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'ergo_db.db'));

    if (Platform.isWindows) {
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
    }

    final cipherToken = await WinVault.getOrCreateDatabaseKey();

    return NativeDatabase.createInBackground(file, setup: (db) {
      db.execute("PRAGMA key = '$cipherToken ';");
      // Verify encryption works
      final result = db.select('PRAGMA cipher_version;');
      if (result.isEmpty) {
        throw Exception('SQLCipher not available');
      }
    });
  });
}
