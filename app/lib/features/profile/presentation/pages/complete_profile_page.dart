import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_layout.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_button.dart';
import 'package:ergo_desktop/features/profile/presentation/widgets/profile_label.dart';
import 'package:ergo_desktop/features/profile/data/services/profile_service.dart';
import 'package:ergo_desktop/features/home/presentation/pages/home_page.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (oldValue.text.length >= 10 && newValue.text.length > oldValue.text.length) {
      final base = oldValue.selection.baseOffset;
      final extent = newValue.selection.extentOffset;
      if (extent > base && base >= 0) {
        final inserted = newValue.text.substring(base, extent);
        final newDigits = inserted.replaceAll(RegExp(r'[^0-9]'), '');
        if (newDigits.isNotEmpty) {
          text = newDigits;
        }
      }
    }

    if (text.length > 8) text = text.substring(0, 8);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();

    return TextEditingValue(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

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
  final profileService = GetIt.instance<ProfileService>();

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  String? _parseDateToIso(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date.toIso8601String();
    } catch (_) {
      return null;
    }
  }

  void _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      final isoDate = _parseDateToIso(_birthDateController.text);
      if (isoDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fecha inválida")),
        );
        return;
      }

      setState(() => _isSaving = true);

      String occupation = _showOtherProfession
          ? _otherProfessionController.text
          : (_selectedProfession ?? "");

      final success = await profileService.updateProfile(
        fullName: _nameController.text.trim(),
        birthDate: isoDate,
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
    return ProfileLayout(
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
                  const SizedBox(height: 16),
                  const ProfileLabel("Nombre Completo"),
                  ProfileTextField(
                      hint: "Ej. Juanito Perez",
                      controller: _nameController,
                      validator: (v) =>
                          v!.isEmpty ? "Ingresa tu nombre" : null),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ProfileLabel("F. De Nacimiento"),
                            TextFormField(
                              controller: _birthDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                DateInputFormatter(),
                              ],
                              decoration: _inputDecorationWithIcon(
                                  "DD/MM/YYYY",
                                  Icons.calendar_today,
                                  () => _selectDate(context)),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Requerido";
                                if (_parseDateToIso(v) == null) {
                                  return "Fecha inválida";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ProfileLabel("Ubicación (Ciudad, Departamento)"),
                  _buildLocationAutocomplete(),
                  const SizedBox(height: 12),
                  const ProfileLabel("Profesión"),
                  _buildProfessionDropdown(),
                  if (_showOtherProfession) ...[
                    const SizedBox(height: 10),
                    ProfileTextField(
                        hint: "Especifica tu cargo",
                        controller: _otherProfessionController,
                        validator: (v) => _showOtherProfession && v!.isEmpty
                            ? "Especifica tu cargo"
                            : null),
                  ],
                  const SizedBox(height: 24),
                  ProfileButton(
                      text: "Continuar",
                      isLoading: _isSaving,
                      onPressed: _handleContinue),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecorationWithIcon(
      String hint, IconData icon, VoidCallback onTap) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      suffixIcon: IconButton(
        icon: Icon(icon, size: 18, color: AppColors.textSecondary),
        onPressed: onTap,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
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
                radius: 35,
                backgroundColor: AppColors.backgroundLight,
                backgroundImage: _imageFile != null
                    ? FileImage(File(_imageFile!.path))
                    : null,
                child: _imageFile == null
                    ? const Icon(Icons.person_outline,
                        size: 35, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => _imageFile = img);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text("Añade una foto",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            child: SizedBox(
              width: 450, // Match ConstrainedBox in ProfileLayout
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final LocationModel option = options.elementAt(index);
                  return InkWell(
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
          validator: (v) {
            final exists = _allLocations.any((loc) => loc.fullName == v);
            return exists ? null : "Selecciona una ubicación válida";
          },
        );
      },
    );
  }

  Widget _buildProfessionDropdown() {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: _selectedProfession,
        enableFilter: true,
        requestFocusOnTap: true,
        dropdownMenuEntries: _professions
            .map((p) => DropdownMenuEntry(value: p, label: p))
            .toList(),
        inputDecorationTheme: _dropdownDecorationTheme(),
        onSelected: (v) => setState(() {
          _selectedProfession = v;
          _showOtherProfession = v == "Otro";
        }),
      );
    });
  }

  Widget _buildGenderDropdown() {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: _selectedGender,
        dropdownMenuEntries: ["Masculino", "Femenino", "Prefiero no decir"]
            .map((v) => DropdownMenuEntry(value: v, label: v))
            .toList(),
        inputDecorationTheme: _dropdownDecorationTheme(),
        onSelected: (v) => setState(() => _selectedGender = v),
      );
    });
  }

  InputDecorationTheme _dropdownDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
