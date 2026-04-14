import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_layout.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_button.dart';
import 'package:ergo_desktop/features/auth/presentation/widgets/auth_label.dart';
import 'package:ergo_desktop/features/auth/data/services/account_service.dart'; 
import 'package:ergo_desktop/features/home/presentation/pages/home_page.dart';

class LocationModel {
  final String municipio;
  final String departamento;
  LocationModel({required this.municipio, required this.departamento});
  String get fullName => "$municipio, $departamento";
}

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});
  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
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
  XFile? _imageFile;
  DateTime? _rawBirthDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String profRes = await rootBundle.loadString('assets/data/professions.json');
      final String locRes = await rootBundle.loadString('assets/data/colombia_municipios.json');
      
      final List<dynamic> profData = json.decode(profRes);
      final List<dynamic> locData = json.decode(locRes);

      List<LocationModel> flattened = [];
      for (var deptoMap in locData) {
        for (var ciudad in deptoMap['ciudades']) {
          flattened.add(LocationModel(municipio: ciudad, departamento: deptoMap['departamento']));
        }
      }

      setState(() {
        _professions = List<String>.from(profData);
        _allLocations = flattened;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando datos: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'FECHA DE NACIMIENTO',
    );
    if (picked != null) { 
      setState(() {
        _rawBirthDate = picked;
        _birthDateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      String occupation = _showOtherProfession ? _otherProfessionController.text : (_selectedProfession ?? "");
      
      final success = await accountService.updateProfile( 
        fullName: _nameController.text.trim(),
        birthDate: _rawBirthDate?.toIso8601String() ?? "", 
        gender: _selectedGender ?? "",
        location: _locationController.text.trim(),
        occupation: occupation,
        imagePath: _imageFile?.path,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
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
    return AuthLayout(
      title: "Completa tu perfil",
      subtitle: "Personaliza tu experiencia ergonómica.",
      child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarPicker(),
            const SizedBox(height: 30),
            
            const AuthLabel("Nombre Completo"),
            AuthTextField(
              hint: "Ej. Juanito Perez", 
              controller: _nameController,
              validator: (v) => v!.isEmpty ? "Ingresa tu nombre" : null
            ),
            
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
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
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
                validator: (v) => _showOtherProfession && v!.isEmpty ? "Especifica tu cargo" : null
              ),
            ],
            
            const SizedBox(height: 40),
            AuthButton(
              text: "Continuar", 
              isLoading: _isSaving, 
              onPressed: _handleContinue
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.backgroundLight,
                backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                child: _imageFile == null ? const Icon(Icons.person_outline, size: 40, color: Colors.grey) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => _imageFile = img);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text("Añade una foto", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLocationAutocomplete() {
    return Autocomplete<LocationModel>(
      displayStringForOption: (option) => option.fullName,
      optionsBuilder: (textValue) {
        if (textValue.text.length < 2) return const Iterable.empty();
        return _allLocations.where((loc) => 
          loc.municipio.toLowerCase().contains(textValue.text.toLowerCase())
        ).take(6);
      },
      onSelected: (selection) => _locationController.text = selection.fullName,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return AuthTextField(
          hint: "Escribe tu ciudad...",
          controller: controller,
          focusNode: focusNode,
          validator: (v) {
            final exists = _allLocations.any((loc) => loc.fullName == v);
            return exists ? null : "Selecciona una ubicación válida";
          },
        );
      },
    );
  }

  Widget _buildProfessionDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProfession,
      validator: (v) => v == null ? "Selecciona una opción" : null,
      items: _professions.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) => setState(() {
        _selectedProfession = v;
        _showOtherProfession = v == "Otro";
      }),
      decoration: _dropdownDecoration(),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      validator: (v) => v == null ? "Selecciona una opción" : null,
      items: ["Masculino", "Femenino", "Prefiero no decir"].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      decoration: _dropdownDecoration(),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}