import 'package:app_top_medicos/presentation/screens/doctors/doctor_detail_screen.dart';
import 'package:app_top_medicos/presentation/screens/doctors/doctors_screen.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_top_medicos/presentation/screens/screens.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => _authRedirect(authState, state),
    routes: _appRoutes,
  );
});

String? _authRedirect(AuthState authState, GoRouterState state) {
  final currentPath = state.uri.path;
  final isSplashRoute = currentPath == '/splash';
  final isLoginRoute = currentPath == '/login';
  final isForgotPasswordRoute = currentPath == '/forgot-password';
  final isRegisterRoute = currentPath == '/register';

  if (authState.isCheckingSession) {
    return isSplashRoute ? null : '/splash';
  }

  if (!authState.isAuthenticated) {
    return isLoginRoute ||
            isSplashRoute ||
            isForgotPasswordRoute ||
            isRegisterRoute
        ? null
        : '/login';
  }

  if (isLoginRoute) return '/';

  return null;
}

final _appRoutes = [
  GoRoute(
    path: '/splash',
    name: SplashScreen.name,
    builder: (context, state) => const SplashScreen(),
  ),

  GoRoute(
    path: '/login',
    name: LoginScreen.name,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/forgot-password',
    name: ForgotPasswordScreen.name,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: '/register',
    name: RegisterScreen.name,
    builder: (context, state) => const RegisterScreen(),
  ),

  GoRoute(
    path: '/',
    name: HomeScreen.name,
    builder: (context, state) => const HomeScreen(),
  ),

  GoRoute(
    path: '/buttons',
    name: ButtonsScreen.name,
    builder: (context, state) => const ButtonsScreen(),
  ),

  GoRoute(
    path: '/cards',
    name: CardsScreen.name,
    builder: (context, state) => const CardsScreen(),
  ),

  GoRoute(
    path: '/progress',
    name: ProgressScreen.name,
    builder: (context, state) => const ProgressScreen(),
  ),

  GoRoute(
    path: '/snackbars',
    name: SnackbarScreen.name,
    builder: (context, state) => const SnackbarScreen(),
  ),

  GoRoute(
    path: '/animated',
    name: AnimatedScreen.name,
    builder: (context, state) => const AnimatedScreen(),
  ),

  GoRoute(
    path: '/ui-controls',
    name: UiControlsScreen.name,
    builder: (context, state) => const UiControlsScreen(),
  ),

  GoRoute(
    path: '/tutorial',
    name: AppTutorialScreen.name,
    builder: (context, state) => const AppTutorialScreen(),
  ),

  GoRoute(
    path: '/infinite',
    name: InfiniteScrollScreen.name,
    builder: (context, state) => const InfiniteScrollScreen(),
  ),

  GoRoute(
    path: '/counter-river',
    name: CounterScreen.name,
    builder: (context, state) => const CounterScreen(),
  ),

  GoRoute(
    path: '/theme-changer',
    name: ThemeChangerScreen.name,
    builder: (context, state) => const ThemeChangerScreen(),
  ),
  GoRoute(
    path: '/favorites',
    name: FavoritesScreen.name,
    builder: (context, state) => const FavoritesScreen(),
  ),
  GoRoute(
    path: '/appointments',
    name: AppointmentsScreen.name,
    builder: (context, state) => const AppointmentsScreen(),
  ),
  GoRoute(
    path: '/profile',
    name: ProfileScreen.name,
    builder: (context, state) => const ProfileScreen(),
  ),

  GoRoute(
    path: '/doctors',
    name: DoctorsScreen.name,
    builder: (context, state) => const DoctorsScreen(),
  ),
  GoRoute(
    path: '/search',
    name: MedicalSearchScreen.name,
    builder: (context, state) => const MedicalSearchScreen(),
  ),
  GoRoute(
    path: '/appointment-booking',
    name: AppointmentBookingScreen.name,
    builder: (context, state) {
      final args = state.extra as AppointmentBookingArgs?;

      if (args == null) {
        return const HomeScreen();
      }

      return AppointmentBookingScreen(args: args);
    },
  ),
  GoRoute(
    path: '/doctor-detail/:fullName',
    builder: (context, state) {
      final fullName = state.pathParameters['fullName'] ?? '';
      return DoctorDetailScreen(fullName: fullName);
    },
  ),
];
