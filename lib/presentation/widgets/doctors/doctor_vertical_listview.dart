import 'package:app_top_medicos/presentation/widgets/doctors/doctor_card_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/presentation/providers/doctors/doctors_provider.dart';

class DoctorVerticalListView extends ConsumerStatefulWidget {
  const DoctorVerticalListView({super.key});

  @override
  ConsumerState<DoctorVerticalListView> createState()
      => _DoctorVerticalListViewState();
}

class _DoctorVerticalListViewState
    extends ConsumerState<DoctorVerticalListView> {

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.position.pixels + 200 >=
          controller.position.maxScrollExtent) {
        ref.read(doctorsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final state = ref.watch(doctorsProvider);

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      itemCount: state.doctors.length + 1,
      itemBuilder: (context, index) {

        if (index < state.doctors.length) {
          final doctor = state.doctors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: DoctorCardPro(doctor: doctor),
          );
        }

        return state.isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            : const SizedBox();
      },
    );
  }
}
