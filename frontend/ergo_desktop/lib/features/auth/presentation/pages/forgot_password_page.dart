import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ergo_desktop/core/theme/app_colors.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_label.dart';
import '../../data/services/account_service.dart';

enum ForgotStep { inputEmail, inputCodeAndNewPass }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final accountService = GetIt.instance<AccountService>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  
  ForgotStep _currentStep = ForgotStep.inputEmail;
  bool _isLoading = false;
  bool _obscurePass = true;

  void _handleSendCode() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    final success = await accountService.requestPasswordReset(_emailController.text.trim());
    
    setState(() => _isLoading = false);
    if (success) {
      setState(() => _currentStep = ForgotStep.inputCodeAndNewPass);
    } else {
      _showMsg("No pudimos enviar el código. Revisa el correo.", isError: true);
    }
  }

  void _handleReset() async {
    if (_codeController.text.isEmpty || _passController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    final success = await accountService.resetPassword(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _passController.text.trim()
    );

    if (!mounted) return; 
    
    setState(() => _isLoading = false);
    if (success) {
      _showMsg("Contraseña actualizada con éxito.", isError: false);
      Navigator.pop(context);
    } else {
      _showMsg("Código inválido o error al actualizar.", isError: true);
    }
  }

  void _showMsg(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: _currentStep == ForgotStep.inputEmail ? "Recuperar acceso" : "Nueva contraseña",
      subtitle: _currentStep == ForgotStep.inputEmail 
          ? "Ingresa tu correo y te enviaremos un código de seguridad." 
          : "Introduce el código de tu correo y elige tu nueva clave.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentStep == ForgotStep.inputEmail) ...[
            const AuthLabel("Correo electrónico *"),
            AuthTextField(hint: "ejemplo@correo.com", controller: _emailController),
            const SizedBox(height: 30),
            AuthButton(text: "Enviar código", isLoading: _isLoading, onPressed: _handleSendCode),
          ] else ...[
            const AuthLabel("Código de seguridad"),
            AuthTextField(hint: "6 dígitos", controller: _codeController),
            const SizedBox(height: 20),
            const AuthLabel("Nueva contraseña"),
            AuthTextField(
              hint: "••••••••", 
              isPassword: true, 
              obscureText: _obscurePass, 
              controller: _passController,
              togglePassword: () => setState(() => _obscurePass = !_obscurePass),
            ),
            const SizedBox(height: 30),
            AuthButton(text: "Actualizar contraseña", isLoading: _isLoading, onPressed: _handleReset),
          ],
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar y volver", style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        ],
      ),
    );
  }
}