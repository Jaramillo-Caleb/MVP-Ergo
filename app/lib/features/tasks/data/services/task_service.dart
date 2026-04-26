import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/models/task_model.dart';

class TaskService extends ChangeNotifier {
  final AppDatabase _db;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  TaskService({required AppDatabase db}) : _db = db;

  Future<void> loadTasks() async {
    final rows = await _db.select(_db.tasks).get();
    _tasks = rows.map((row) => TaskModel(
      id: row.id,
      title: row.title,
      description: row.description,
      priority: TaskPriority.values[row.priority],
      date: row.date,
      status: TaskStatus.values[row.status],
      createdAt: row.createdAt,
    )).toList();
    _sortTasks();
    notifyListeners();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      // First by priority (high to low)
      int priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // Then by date
      return a.date.compareTo(b.date);
    });
  }

  Future<void> addTask(TaskModel task) async {
    final entry = TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      priority: Value(task.priority.index),
      date: Value(task.date),
      status: Value(task.status.index),
      createdAt: Value(task.createdAt),
    );
    await _db.into(_db.tasks).insert(entry);
    _tasks.add(task);
    _sortTasks();
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(
        title: Value(task.title),
        description: Value(task.description),
        priority: Value(task.priority.index),
        date: Value(task.date),
        status: Value(task.status.index),
      ),
    );
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _sortTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> moveTask(String id, TaskStatus newStatus) async {
    int index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(status: newStatus);
      await updateTask(updatedTask);
    }
  }

  String generateId() => _uuid.v4();
}
