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
  TextColumn get fullName => text().named('full_name')();
  DateTimeColumn get birthDate => dateTime().named('birth_date')();
  TextColumn get gender => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get occupation => text().nullable()();
  BlobColumn get photo => blob().nullable()();
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
  TextColumn get taskSortStrategy => text()
      .named('task_sort_strategy')
      .withDefault(const Constant("Prioridad"))();
  TextColumn get monitoringIntensity => text()
      .named('monitoring_intensity')
      .withDefault(const Constant("Medio"))();
  BoolColumn get showCalibrationInstructions => boolean()
      .named('show_calibration_instructions')
      .withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {userId};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get priority => integer()(); // 0: low, 1: medium, 2: high
  DateTimeColumn get date => dateTime()();
  IntColumn get status =>
      integer()(); // 0: pending, 1: inProgress, 2: completed
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, ReferencePoses, WorkSessions, Settings, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 4) {
            await m.createTable(tasks);
          }
          if (from < 5) {
            await m.addColumn(users, users.photo);
          }
          if (from < 7) {
            await m.addColumn(settings, settings.taskSortStrategy);
          }
          if (from < 8) {
            // Utilizar los GeneratedColumn generados en _$AppDatabase
            await m.addColumn(settings, settings.monitoringIntensity);
            await m.addColumn(settings, settings.showCalibrationInstructions);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'ergo.db'));

    if (Platform.isWindows) {
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
    }

    final cipherToken = await WinVault.getOrCreateDatabaseKey();

    return NativeDatabase.createInBackground(file, setup: (db) {
      db.execute("PRAGMA key = '$cipherToken';");
      final result = db.select('PRAGMA cipher_version;');
      db.execute("PRAGMA cipher_compatibility = 4;");
      if (result.isEmpty) {
        throw Exception('SQLCipher not available');
      }
    });
  });
}
