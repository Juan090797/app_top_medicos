import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/profile/patient_profile_provider.dart';
import 'package:app_top_medicos/presentation/screens/profile/change_password_dialog.dart';
import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const name = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedGender;
  bool _didSyncFromApi = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(patientProfileProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        ref.read(patientProfileProvider.notifier).clearMessages();
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.successMessage!)));
        ref.read(patientProfileProvider.notifier).clearMessages();
      }
    });

    final authState = ref.watch(authProvider);
    final profileState = ref.watch(patientProfileProvider);

    final profile = profileState.profile;
    final genders = profileState.genders;

    if (profile != null && !_didSyncFromApi) {
      phoneController.text = profile.phoneNumber;
      selectedGender = profile.gender;
      _didSyncFromApi = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child:
            profileState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                ? const Center(child: Text('No se pudo cargar el perfil.'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _ProfileAvatar(
                          urlImagenUser: authState.user?.urlImagenUser,
                          fullName: profile.fullName,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0E2E3F),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _Label('Nombres y Apellidos'),
                        const SizedBox(height: 8),
                        _ReadOnlyField(value: profile.fullName),
                        const SizedBox(height: 16),
                        const _Label('Correo Electrónico'),
                        const SizedBox(height: 8),
                        _ReadOnlyField(value: profile.email),
                        const SizedBox(height: 16),
                        const _Label('Celular'),
                        const SizedBox(height: 8),
                        _EditableInput(
                          controller: phoneController,
                          hint: 'Ingrese su celular',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            final phone = (value ?? '').trim();
                            if (phone.isEmpty) return 'Ingrese su celular';
                            if (phone.length < 6) return 'Celular inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _Label('Género'),
                        const SizedBox(height: 8),
                        _GenderDropdown(
                          genders: genders,
                          value: selectedGender,
                          onChanged: (value) {
                            setState(() => selectedGender = value);
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                profileState.isSaving
                                    ? null
                                    : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      final gender =
                                          selectedGender
                                              ?.trim()
                                              .toUpperCase() ??
                                          '';
                                      if (gender != 'M' && gender != 'F') {
                                        ScaffoldMessenger.of(context)
                                          ..clearSnackBars()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Seleccione un género válido',
                                              ),
                                            ),
                                          );
                                        return;
                                      }

                                      await ref
                                          .read(patientProfileProvider.notifier)
                                          .updateEditableFields(
                                            phoneNumber:
                                                phoneController.text.trim(),
                                            gender: gender,
                                          );
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E2E3F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            child:
                                profileState.isSaving
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text('Guardar Cambios'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => const ChangePasswordDialog(),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0E2E3F),
                              side: const BorderSide(
                                color: Color(0xFF0E2E3F),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            child: const Text('Cambiar Contraseña'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Cerrar Sesión'),
                                      content: const Text(
                                        '¿Estás seguro de que deseas cerrar sesión?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Cerrar Sesión',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) context.go('/login');
                              }
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text('Cerrar Sesión'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/appointments');
          if (i == 2) return;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? urlImagenUser;
  final String fullName;

  const _ProfileAvatar({required this.urlImagenUser, required this.fullName});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (urlImagenUser ?? '').trim();
    final hasValidImage =
        imageUrl.isNotEmpty &&
        !imageUrl.endsWith('/null') &&
        !imageUrl.contains('/static/null');

    if (hasValidImage) {
      return Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFE1D6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      );
    }

    return InitialsAvatar(fullName: fullName, radius: 60);
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFF355A6B),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;

  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0E2E3F),
        ),
      ),
    );
  }
}

class _EditableInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _EditableInput({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0E2E3F)),
        ),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final List<GenderOption> genders;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({
    required this.genders,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: (value == 'M' || value == 'F') ? value : null,
      onChanged: onChanged,
      items:
          genders
              .map(
                (gender) => DropdownMenuItem<String>(
                  value: gender.shortDescription,
                  child: Text(gender.description),
                ),
              )
              .toList(),
      decoration: InputDecoration(
        hintText: 'Seleccione género',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0E2E3F)),
        ),
      ),
      validator: (selected) {
        final gender = (selected ?? '').toUpperCase();
        if (gender != 'M' && gender != 'F') {
          return 'Seleccione un género';
        }
        return null;
      },
    );
  }
}
