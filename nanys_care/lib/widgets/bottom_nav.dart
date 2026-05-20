import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_router.dart';
import '../theme/app_colors.dart';

class TutorBottomNav extends StatelessWidget {
  final int indexActual;
  const TutorBottomNav({super.key, required this.indexActual});

  void _navegar(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        context.go(AppRoutes.tutorHome);
        break;
      case 1:
        context.go(AppRoutes.tutorSearch);
        break;
      case 2:
        context.go(AppRoutes.tutorReservations);
        break;
      case 3:
      case 4:
        // Mensajes y Perfil son de sprints posteriores. Mostramos aviso.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disponible en próximos sprints'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: indexActual,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (i) => _navegar(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Reservas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Mensajes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}

class CaregiverBottomNav extends StatelessWidget {
  final int indexActual;
  const CaregiverBottomNav({super.key, required this.indexActual});

  void _navegar(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        context.go(AppRoutes.caregiverHome);
        break;
      case 1:
        context.go(AppRoutes.caregiverRequests);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disponible en próximos sprints'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: indexActual,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (i) => _navegar(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), label: 'Solicitudes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Mensajes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
