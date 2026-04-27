import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

import '../../data/services/posture_service.dart';
import '../../data/models/posture_models.dart';

final sl = GetIt.instance;

class PostureSelectionDialog extends StatefulWidget {
  final Function({PostureReferenceModel? existingPosture}) onAddNew;

  const PostureSelectionDialog({super.key, required this.onAddNew});

  @override
  State<PostureSelectionDialog> createState() => _PostureSelectionDialogState();
}

class _PostureSelectionDialogState extends State<PostureSelectionDialog> {
  final _postureService = sl<PostureService>();

  List<PostureReferenceModel> _postures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostures();
  }

  Future<void> _loadPostures() async {
    if (mounted) setState(() => _isLoading = true);
    final data = await _postureService.getPostures();
    if (mounted) {
      setState(() {
        _postures = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE0E0E0))),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Seleccionar postura",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else if (_postures.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No hay posturas guardadas",
                    style: TextStyle(color: Colors.grey)),
              )
            else
              Flexible(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _postures
                    .map((posture) => _buildPostureItem(context, posture))
                    .toList(),
              )),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onAddNew(existingPosture: null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "+ Añadir nueva postura",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPostureItem(
      BuildContext context, PostureReferenceModel posture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: InkWell(
        onTap: () => Navigator.pop(context, posture),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.accessibility_new_rounded,
                  size: 18, color: Colors.blueGrey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  posture.alias,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: Colors.grey),
                hoverColor: Colors.blue.withValues(alpha: 0.05),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black87,
                    builder: (context) => EditPostureDialog(
                      posture: posture,
                      onRecalibrate: () =>
                          widget.onAddNew(existingPosture: posture),
                    ),
                  ).then((_) => _loadPostures());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditPostureDialog extends StatefulWidget {
  final PostureReferenceModel posture;
  final VoidCallback onRecalibrate;

  const EditPostureDialog(
      {super.key, required this.posture, required this.onRecalibrate});

  @override
  State<EditPostureDialog> createState() => _EditPostureDialogState();
}

class _EditPostureDialogState extends State<EditPostureDialog> {
  late TextEditingController _textController;
  bool _isDeleting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.posture.alias);
  }

  Future<void> _deletePosture() async {
    setState(() => _isDeleting = true);
    final success = await sl<PostureService>().deletePosture(widget.posture.id);
    if (success && mounted) {
      Navigator.pop(context);
    }
    if (mounted) setState(() => _isDeleting = false);
  }

  Future<void> _saveChanges() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    final success = await sl<PostureService>()
        .updatePosture(widget.posture.id, _textController.text.trim());

    if (success && mounted) {
      Navigator.pop(context);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Opciones de postura",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nombre de la postura",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionItem(
              label: "Recalibrar postura",
              icon: Icons.refresh_rounded,
              color: AppColors.primaryBlue,
              onTap: widget.onRecalibrate,
            ),
            const SizedBox(height: 8),
            _buildActionItem(
              label: _isDeleting ? "Eliminando..." : "Eliminar postura",
              icon: Icons.delete_outline_rounded,
              color: Colors.redAccent,
              onTap: _isDeleting ? () {} : _deletePosture,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sidebarBackground,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isSaving ? "Guardando..." : "Guardar cambios",
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SavePostureDialog extends StatefulWidget {
  final Function(String name) onSave;
  final VoidCallback onTemporary;

  const SavePostureDialog(
      {super.key, required this.onSave, required this.onTemporary});

  @override
  State<SavePostureDialog> createState() => _SavePostureDialogState();
}

class _SavePostureDialogState extends State<SavePostureDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¡Análisis listo!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            const SizedBox(height: 10),
            const Text("Asigna un nombre si deseas guardarla.",
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ej. Oficina Mañana",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onSave(_nameController.text),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text("Guardar postura",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: widget.onTemporary,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text("Usar como temporal",
                    style: TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildActionItem(
    {required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(Icons.chevron_right,
              size: 16, color: color.withValues(alpha: 0.3)),
        ],
      ),
    ),
  );
}

class CalibrationInstructionsDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const CalibrationInstructionsDialog({
    super.key,
    required this.onContinue,
  });

  @override
  State<CalibrationInstructionsDialog> createState() =>
      _CalibrationInstructionsDialogState();
}

class _CalibrationInstructionsDialogState
    extends State<CalibrationInstructionsDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      title: const Text(
        'Preparación para la Calibración',
        style: TextStyle(
          color: Color(0xFF1A1C1E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, siéntese en una posición correcta y cómoda en su silla, mirando de frente al computador...',
              style: TextStyle(color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    onChanged: (val) {
                      setState(() => _dontShowAgain = val ?? false);
                    },
                    activeColor: const Color(0xFF2962FF),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'No volver a preguntar',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2962FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () async {
            if (_dontShowAgain) {
              await sl<PostureService>().setShowCalibrationInstructions(false);
            }
            if (!context.mounted) return;
            Navigator.pop(context);
            widget.onContinue();
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
