import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_button.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_label.dart';
import 'package:ergo_desktop/features/auth/data/services/account_service.dart';

class LocationModel {
  final String municipio;
  final String departamento;
  LocationModel({required this.municipio, required this.departamento});
  String get fullName => "$municipio, $departamento";
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final accountService = GetIt.instance<AccountService>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherProfessionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  List<String> _professions = [];
  List<LocationModel> _allLocations = [];

  String? _selectedGender;
  String? _selectedProfession;
  bool _showOtherProfession = false;
  DateTime? _rawBirthDate;
  String? _currentAvatarPath; // To store the current avatar path if any

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadStaticData(); // Load professions and locations
  }

  Future<void> _loadStaticData() async {
    try {
      final String profRes =
          await rootBundle.loadString('assets/data/professions.json');
      final String locRes =
          await rootBundle.loadString('assets/data/colombia_municipios.json');

      final List<dynamic> profData = json.decode(profRes);
      final List<dynamic> locData = json.decode(locRes);

      List<LocationModel> flattened = [];
      for (var deptoMap in locData) {
        for (var ciudad in deptoMap['ciudades']) {
          flattened.add(LocationModel(
              municipio: ciudad, departamento: deptoMap['departamento']));
        }
      }

      setState(() {
        _professions = List<String>.from(profData);
        _allLocations = flattened;
      });
    } catch (e) {
      debugPrint("Error cargando datos estáticos: $e");
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profileData = await accountService.getProfile();
      if (profileData != null) {
        _nameController.text = profileData['FullName'] ?? '';
        _birthDateController.text = profileData['BirthDate'] != null
            ? DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(profileData['BirthDate']))
            : '';
        _rawBirthDate = profileData['BirthDate'] != null
            ? DateTime.parse(profileData['BirthDate'])
            : null;
        _selectedGender = profileData['Gender'];
        _locationController.text = profileData['Location'] ?? '';
        _selectedProfession = profileData['Occupation'];
        _showOtherProfession = _selectedProfession == "Otro";
        if (_showOtherProfession) {
          _otherProfessionController.text = profileData['Occupation'] ?? '';
        }
        _currentAvatarPath = profileData['AvatarPath'];
      }
    } catch (e) {
      debugPrint("Error cargando datos del perfil: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rawBirthDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'FECHA DE NACIMIENTO',
    );
    if (picked != null) {
      setState(() {
        _rawBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      String occupation = _showOtherProfession
          ? _otherProfessionController.text
          : (_selectedProfession ?? "");

      final String birthDateIso = _rawBirthDate?.toIso8601String() ?? "";
      final String gender = _selectedGender ?? "";

      final success = await accountService.updateProfile(
        fullName: _nameController.text.trim(),
        birthDate: birthDateIso,
        gender: gender,
        location: _locationController.text.trim(),
        occupation: occupation,
        imagePath: null,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado correctamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar perfil")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: AppColors.sidebarBackground,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarDisplay(),
                    const SizedBox(height: 30),
                    const AuthLabel("Nombre Completo"),
                    AuthTextField(
                        hint: "Ej. Juanito Perez",
                        controller: _nameController,
                        validator: (v) =>
                            v!.isEmpty ? "Ingresa tu nombre" : null),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthLabel("Género"),
                              _buildGenderDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthLabel("F. De Nacimiento"),
                              AuthTextField(
                                hint: "dd/mm/aaaa",
                                controller: _birthDateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (v) =>
                                    v!.isEmpty ? "Requerido" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const AuthLabel("Ubicación (Ciudad, Departamento)"),
                    _buildLocationAutocomplete(),
                    const SizedBox(height: 20),
                    const AuthLabel("Profesión"),
                    _buildProfessionDropdown(),
                    if (_showOtherProfession) ...[
                      const SizedBox(height: 10),
                      AuthTextField(
                          hint: "Especifica tu cargo",
                          controller: _otherProfessionController,
                          validator: (v) => _showOtherProfession && v!.isEmpty
                              ? "Especifica tu cargo"
                              : null),
                    ],
                    const SizedBox(height: 40),
                    AuthButton(
                        text: "Guardar Cambios",
                        isLoading: _isSaving,
                        onPressed: _handleSave),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarDisplay() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300], // Placeholder background
            backgroundImage:
                _currentAvatarPath != null && _currentAvatarPath!.isNotEmpty
                    ? FileImage(File(_currentAvatarPath!))
                    : null,
            child: _currentAvatarPath == null || _currentAvatarPath!.isEmpty
                ? const Icon(Icons.person_outline, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 10),
          const Text("Foto de perfil",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLocationAutocomplete() {
    return Autocomplete<LocationModel>(
      displayStringForOption: (option) => option.fullName,
      optionsBuilder: (textValue) {
        if (textValue.text.length < 2) return const Iterable.empty();
        return _allLocations
            .where((loc) => loc.municipio
                .toLowerCase()
                .contains(textValue.text.toLowerCase()))
            .take(6);
      },
      onSelected: (selection) => _locationController.text = selection.fullName,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AuthTextField(
          hint: "Escribe tu ciudad...",
          controller: controller,
          focusNode: focusNode,
          validator: (v) {
            if (v == null || v.isEmpty) return "La ubicación es requerida";
            final exists = _allLocations
                .any((loc) => loc.fullName.toLowerCase() == v.toLowerCase());
            return exists
                ? null
                : "Selecciona una ubicación válida de la lista";
          },
        );
      },
    );
  }

  Widget _buildProfessionDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProfession,
      validator: (v) => v == null || v.isEmpty ? "Selecciona una opción" : null,
      items: (_professions)
          .map((p) => DropdownMenuItem(
              value: p, child: Text(p, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => setState(() {
        _selectedProfession = v;
        _showOtherProfession = v == "Otro";
        if (!_showOtherProfession) {
          _otherProfessionController.clear();
        }
      }),
      decoration: _dropdownDecoration(),
      isExpanded: true,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender, // Use value instead of initialValue
      validator: (v) => v == null || v.isEmpty ? "Selecciona una opción" : null,
      items: ["Masculino", "Femenino", "Prefiero no decir"]
          .map((v) => DropdownMenuItem(
              value: v, child: Text(v, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      decoration: _dropdownDecoration(),
      isExpanded: true,
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _locationController.dispose();
    _otherProfessionController.dispose();
    super.dispose();
  }
}
