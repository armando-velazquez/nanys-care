import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_role.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/nanys_logo.dart';
import '../../widgets/step_indicator.dart';

/// Pantalla 02 - "NanysCareTutorOCuidador"
/// El usuario elige el rol con el que va a usar la app.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _seleccionar(BuildContext context, UserRole rol) {
    final ruta = rol == UserRole.tutor
        ? AppRoutes.registerTutor
        : AppRoutes.registerCaregiver;
    context.push(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: StepIndicator(pasoActual: 2, total: 4),
              ),
              const SizedBox(height: 32),
              Text(
                '¿Cómo deseas usar\nNanys Care?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Selecciona una opción para continuar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 32),
              _OpcionRol(
                titulo: 'Soy Tutor',
                descripcion: 'Busco una persona para cuidar a mis hijos.',
                icono: Icons.groups,
                colorFondo: AppColors.primarySurface,
                colorAcento: AppColors.primary,
                onTap: () => _seleccionar(context, UserRole.tutor),
              ),
              const SizedBox(height: 16),
              _OpcionRol(
                titulo: 'Soy Cuidador',
                descripcion: 'Quiero ofrecer mis servicios de cuidado.',
                icono: Icons.person,
                colorFondo: AppColors.accentSurface,
                colorAcento: AppColors.accent,
                onTap: () => _seleccionar(context, UserRole.cuidador),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿No estás seguro?',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text(
                            'Puedes cambiar tu rol más tarde desde la configuración de tu cuenta.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: NanysLogo(fontSize: 20)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionRol extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color colorFondo;
  final Color colorAcento;
  final VoidCallback onTap;

  const _OpcionRol({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorFondo,
    required this.colorAcento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icono, size: 36, color: colorAcento),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icono == Icons.groups ? Icons.groups : Icons.person,
                          size: 18, color: colorAcento),
                      const SizedBox(width: 6),
                      Text(titulo,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorAcento)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(descripcion,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorAcento,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right,
                  color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
