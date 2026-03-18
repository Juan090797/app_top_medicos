import 'package:flutter/material.dart';

/// Genera un avatar con iniciales y color basado en la primera letra,
/// estilo Google. Usa la primera letra del nombre y la primera del apellido.
class InitialsAvatar extends StatelessWidget {
  final String fullName;
  final double radius;

  const InitialsAvatar({
    super.key,
    required this.fullName,
    this.radius = 26,
  });

  static const _colors = <Color>[
    Color(0xFFE53935), // A
    Color(0xFF8E24AA), // B
    Color(0xFF5C6BC0), // C
    Color(0xFF039BE5), // D
    Color(0xFF00ACC1), // E
    Color(0xFF00897B), // F
    Color(0xFF43A047), // G
    Color(0xFF7CB342), // H
    Color(0xFFC0CA33), // I
    Color(0xFFFFB300), // J
    Color(0xFFFB8C00), // K
    Color(0xFFF4511E), // L
    Color(0xFF6D4C41), // M
    Color(0xFF757575), // N
    Color(0xFF1E88E5), // O
    Color(0xFFD81B60), // P
    Color(0xFF8E24AA), // Q
    Color(0xFF3949AB), // R
    Color(0xFF00897B), // S
    Color(0xFF00ACC1), // T
    Color(0xFF039BE5), // U
    Color(0xFF7CB342), // V
    Color(0xFFE53935), // W
    Color(0xFFFB8C00), // X
    Color(0xFFFFB300), // Y
    Color(0xFF5C6BC0), // Z
  ];

  static String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';

    final first = parts.first[0].toUpperCase();
    if (parts.length < 2) return first;

    // Buscar primer apellido (saltar segundos nombres comunes)
    String last = parts.last[0].toUpperCase();
    if (parts.length > 2) {
      last = parts[parts.length > 3 ? 2 : 1][0].toUpperCase();
    }

    return '$first$last';
  }

  static Color getColor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return _colors[0];
    final index = trimmed[0].toUpperCase().codeUnitAt(0) - 65; // 'A' = 65
    if (index < 0 || index >= _colors.length) return _colors[0];
    return _colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(fullName);
    final color = getColor(fullName);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
