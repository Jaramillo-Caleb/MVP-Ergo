import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../../../core/di/injection_container.dart';
import '../widgets/task_column.dart';
import '../widgets/task_button.dart';
import '../widgets/task_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = sl<TaskService>();
    _taskService.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _taskService,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text("Gestión de Tareas",
              style: TextStyle(
                  color: AppColors.textMain, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: TaskButton(
                  text: "Nueva Tarea",
                  onPressed: () => _showTaskDialog(context),
                  width: 170,
                  icon: Icons.add,
                ),
              ),
            ),
          ],
        ),
        body: Consumer<TaskService>(
          builder: (context, service, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskColumn(
                    title: "Pendientes",
                    status: TaskStatus.pending,
                    service: service,
                  ),
                  const SizedBox(width: 20),
                  TaskColumn(
                    title: "En Progreso",
                    status: TaskStatus.inProgress,
                    service: service,
                  ),
                  const SizedBox(width: 20),
                  TaskColumn(
                    title: "Completadas",
                    status: TaskStatus.completed,
                    service: service,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: Duration.zero,
      pageBuilder: (context, anim1, anim2) => TaskDialog(service: _taskService),
    );
  }
}
