import 'package:flutter/material.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

import '../../data/services/posture_service.dart';
import '../../data/models/posture_models.dart';
import '../../../auth/data/services/auth_service.dart';

final sl = GetIt.instance;

class PostureSelectionDialog extends StatefulWidget {
  final VoidCallback onAddNew;

  const PostureSelectionDialog({super.key, required this.onAddNew});

  @override
  State<PostureSelectionDialog> createState() => _PostureSelectionDialogState();
}

class _PostureSelectionDialogState extends State<PostureSelectionDialog> {
  final _postureService = sl<PostureService>();
  final _authService = sl<AuthService>();
  
  List<PostureReferenceModel> _postures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostures();
  }

  Future<void> _loadPostures() async {
    if (mounted) setState(() => _isLoading = true);
    final userId = await _authService.getUserId();
    if (userId != null) {
      final data = await _postureService.getPostures(userId);
      if (mounted) {
        setState(() {
          _postures = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SELECCIONAR POSTURA",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else if (_postures.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No hay posturas guardadas", style: TextStyle(color: Colors.grey)),
              )
            else
              ..._postures.map((posture) => _buildPostureItem(context, posture)),
            
            const Divider(height: 30),
            
            InkWell(
              onTap: widget.onAddNew,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "+ Añadir nueva",
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPostureItem(BuildContext context, PostureReferenceModel posture) {
    return ListTile(
      title: Text(posture.alias, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
        onPressed: () {
          Navigator.pop(context); 
          showDialog(
            context: context,
            builder: (context) => EditPostureDialog(posture: posture),
          ).then((_) => _loadPostures()); 
        },
      ),
      onTap: () {
        Navigator.pop(context, posture);
      }, 
    );
  }
}

class EditPostureDialog extends StatefulWidget {
  final PostureReferenceModel posture;

  const EditPostureDialog({super.key, required this.posture});

  @override
  State<EditPostureDialog> createState() => _EditPostureDialogState();
}

class _EditPostureDialogState extends State<EditPostureDialog> {
  late TextEditingController _textController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.posture.alias);
  }

  Future<void> _deletePosture() async {
    setState(() => _isDeleting = true);
    final userId = await sl<AuthService>().getUserId();
    if (userId != null) {
      final success = await sl<PostureService>().deletePosture(widget.posture.id, userId);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
    if (mounted) setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "OPCIONES DE POSTURA",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 20),

            const Text(
              "CAMBIAR NOMBRE",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 15),

            _ActionButtonFull(
              label: "Recalibrar",
              icon: Icons.refresh,
              bgColor: AppColors.primaryBlue.withValues(alpha: 0.08),
              textColor: AppColors.primaryBlue,
              onTap: () {
              },
            ),

            const SizedBox(height: 10),

            _ActionButtonFull(
              label: _isDeleting ? "Eliminando..." : "Eliminar",
              icon: Icons.delete_outline,
              bgColor: Colors.red.withValues(alpha: 0.08),
              textColor: Colors.red,
              onTap: _isDeleting ? () {} : _deletePosture,
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.backgroundLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sidebarBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Guardar cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
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

  const SavePostureDialog({super.key, required this.onSave, required this.onTemporary});

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
            const Text("¡Análisis listo!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const SizedBox(height: 10),
            const Text("Asigna un nombre si deseas guardarla.", style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ej. Oficina Mañana",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onSave(_nameController.text),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Guardar postura", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: widget.onTemporary,
                style: TextButton.styleFrom(backgroundColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Usar como temporal", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonFull extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButtonFull({required this.label, required this.icon, required this.bgColor, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class CalibrationInstructionsDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const CalibrationInstructionsDialog({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preparación para la Calibración'),
      content: const Text(
        'Por favor, siéntese en una posición correcta y cómoda en su silla, mirando de frente al computador. '
        'Permanecera así durante 5 segundos para calibrar su postura de referencia.',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Continuar'),
          onPressed: () {
            Navigator.of(context).pop();
            onContinue();
          },
        ),
      ],
    );
  }
}