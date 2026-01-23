import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'splash_screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/login');
    });
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
            Image(
              image: NetworkImage(
                'https://topmedicosperu.com/static/logo.png',
              ),
              width: 180,
            ),

            SizedBox(height: 20),

            // Texto con colores
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
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