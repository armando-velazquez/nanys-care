import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_caregiver_screen.dart';
import '../screens/auth/register_tutor_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/caregiver/care_requests_screen.dart';
import '../screens/caregiver/caregiver_home_screen.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/tutor/book_appointment_screen.dart';
import '../screens/tutor/caregiver_detail_screen.dart';
import '../screens/tutor/my_reservations_screen.dart';
import '../screens/tutor/search_caregivers_screen.dart';
import '../screens/tutor/tutor_home_screen.dart';
import '../screens/tutor/tutor_profile_setup_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const welcome = '/welcome';
  static const roleSelection = '/role-selection';
  static const registerTutor = '/register-tutor';
  static const registerCaregiver = '/register-caregiver';
  static const login = '/login';

  static const tutorProfileSetup = '/tutor/profile-setup';
  static const tutorHome = '/tutor/home';
  static const tutorSearch = '/tutor/search';
  static const tutorCaregiverDetail = '/tutor/caregiver';
  static const tutorBook = '/tutor/book';
  static const tutorReservations = '/tutor/reservations';

  static const caregiverHome = '/caregiver/home';
  static const caregiverRequests = '/caregiver/requests';
}

class AppRouter {
  static GoRouter build(AuthProvider auth) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, __) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.roleSelection,
          builder: (_, __) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerTutor,
          builder: (_, __) => const RegisterTutorScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerCaregiver,
          builder: (_, __) => const RegisterCaregiverScreen(),
        ),

        // Tutor
        GoRoute(
          path: AppRoutes.tutorProfileSetup,
          builder: (_, __) => const TutorProfileSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.tutorHome,
          builder: (_, __) => const TutorHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.tutorSearch,
          builder: (_, __) => const SearchCaregiversScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.tutorCaregiverDetail}/:id',
          builder: (ctx, state) =>
              CaregiverDetailScreen(cuidadorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '${AppRoutes.tutorBook}/:id',
          builder: (ctx, state) =>
              BookAppointmentScreen(cuidadorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.tutorReservations,
          builder: (_, __) => const MyReservationsScreen(),
        ),

        // Cuidador
        GoRoute(
          path: AppRoutes.caregiverHome,
          builder: (_, __) => const CaregiverHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.caregiverRequests,
          builder: (_, __) => const CareRequestsScreen(),
        ),
      ],
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final autenticado = auth.autenticado;

        // En el splash dejamos que él mismo redirija.
        if (loc == AppRoutes.splash) return null;

        // Si el usuario está autenticado e intenta entrar a un flujo
        // de auth, lo mandamos a su home.
        final rutasAuth = {
          AppRoutes.welcome,
          AppRoutes.roleSelection,
          AppRoutes.login,
          AppRoutes.registerTutor,
          AppRoutes.registerCaregiver,
        };
        if (autenticado && rutasAuth.contains(loc)) {
          return auth.usuario!.rol == UserRole.tutor
              ? AppRoutes.tutorHome
              : AppRoutes.caregiverHome;
        }

        // Si no está autenticado y trata de entrar a una ruta protegida,
        // lo mandamos al welcome.
        if (!autenticado && !rutasAuth.contains(loc)) {
          return AppRoutes.welcome;
        }
        return null;
      },
    );
  }
}
