import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/core/utils/date_picker_utils.dart';
import 'package:ergo_desktop/core/widgets/app_date_picker_field.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_button.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_label.dart';

import 'package:ergo_desktop/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:ergo_desktop/core/models/location_model.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_avatar_picker.dart';
import '../widgets/settings_gender_dropdown.dart';
import '../widgets/settings_form_field.dart';
import '../widgets/settings_dropdown_field.dart';

import 'package:ergo_desktop/features/profile/data/services/profile_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/services/work_session_service.dart';
import 'package:ergo_desktop/features/pomodoro/data/models/work_session_model.dart';
import 'package:ergo_desktop/features/tasks/data/services/task_service.dart';
import 'package:ergo_desktop/core/database/app_database.dart';

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
  final _workDurationController = TextEditingController();
  final _breakDurationController = TextEditingController();
  final _cyclesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  XFile? _imageFile;
  String? _selectedGender;
  String? _selectedLocation;
  String? _selectedOccupation;
  Uint8List? _dbPhotoBytes;
  String _selectedSort = "Prioridad";
  bool _photoDeleted = false;

  List<LocationModel> _allLocations = [];
  List<String> _professions = [];

  // Initial values for change detection
  String _initialName = '';
  String? _initialGender;
  String? _initialLocation;
  String? _initialOccupation;
  String _initialBirthDate = '';
  String _initialSort = "Prioridad";
  String _initialWork = '';
  String _initialBreak = '';
  String _initialCycles = '';

  @override
  void initState() {
    super.initState();
    final profile = profileService.profile;
    final settings = sessionService.settings;

    if (profile != null && settings != null) {
      _isLoading = false;
      _setInitialData(profile, settings);
    }
    _loadData();
  }

  void _setInitialData(User profile, PomodoroSettings settings) {
    _initialName = profile.fullName;
    _initialGender = profile.gender;
    _initialLocation = profile.location;
    _initialOccupation = profile.occupation;
    _initialBirthDate = DatePickerUtils.formatDate(profile.birthDate);
    _dbPhotoBytes = profile.photo;

    _nameController.text = _initialName;
    _selectedGender = _initialGender;
    _selectedLocation = _initialLocation;
    _selectedOccupation = _initialOccupation;
    _birthDateController.text = _initialBirthDate;

    // We assume default sort is "Prioridad" or we could fetch it from TaskService if it was persistent
    _initialSort = "Prioridad";
    _selectedSort = _initialSort;

    _initialWork = settings.workDuration.toString();
    _initialBreak = settings.breakDuration.toString();
    _initialCycles = settings.repetitions.toString();
    _initialSort = settings.taskSortStrategy;

    _workDurationController.text = _initialWork;
    _breakDurationController.text = _initialBreak;
    _cyclesController.text = _initialCycles;
    _selectedSort = _initialSort;
    _photoDeleted = false;
  }

  bool _hasChanges() {
    return _nameController.text != _initialName ||
        _selectedGender != _initialGender ||
        _selectedLocation != _initialLocation ||
        _selectedOccupation != _initialOccupation ||
        _birthDateController.text != _initialBirthDate ||
        _selectedSort != _initialSort ||
        _workDurationController.text != _initialWork ||
        _breakDurationController.text != _initialBreak ||
        _cyclesController.text != _initialCycles ||
        _imageFile != null ||
        _photoDeleted;
  }

  void _onDeletePhoto() {
    setState(() {
      _imageFile = null;
      _dbPhotoBytes = null;
      _photoDeleted = true;
    });
  }

  Future<void> _loadData() async {
    try {
      final String locationsJson =
          await rootBundle.loadString('assets/data/colombia_municipios.json');
      final List<dynamic> departments = json.decode(locationsJson);
      List<LocationModel> flattenedLocations = [];
      for (var dept in departments) {
        final String deptName = dept['departamento'];
        final List<dynamic> cities = dept['ciudades'];
        for (var city in cities) {
          flattenedLocations
              .add(LocationModel(municipio: city, departamento: deptName));
        }
      }

      final String professionsJson =
          await rootBundle.loadString('assets/data/professions.json');
      final List<String> loadedProfessions =
          List<String>.from(json.decode(professionsJson));

      final profile = await profileService.getProfile();
      final settings = await sessionService.getSettings() ?? PomodoroSettings();

      if (profile != null) {
        _setInitialData(profile, settings);
      }

      setState(() {
        _allLocations = flattenedLocations;
        _professions = loadedProfessions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading settings data: $e");
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLocationAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileLabel("Ubicación"),
        const SizedBox(height: 8),
        Autocomplete<LocationModel>(
          displayStringForOption: (option) => option.fullName,
          initialValue: TextEditingValue(text: _selectedLocation ?? ""),
          optionsBuilder: (textValue) {
            if (textValue.text.isEmpty) return const Iterable.empty();
            return _allLocations
                .where((loc) => loc.fullName
                    .toLowerCase()
                    .contains(textValue.text.toLowerCase()))
                .take(6);
          },
          onSelected: (selection) =>
              setState(() => _selectedLocation = selection.fullName),
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: SizedBox(
                  width: 400,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final LocationModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(option.fullName),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return ProfileTextField(
              hint: "Escribe tu ciudad...",
              controller: controller,
              focusNode: focusNode,
              onTap: () {
                if (controller.text == _initialLocation) {
                  controller.selection = TextSelection(
                      baseOffset: 0, extentOffset: controller.text.length);
                }
              },
              onChanged: (v) {
                setState(() => _selectedLocation = v);
              },
              validator: (v) {
                if (v == null || v.isEmpty) return "Selecciona una ubicación";
                final exists = _allLocations.any((loc) => loc.fullName == v);
                return exists ? null : "Selecciona una ubicación válida";
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      Uint8List? photoBytes;
      if (_imageFile != null) {
        photoBytes = await _imageFile!.readAsBytes();
      } else {
        photoBytes = _dbPhotoBytes;
      }

      await profileService.updateProfile(
        fullName: _nameController.text,
        birthDate: _birthDateController.text,
        gender: _selectedGender ?? "",
        location: _selectedLocation ?? "",
        occupation: _selectedOccupation ?? "",
        photoBytes: photoBytes,
      );

      final newSettings = PomodoroSettings(
        userId: 'me',
        workDuration: int.tryParse(_workDurationController.text) ?? 25,
        breakDuration: int.tryParse(_breakDurationController.text) ?? 5,
        repetitions: int.tryParse(_cyclesController.text) ?? 1,
        autoStart: sessionService.settings?.autoStart ?? false,
        taskSortStrategy: _selectedSort,
      );

      await sessionService.updateSettings(newSettings);

      // Apply sort strategy to TaskService for immediate effect
      GetIt.instance<TaskService>().setSortStrategy(_selectedSort);

      final updatedProfile = await profileService.getProfile();
      if (updatedProfile != null) {
        _setInitialData(updatedProfile, newSettings);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Configuración guardada exitosamente")),
        );
      }
    } catch (e) {
      debugPrint("Error saving settings: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showClearTasksDialog() async {
    final taskService = GetIt.instance<TaskService>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text("Borrar tareas completadas",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
              const SizedBox(height: 10),
              Text(
                  "¿Estás seguro de que quieres eliminar todas las tareas completadas? Esta acción no se puede deshacer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
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
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text("Borrar",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await taskService.clearCompletedTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tareas completadas eliminadas")),
        );
      }
    }
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text("Descartar cambios",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
              const SizedBox(height: 10),
              Text(
                  "Tienes cambios sin guardar. ¿Seguro que quieres salir y perder las modificaciones?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
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
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text("Descartar",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          final shouldPop = !_hasChanges() || await _showDiscardDialog();
          if (shouldPop && context.mounted) {
            if (mounted) Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Configuración",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain),
                    ),
                    const SizedBox(height: 40),
                    const SettingsSectionTitle(title: "Perfil de Usuario"),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsAvatarPicker(
                          imageFile: _imageFile,
                          dbPhotoBytes: _dbPhotoBytes,
                          onImageSelected: (file) =>
                              setState(() => _imageFile = file),
                          onDeletePhoto: _onDeletePhoto,
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          child: Column(
                            children: [
                              SettingsFormField(
                                  label: "Nombre Completo",
                                  hint: "Nombre",
                                  controller: _nameController),
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ProfileLabel("Género"),
                                        const SizedBox(height: 8),
                                        SettingsGenderDropdown(
                                          value: _selectedGender,
                                          onChanged: (v) => setState(
                                              () => _selectedGender = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ProfileLabel("F. De Nacimiento"),
                                        const SizedBox(height: 8),
                                        AppDatePickerField(
                                          controller: _birthDateController,
                                          helpText: 'FECHA DE NACIMIENTO',
                                          initialDate:
                                              DatePickerUtils.parseDate(
                                                      _birthDateController
                                                          .text) ??
                                                  DateTime(2000),
                                          firstDate: DateTime(1940),
                                          lastDate: DateTime.now(),
                                        ),
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
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLocationAutocomplete()),
                        const SizedBox(width: 20),
                        Expanded(
                            child: SettingsDropdownField(
                                label: "Profesión",
                                value: _selectedOccupation,
                                items: _professions,
                                onChanged: (v) =>
                                    setState(() => _selectedOccupation = v))),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const SettingsSectionTitle(title: "Gestión de Tareas"),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SettingsDropdownField(
                            label: "Ordenamiento Predeterminado",
                            value: _selectedSort,
                            items: const ["Prioridad", "Fecha", "Nombre (A-Z)"],
                            onChanged: (v) =>
                                setState(() => _selectedSort = v!),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ProfileLabel("Mantenimiento"),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _showClearTasksDialog,
                                  icon: const Icon(Icons.delete_sweep_outlined,
                                      color: AppColors.textMain),
                                  label: const Text("Borrar tareas completadas",
                                      style:
                                          TextStyle(color: AppColors.textMain)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const SettingsSectionTitle(
                        title: "Preferencias de Pomodoro"),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 650,
                      child: Row(
                        children: [
                          Expanded(
                              child: SettingsFormField(
                                  label: "Trabajo (min)",
                                  hint: "25",
                                  controller: _workDurationController,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 20),
                          Expanded(
                              child: SettingsFormField(
                                  label: "Descanso (min)",
                                  hint: "5",
                                  controller: _breakDurationController,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 20),
                          Expanded(
                              child: SettingsFormField(
                                  label: "Ciclos",
                                  hint: "4",
                                  controller: _cyclesController,
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 220,
                        height: 45,
                        child: ProfileButton(
                            text: "Guardar Cambios",
                            isLoading: _isSaving,
                            onPressed: _saveAll),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
