import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_label.dart';
import '../../data/services/auth_service.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'complete_profile_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authService = GetIt.instance<AuthService>();
  
  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoggingIn = true);
    final result = await authService.login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoggingIn = false);

    if (result != null) {
      if (!mounted) return;
      Widget nextStep = result.fullName.isEmpty ? const CompleteProfilePage() : const HomePage();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextStep));
    } else {
      _showError("Credenciales incorrectas");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Inicia sesión",
      subtitle: "Bienvenido de nuevo a tu asistente de salud digital.",
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthLabel("Correo *"),
            AuthTextField(
              hint: "correo@ejemplo.com", 
              controller: _emailController,
              validator: (v) => (v == null || v.isEmpty) ? "Ingresa tu correo" : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AuthLabel("Contraseña *"),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                  child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
                )
              ],
            ),
            AuthTextField(
              hint: "••••••••",
              isPassword: true,
              obscureText: _obscurePassword,
              controller: _passwordController,
              togglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) => (v == null || v.length < 6) ? "Mínimo 6 caracteres" : null,
            ),
            const SizedBox(height: 30),
            AuthButton(text: "Iniciar sesión", isLoading: _isLoggingIn, onPressed: _handleLogin),
            const SizedBox(height: 30),
            _buildDivider(),
            const SizedBox(height: 30),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey[300])),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("O CONTINÚA CON", style: TextStyle(fontSize: 11, color: Colors.grey))),
      Expanded(child: Divider(color: Colors.grey[300])),
    ]);
  }

  Widget _buildFooter() {
    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("¿Aún no tienes cuenta? ", style: TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
          child: const Text("Crear una ahora", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}