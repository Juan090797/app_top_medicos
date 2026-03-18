import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showBack;
  final bool showBottomNav;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    this.showBack = true,
    this.showBottomNav = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
        leading: showBack ? const BackButton() : null,
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
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
      )
      : null,
    );
  }
}
