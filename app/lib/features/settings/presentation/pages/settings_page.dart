import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_button.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_label.dart';
import 'package:ergo_desktop/features/profile/data/services/profile_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/models/work_session_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final profileService = GetIt.instance<ProfileService>();
  final sessionService = GetIt.instance<WorkSessionService>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();

  final _workDurationController = TextEditingController();
  final _breakDurationController = TextEditingController();
  final _cyclesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  XFile? _imageFile;
  String? _selectedGender;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await profileService.getProfile();
    final settings = await sessionService.getSettings() ?? PomodoroSettings();

    if (profile != null) {
      _nameController.text = profile.fullName;
      _locationController.text = profile.location ?? '';
      _occupationController.text = profile.occupation ?? '';
      _selectedGender = profile.gender;
      _avatarPath = profile.avatarPath;

      final date = profile.birthDate;
      _birthDateController.text =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    _workDurationController.text = settings.workDuration.toString();
    _breakDurationController.text = settings.breakDuration.toString();
    _cyclesController.text = settings.repetitions.toString();

    setState(() => _isLoading = false);
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);

    // Save Profile
    await profileService.updateProfile(
      fullName: _nameController.text,
      birthDate:
          _birthDateController.text, // Simplificado, debería enviarse ISO
      gender: _selectedGender ?? '',
      location: _locationController.text,
      occupation: _occupationController.text,
      imagePath: _imageFile?.path,
    );

    // Save Pomodoro Settings
    final currentSettings = sessionService.settings ?? PomodoroSettings();
    await sessionService.updateSettings(
      currentSettings.copyWith(
        workDuration: int.tryParse(_workDurationController.text) ?? 25,
        breakDuration: int.tryParse(_breakDurationController.text) ?? 5,
        repetitions: int.tryParse(_cyclesController.text) ?? 4,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuración guardada correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Configuración",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Perfil de Usuario"),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    children: [
                      const ProfileLabel("Nombre Completo"),
                      ProfileTextField(
                          hint: "Nombre", controller: _nameController),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProfileLabel("Género"),
                                _buildGenderDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProfileLabel("F. De Nacimiento"),
                                ProfileTextField(
                                    hint: "dd/mm/aaaa",
                                    controller: _birthDateController,
                                    readOnly: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const ProfileLabel("Ubicación (Ciudad, Departamento)"),
            ProfileTextField(
                hint: "Ubicación", controller: _locationController),
            const SizedBox(height: 20),
            const ProfileLabel("Profesión"),
            ProfileTextField(
                hint: "Profesión", controller: _occupationController),
            const SizedBox(height: 40),
            _buildSectionTitle("Preferencias de Pomodoro"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildNumberInput(
                        "Trabajo (min)", _workDurationController)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildNumberInput(
                        "Descanso (min)", _breakDurationController)),
                const SizedBox(width: 20),
                Expanded(child: _buildNumberInput("Ciclos", _cyclesController)),
              ],
            ),
            const SizedBox(height: 50),
            ProfileButton(
              text: "Guardar Cambios",
              isLoading: _isSaving,
              onPressed: _saveAll,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue)),
        const Divider(height: 30),
      ],
    );
  }

  Widget _buildAvatarSection() {
    ImageProvider? provider;
    if (_imageFile != null) {
      provider = FileImage(File(_imageFile!.path));
    } else if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      provider = NetworkImage("http://localhost:5000$_avatarPath");
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.backgroundLight,
          backgroundImage: provider,
          child: provider == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        TextButton(
          onPressed: () async {
            final img =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (img != null) setState(() => _imageFile = img);
          },
          child: const Text("Cambiar foto"),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      items: ["Masculino", "Femenino", "Prefiero no decir"]
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileLabel(label),
        ProfileTextField(
            hint: "0",
            controller: controller,
            keyboardType: TextInputType.number),
      ],
    );
  }
}
