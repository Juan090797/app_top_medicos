import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login_screen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Logo
                const Image(
                  image: NetworkImage('https://topmedicosperu.com/static/logo.png'),
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 14),

                // Título
                const Text(
                  'Iniciar sesion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtítulo
                const Text(
                  'Gestiona tus citas médicas con facilidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF355A6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 28),

                // Email
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Correo electronico'),
                ),

                const SizedBox(height: 14),

                // Password
                TextField(
                  obscureText: true,
                  decoration: _inputDecoration('Contraseña'),
                ),

                const SizedBox(height: 22),

                // Botón Ingresar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E2E3F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Ingresar'),
                  ),
                ),

                const SizedBox(height: 18),

                // Olvidaste tu contraseña
                GestureDetector(
                  onTap: () {
                    // TODO: navegar a recuperar contraseña cuando la crees
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E2E3F),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // No tienes cuenta? Registrate
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0E2E3F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: navegar a registro cuando la crees
                      },
                      child: const Text(
                        'Registrate',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0E2E3F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}