import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const name = 'splash_screen';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final ProviderSubscription _authSub;

  bool _didNavigate = false;

  void _redirect(AuthState authState) {
    if (!mounted || authState.isCheckingSession || _didNavigate) return;

    _didNavigate = true;

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(authState.isAuthenticated ? '/' : '/login');
    });
  }

  @override
  void initState() {
    super.initState();

    _authSub = ref.listenManual(authProvider, (previous, next) {
      _redirect(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect(ref.read(authProvider));
    });
  }

  @override
  void dispose() {
    _authSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF143042),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Imagen desde URL
            SizedBox(
              width: 100, // prueba 280–320
              child: Image.network(
                'https://topmedicosperu.com/static/logo.png',
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 20),

            // Texto con colores
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                children: [
                  TextSpan(
                    text: 'TOP',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: 'MEDICOS',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                    text: 'PERU',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}