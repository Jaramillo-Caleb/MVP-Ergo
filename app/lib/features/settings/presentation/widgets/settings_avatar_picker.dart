import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';

class SettingsAvatarPicker extends StatelessWidget {
  final XFile? imageFile;
  final Uint8List? dbPhotoBytes;
  final Function(XFile) onImageSelected;
  final VoidCallback onDeletePhoto;

  const SettingsAvatarPicker({
    super.key,
    this.imageFile,
    this.dbPhotoBytes,
    required this.onImageSelected,
    required this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imageFile != null) {
      provider = FileImage(File(imageFile!.path));
    } else if (dbPhotoBytes != null) {
      provider = MemoryImage(dbPhotoBytes!);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: AppColors.backgroundLight,
          backgroundImage: provider,
          child: provider == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () async {
                final img =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (img != null) onImageSelected(img);
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text("Cambiar foto"),
            ),
            if (provider != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDeletePhoto,
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                tooltip: "Eliminar foto",
              ),
            ],
          ],
        ),
      ],
    );
  }
}
