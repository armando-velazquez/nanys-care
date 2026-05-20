import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/nanys_logo.dart';

/// Pantalla intermedia que decide a dónde mandar al usuario al arrancar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decidirRuta());
  }

  Future<void> _decidirRuta() async {
    final auth = context.read<AuthProvider>();
    await auth.cargarSesion();
    if (!mounted) return;

    if (auth.autenticado) {
      final destino = auth.usuario!.rol == UserRole.tutor
          ? AppRoutes.tutorHome
          : AppRoutes.caregiverHome;
      context.go(destino);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NanysLogo(fontSize: 36),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
