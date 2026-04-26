import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/utils/date_picker_utils.dart';
import 'package:ergo_desktop/core/widgets/app_date_picker_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/task_model.dart';
import '../../data/services/task_service.dart';

class TaskDialog extends StatefulWidget {
  final TaskService service;
  final TaskModel? task;

  const TaskDialog({super.key, required this.service, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController dateController;
  late TaskPriority priority;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.task != null;
    titleController = TextEditingController(text: widget.task?.title ?? "");
    descController =
        TextEditingController(text: widget.task?.description ?? "");
    priority = widget.task?.priority ?? TaskPriority.medio;

    if (isEditing) {
      dateController = TextEditingController(
          text: DatePickerUtils.formatDate(widget.task!.date));
    } else {
      dateController = TextEditingController(text: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "Editar Tarea" : "Nueva Tarea",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
            const SizedBox(height: 25),
            const Text("Nombre de la tarea",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              cursorColor: AppColors.textMain,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: standardBorder,
                enabledBorder: standardBorder,
                focusedBorder: standardBorder.copyWith(
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Descripción",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              maxLines: 5,
              minLines: 5,
              cursorColor: AppColors.textMain,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "",
                alignLabelWithHint: true,
                border: standardBorder,
                enabledBorder: standardBorder,
                focusedBorder: standardBorder.copyWith(
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Prioridad",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Theme(
                        data: Theme.of(context).copyWith(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: DropdownButtonFormField<TaskPriority>(
                          initialValue: priority,
                          icon: const SizedBox.shrink(),
                          dropdownColor: Colors.white,
                          focusColor: Colors.transparent,
                          style: const TextStyle(
                              color: AppColors.textMain, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: standardBorder,
                            enabledBorder: standardBorder,
                            focusedBorder: standardBorder,
                          ),
                          items: TaskPriority.values
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.name.toUpperCase(),
                                        style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => priority = val!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Fecha",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      AppDatePickerField(
                        controller: dateController,
                        helpText: 'Fecha de la tarea',
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text("Cancelar",
                        style: TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) return;
                      final date =
                          DatePickerUtils.parseDate(dateController.text) ??
                              DateTime.now();
                      final newTask = TaskModel(
                        id: isEditing
                            ? widget.task!.id
                            : widget.service.generateId(),
                        title: titleController.text,
                        description: descController.text,
                        priority: priority,
                        date: date,
                        status: widget.task?.status ?? TaskStatus.pending,
                        createdAt: widget.task?.createdAt ?? DateTime.now(),
                      );
                      if (isEditing) {
                        widget.service.updateTask(newTask);
                      } else {
                        widget.service.addTask(newTask);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(isEditing ? "Guardar Cambios" : "Crear Tarea",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
