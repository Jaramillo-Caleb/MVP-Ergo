import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_label.dart';
import '../widgets/terms_checkbox.dart';
import '../../data/services/auth_service.dart';
import 'login_page.dart';
import 'complete_profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final authService = GetIt.instance<AuthService>();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() {
      _showTermsError = !_acceptedTerms;
    });

    if (_formKey.currentState!.validate() && _acceptedTerms) {
      setState(() => _isLoading = true);

      final result = await authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Protección contra async gaps
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al registrar: intenta con otro correo."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Crear cuenta",
      subtitle: "Comienza a mejorar tu postura y productividad hoy.",
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthLabel("Email *"),
            AuthTextField(
              hint: "correo@ejemplo.com",
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'El correo es obligatorio';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Fila de Contraseñas (Lado a lado como en tu diseño original)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthLabel("Contraseña *"),
                      AuthTextField(
                        hint: "••••••••",
                        isPassword: true,
                        obscureText: _obscurePass,
                        controller: _passwordController,
                        togglePassword: () => setState(() => _obscurePass = !_obscurePass),
                        validator: (v) => (v == null || v.length < 6) ? "Mín. 6 carac." : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthLabel("Confirmar *"),
                      AuthTextField(
                        hint: "••••••••",
                        isPassword: true,
                        obscureText: _obscureConfirm,
                        controller: _confirmPasswordController,
                        togglePassword: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => (v != _passwordController.text) ? "No coinciden" : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TermsCheckbox(
              accepted: _acceptedTerms,
              showError: _showTermsError,
              onChanged: (v) {
                setState(() {
                  _acceptedTerms = v ?? false;
                  if (_acceptedTerms) _showTermsError = false;
                });
              },
            ),
            if (_showTermsError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Debes aceptar los términos", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            
            const SizedBox(height: 30),
            AuthButton(
              text: "Crear Cuenta",
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ),
            
            const SizedBox(height: 30),
            _buildDivider(),
            const SizedBox(height: 30),
            
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? ", style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                    child: const Text("Iniciar sesión", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("O REGÍSTRATE CON", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}