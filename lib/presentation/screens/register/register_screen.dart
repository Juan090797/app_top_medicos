import 'package:app_top_medicos/domain/entities/document_type.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/presentation/providers/register/register_provider.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const name = 'register_screen';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  DocumentType? _selectedDocumentType;
  GenderOption? _selectedGender;
  DateTime? _birthdate;
  bool _dataConsent = false;
  bool _communicationsConsent = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _allSelected => _dataConsent && _communicationsConsent;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_dataConsent) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar el tratamiento de tus datos de salud'),
          ),
        );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'name': _nameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'documentType': _selectedDocumentType!.shortDescription,
      'documentNumber': _documentNumberController.text.trim(),
      'gender': _selectedGender!.shortDescription,
      'email': _emailController.text.trim(),
      'repiteEmail': _confirmEmailController.text.trim(),
      'password': _passwordController.text,
      'phoneNumber': _phoneController.text.trim(),
      'birthdate': _formatPayloadDate(_birthdate!),
      'communicationsConsent': _communicationsConsent,
      'dataConsent': _dataConsent,
      'allSelected': _allSelected,
    };

    try {
      await ref
          .read(registerRepositoryProvider)
          .createPatient(payload: payload);

      if (!mounted) return;
      await _showSuccessDialog();
      if (mounted) context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 18, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selected != null) {
      setState(() => _birthdate = selected);
    }
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDFF2D6), width: 4),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Color(0xFF96D47A),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Se ha generado con éxito tu registro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Código de verificación enviado.\nRevise su correo electrónico.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18894E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentTypesAsync = ref.watch(documentTypesProvider);
    final gendersAsync = ref.watch(registerGendersProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(10, topPadding + 10, 18, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.darkBlue, Color(0xFF153F56)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  tooltip: 'Volver',
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Registro gratuito',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: documentTypesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => _CenteredError(
                      message: 'No se pudo cargar tipos de documento: $e',
                    ),
                data:
                    (documentTypes) => gendersAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (e, _) => _CenteredError(
                            message: 'No se pudo cargar géneros: $e',
                          ),
                      data:
                          (genders) => _RegisterForm(
                            formKey: _formKey,
                            nameController: _nameController,
                            lastNameController: _lastNameController,
                            documentNumberController: _documentNumberController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            confirmEmailController: _confirmEmailController,
                            passwordController: _passwordController,
                            documentTypes: documentTypes,
                            genders: genders,
                            selectedDocumentType: _selectedDocumentType,
                            selectedGender: _selectedGender,
                            birthdate: _birthdate,
                            dataConsent: _dataConsent,
                            communicationsConsent: _communicationsConsent,
                            allSelected: _allSelected,
                            obscurePassword: _obscurePassword,
                            isSubmitting: _isSubmitting,
                            onDocumentTypeChanged: (value) {
                              setState(() {
                                _selectedDocumentType = value;
                                _documentNumberController.clear();
                              });
                            },
                            onGenderChanged:
                                (value) =>
                                    setState(() => _selectedGender = value),
                            onBirthdateTap: _pickBirthdate,
                            onAllSelectedChanged: (value) {
                              final selected = value ?? false;
                              setState(() {
                                _dataConsent = selected;
                                _communicationsConsent = selected;
                              });
                            },
                            onDataConsentChanged:
                                (value) => setState(
                                  () => _dataConsent = value ?? false,
                                ),
                            onCommunicationsConsentChanged:
                                (value) => setState(
                                  () => _communicationsConsent = value ?? false,
                                ),
                            onTogglePassword:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                            onSubmit: _submit,
                          ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPayloadDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController documentNumberController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController confirmEmailController;
  final TextEditingController passwordController;
  final List<DocumentType> documentTypes;
  final List<GenderOption> genders;
  final DocumentType? selectedDocumentType;
  final GenderOption? selectedGender;
  final DateTime? birthdate;
  final bool dataConsent;
  final bool communicationsConsent;
  final bool allSelected;
  final bool obscurePassword;
  final bool isSubmitting;
  final ValueChanged<DocumentType?> onDocumentTypeChanged;
  final ValueChanged<GenderOption?> onGenderChanged;
  final VoidCallback onBirthdateTap;
  final ValueChanged<bool?> onAllSelectedChanged;
  final ValueChanged<bool?> onDataConsentChanged;
  final ValueChanged<bool?> onCommunicationsConsentChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.lastNameController,
    required this.documentNumberController,
    required this.phoneController,
    required this.emailController,
    required this.confirmEmailController,
    required this.passwordController,
    required this.documentTypes,
    required this.genders,
    required this.selectedDocumentType,
    required this.selectedGender,
    required this.birthdate,
    required this.dataConsent,
    required this.communicationsConsent,
    required this.allSelected,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onDocumentTypeChanged,
    required this.onGenderChanged,
    required this.onBirthdateTap,
    required this.onAllSelectedChanged,
    required this.onDataConsentChanged,
    required this.onCommunicationsConsentChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registro gratuito',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF202428),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 18),
                _ResponsivePair(
                  first: _TextField(
                    controller: nameController,
                    label: 'Nombre(s) *',
                    validator: _requiredValidator,
                  ),
                  second: _TextField(
                    controller: lastNameController,
                    label: 'Apellidos *',
                    validator: _requiredValidator,
                  ),
                ),
                const SizedBox(height: 14),
                _ResponsivePair(
                  first: _DocumentTypeDropdown(
                    documentTypes: documentTypes,
                    selectedDocumentType: selectedDocumentType,
                    onChanged: onDocumentTypeChanged,
                  ),
                  second: _TextField(
                    controller: documentNumberController,
                    label: 'Nro. de Documento *',
                    enabled: selectedDocumentType != null,
                    keyboardType:
                        _isDni(selectedDocumentType)
                            ? TextInputType.number
                            : TextInputType.text,
                    inputFormatters: [
                      if (_isDni(selectedDocumentType))
                        FilteringTextInputFormatter.digitsOnly,
                      if (selectedDocumentType != null)
                        LengthLimitingTextInputFormatter(
                          selectedDocumentType!.length,
                        ),
                    ],
                    validator: (value) {
                      final documentType = selectedDocumentType;
                      if (documentType == null) {
                        return 'Seleccione un tipo';
                      }
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Campo es obligatorio';
                      if (_isDni(documentType) &&
                          text.length != documentType.length) {
                        return 'Debe tener ${documentType.length} dígitos';
                      }
                      if (!_isDni(documentType) &&
                          documentType.length > 0 &&
                          text.length > documentType.length) {
                        return 'Máximo ${documentType.length} caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _ResponsivePair(
                  first: _DateField(
                    birthdate: birthdate,
                    onTap: onBirthdateTap,
                  ),
                  second: _GenderDropdown(
                    genders: genders,
                    selectedGender: selectedGender,
                    onChanged: onGenderChanged,
                  ),
                ),
                const SizedBox(height: 14),
                _TextField(
                  controller: phoneController,
                  label: 'Celular *',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return 'Campo es obligatorio';
                    if (phone.length != 9) return 'Ingrese 9 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _ResponsivePair(
                  first: _TextField(
                    controller: emailController,
                    label: 'Correo Electrónico *',
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  second: _TextField(
                    controller: confirmEmailController,
                    label: 'Confirmar Correo Electrónico *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final emailError = _emailValidator(value);
                      if (emailError != null) return emailError;
                      if ((value ?? '').trim() != emailController.text.trim()) {
                        return 'Los correos no coinciden';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _TextField(
                  controller: passwordController,
                  label: 'Contraseña *',
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Campo es obligatorio';
                    if (password.length < 8) {
                      return 'Debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: allSelected,
                  onChanged: onAllSelectedChanged,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.darkBlue,
                  title: const Text(
                    'Seleccionar todo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3C454C),
                    ),
                  ),
                ),
                _ConsentCheckbox(
                  value: dataConsent,
                  onChanged: onDataConsentChanged,
                  text:
                      'Doy mi consentimiento para que TopMedicosPerú trates mis datos de salud para usar los servicios. * Saber más',
                ),
                _ConsentCheckbox(
                  value: communicationsConsent,
                  onChanged: onCommunicationsConsentChanged,
                  text:
                      'Quiero recibir comunicaciones comerciales de TopMedicosPerú (Opcional). Saber más',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F64B7),
                      disabledBackgroundColor: const Color(0xFF9DB6C6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        isSubmitting
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Registrarse Gratis',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Al registrarte, confirmas que estás de acuerdo a nuestros términos y condiciones y nuestra política de privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 13,
                    color: Color(0xFF5F666D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Iniciar sesión en TopMedicosPerú ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3C454C),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Acceder a tu cuenta',
                          style: TextStyle(
                            color: Color(0xFF1F64B7),
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Campo es obligatorio';
    return null;
  }

  static String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Campo es obligatorio';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Ingresar un correo válido';
    }
    return null;
  }

  static bool _isDni(DocumentType? documentType) {
    return documentType?.shortDescription.toUpperCase() == 'DNI';
  }
}

class _ResponsivePair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsivePair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(children: [first, const SizedBox(height: 14), second]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 18),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _TextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
    );
  }
}

class _DocumentTypeDropdown extends StatelessWidget {
  final List<DocumentType> documentTypes;
  final DocumentType? selectedDocumentType;
  final ValueChanged<DocumentType?> onChanged;

  const _DocumentTypeDropdown({
    required this.documentTypes,
    required this.selectedDocumentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DocumentType>(
      value: selectedDocumentType,
      isExpanded: true,
      decoration: _inputDecoration('Tipo de Documento *'),
      items:
          documentTypes.map((documentType) {
            return DropdownMenuItem(
              value: documentType,
              child: Text(documentType.shortDescription),
            );
          }).toList(),
      validator: (value) => value == null ? 'Campo es obligatorio' : null,
      onChanged: onChanged,
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final List<GenderOption> genders;
  final GenderOption? selectedGender;
  final ValueChanged<GenderOption?> onChanged;

  const _GenderDropdown({
    required this.genders,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GenderOption>(
      value: selectedGender,
      isExpanded: true,
      decoration: _inputDecoration('Género *'),
      items:
          genders.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender.description),
            );
          }).toList(),
      validator: (value) => value == null ? 'Campo es obligatorio' : null,
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? birthdate;
  final VoidCallback onTap;

  const _DateField({required this.birthdate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(birthdate?.toIso8601String() ?? 'empty-birthdate'),
      readOnly: true,
      onTap: onTap,
      initialValue: birthdate == null ? '' : _formatDisplayDate(birthdate!),
      decoration: _inputDecoration('Fecha de Nacimiento *').copyWith(
        hintText: 'dd/mm/aaaa',
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      validator: (_) {
        if (birthdate == null) return 'Campo es obligatorio';
        return null;
      },
    );
  }

  static String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.only(left: 32),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.darkBlue,
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.35,
          color: Color(0xFF3C454C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CenteredError extends StatelessWidget {
  final String message;

  const _CenteredError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9B1C1C),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Color(0xFF4D565D),
      fontWeight: FontWeight.w800,
      fontSize: 14,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF9DC4FF), width: 1.6),
    ),
    errorStyle: const TextStyle(
      color: Color(0xFFE11D48),
      fontWeight: FontWeight.w600,
    ),
  );
}
