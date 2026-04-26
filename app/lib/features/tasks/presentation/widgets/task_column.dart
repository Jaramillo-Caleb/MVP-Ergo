import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/task_model.dart';
import '../../data/services/task_service.dart';
import 'task_card.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final TaskService service;

  const TaskColumn({
    super.key,
    required this.title,
    required this.status,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = service.tasks.where((t) => t.status == status).toList();

    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          service.moveTask(details.data, status);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Colors.blue.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: candidateData.isNotEmpty
                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        "$title (${tasks.length})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: tasks[index], service: service);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
