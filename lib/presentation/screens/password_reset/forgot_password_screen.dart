import 'dart:async';

import 'package:app_top_medicos/domain/entities/password_reset_otp.dart';
import 'package:app_top_medicos/presentation/providers/password_reset/password_reset_provider.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const name = 'forgot_password_screen';

  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  PasswordResetOtp? _otp;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isSending = false;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(passwordResetRepositoryProvider);
      final otp = await repository.sendOtp(email: _emailController.text);

      if (!mounted) return;

      for (final controller in _otpControllers) {
        controller.clear();
      }
      setState(() {
        _otp = otp;
        _remaining = otp.expiresAt.difference(DateTime.now());
        if (_remaining.isNegative) _remaining = Duration.zero;
      });
      _startTimer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otpFocusNodes.first.requestFocus();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final otp = _otp;
      if (otp == null || !mounted) return;

      final remaining = otp.expiresAt.difference(DateTime.now());
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });

      if (remaining.isNegative) _timer?.cancel();
    });
  }

  void _showPendingVerification() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('El servicio para verificar el código está pendiente'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isOtpStep = _otp != null;
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
                const Expanded(child: _PageTitle()),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                children: [
                  SizedBox(height: isOtpStep ? 12 : 32),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child:
                          isOtpStep
                              ? _OtpCard(
                                key: const ValueKey('otp-card'),
                                controllers: _otpControllers,
                                focusNodes: _otpFocusNodes,
                                remaining: _remaining,
                                onVerify: _showPendingVerification,
                                onEditEmail: () {
                                  _timer?.cancel();
                                  setState(() => _otp = null);
                                },
                              )
                              : _EmailCard(
                                key: const ValueKey('email-card'),
                                formKey: _formKey,
                                emailController: _emailController,
                                isSending: _isSending,
                                onSend: _sendOtp,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(width: 190, height: 2, color: const Color(0xFFFFC857)),
      ],
    );
  }
}

class _EmailCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isSending;
  final VoidCallback onSend;

  const _EmailCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return _ResetCard(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Te enviaremos un mensaje con un código de verificación para que puedas crear tu nueva contraseña.',
              style: TextStyle(
                height: 1.6,
                fontSize: 13,
                color: Color(0xFF4D565D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Correo electrónico *'),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Campo es obligatorio';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9DB6C6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Enviar',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpCard extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Duration remaining;
  final VoidCallback onVerify;
  final VoidCallback onEditEmail;

  const _OtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.remaining,
    required this.onVerify,
    required this.onEditEmail,
  });

  @override
  State<_OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<_OtpCard> {
  bool get _isComplete {
    return widget.controllers.every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return _ResetCard(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.darkBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Código de verificación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF202428),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Hemos enviado un código OTP a tu correo electrónico para verificarlo',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              fontSize: 13,
              color: Color(0xFF5A6268),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _formatDuration(widget.remaining),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202428),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, _buildOtpBox),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isComplete ? widget.onVerify : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF9DB6C6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verificar y continuar',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onEditEmail,
            child: const Text(
              'Cambiar correo',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
      child: SizedBox(
        width: 44,
        height: 48,
        child: TextField(
          controller: widget.controllers[index],
          focusNode: widget.focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF202428),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.darkBlue),
            ),
          ),
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty && index < widget.focusNodes.length - 1) {
              widget.focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              widget.focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = safe.inMinutes.remainder(60).toString();
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ResetCard extends StatelessWidget {
  final Widget child;

  const _ResetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Color(0xFF3C454C),
      fontWeight: FontWeight.w800,
      fontSize: 14,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFD8DEE3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.3),
    ),
    errorStyle: const TextStyle(
      color: Color(0xFFE11D48),
      fontWeight: FontWeight.w600,
    ),
  );
}
