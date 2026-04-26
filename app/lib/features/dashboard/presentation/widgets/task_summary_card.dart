import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/core/models/task_model.dart';
import 'package:ergo_desktop/features/tasks/data/services/task_service.dart';
import 'package:ergo_desktop/core/utils/date_picker_utils.dart';

class TaskSummaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const TaskSummaryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light gray background for encapsulation
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tareas en Progreso",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<TaskService>(
            builder: (context, taskService, child) {
              final inProgressTasks = taskService.tasks
                  .where((t) => t.status == TaskStatus.inProgress)
                  .toList();

              if (inProgressTasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No hay tareas",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: inProgressTasks
                    .map((task) => _TaskItem(task: task, service: taskService))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskModel task;
  final TaskService service;

  const _TaskItem({required this.task, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Fixed width for wrap items
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: task.status == TaskStatus.completed,
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: AppColors.border, width: 1.5),
              onChanged: (val) {
                if (val == true) {
                  service.moveTask(task.id, TaskStatus.completed);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  DatePickerUtils.formatDate(task.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
