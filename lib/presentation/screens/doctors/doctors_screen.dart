import 'package:app_top_medicos/presentation/widgets/doctors/doctor_vertical_listview.dart';
import 'package:app_top_medicos/presentation/widgets/layout/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorsScreen extends StatelessWidget {
  static const name = 'doctors_screen';

  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Todos los Doctores Top',
      showBottomNav: false,
      currentIndex: 0,
      onTap: (i) {
        if (i == 0) context.go('/');
        if (i == 1) context.go('/appointments');
        if (i == 2) context.go('/profile');
      },
      body: const DoctorVerticalListView(),
    );
  }
}
