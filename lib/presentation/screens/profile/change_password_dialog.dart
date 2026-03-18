import 'package:app_top_medicos/presentation/providers/profile/patient_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showRepeatPassword = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(patientProfileProvider);

    ref.listen(patientProfileProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ));
        ref.read(patientProfileProvider.notifier).clearMessages();
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ));
        ref.read(patientProfileProvider.notifier).clearMessages();

        // Cerrar diálogo después de éxito
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        });
      }
    });

    return AlertDialog(
      title: const Text('Cambiar Contraseña'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _PasswordField(
                controller: oldPasswordController,
                label: 'Contraseña Actual',
                hint: 'Ingrese su contraseña actual',
                obscureText: !_showOldPassword,
                onToggleVisibility: () {
                  setState(() => _showOldPassword = !_showOldPassword);
                },
                validator: (value) {
                  final password = (value ?? '').trim();
                  if (password.isEmpty) return 'Ingrese su contraseña actual';
                  if (password.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _PasswordField(
                controller: newPasswordController,
                label: 'Nueva Contraseña',
                hint: 'Ingrese su nueva contraseña',
                obscureText: !_showNewPassword,
                onToggleVisibility: () {
                  setState(() => _showNewPassword = !_showNewPassword);
                },
                validator: (value) {
                  final password = (value ?? '').trim();
                  if (password.isEmpty) return 'Ingrese su nueva contraseña';
                  if (password.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _PasswordField(
                controller: repeatPasswordController,
                label: 'Repetir Contraseña',
                hint: 'Repita su nueva contraseña',
                obscureText: !_showRepeatPassword,
                onToggleVisibility: () {
                  setState(() => _showRepeatPassword = !_showRepeatPassword);
                },
                validator: (value) {
                  final password = (value ?? '').trim();
                  if (password.isEmpty) return 'Repita su contraseña';
                  if (password.length < 6) return 'Mínimo 6 caracteres';
                  if (password != newPasswordController.text.trim()) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: profileState.isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  await ref
                      .read(patientProfileProvider.notifier)
                      .changePassword(
                        oldPassword: oldPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                        repeatNewPassword:
                            repeatPasswordController.text.trim(),
                      );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E2E3F),
            foregroundColor: Colors.white,
          ),
          child: profileState.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Cambiar'),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0E2E3F)),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
