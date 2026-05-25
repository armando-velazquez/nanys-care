import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

/// Pantalla de consulta del reglamento interno de uso (H16).
/// Contenido local, breve y orientado al MVP escolar.
class UsageRegulationScreen extends StatelessWidget {
  const UsageRegulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reglamento de uso'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _IntroCard(),
              SizedBox(height: 12),
              _RuleItem(
                icon: Icons.access_time,
                title: '1) Puntualidad en citas',
                text:
                    'Tutor y cuidador deben conectarse o presentarse a la hora acordada. Se recomienda confirmar la cita con antelación para evitar retrasos.',
              ),
              _RuleItem(
                icon: Icons.event_busy,
                title: '2) Cancelaciones',
                text:
                    'Si una cita no podrá realizarse, debe cancelarse con la mayor anticipación posible desde la app. Evita cancelaciones repetidas de último minuto.',
              ),
              _RuleItem(
                icon: Icons.handshake_outlined,
                title: '3) Respeto entre tutor y cuidador',
                text:
                    'Toda interacción debe mantenerse en un tono respetuoso y profesional. No se permiten insultos, amenazas ni discriminación.',
              ),
              _RuleItem(
                icon: Icons.child_care,
                title: '4) Seguridad básica del menor',
                text:
                    'El tutor debe compartir información importante del menor (alergias, rutinas, contactos de emergencia). El cuidador debe seguir las indicaciones acordadas.',
              ),
              _RuleItem(
                icon: Icons.payments_outlined,
                title: '5) Pagos y tarifas',
                text:
                    'Las tarifas mostradas en el perfil son referencia para acordar el servicio. Cualquier ajuste debe quedar claro entre las partes antes de iniciar la cita.',
              ),
              _RuleItem(
                icon: Icons.smartphone,
                title: '6) Uso responsable de la plataforma',
                text:
                    'Nanys Care se usa para coordinar servicios de cuidado infantil dentro del contexto escolar del proyecto. No debe usarse para fines ilícitos o engañosos.',
              ),
              _RuleItem(
                icon: Icons.report_problem_outlined,
                title: '7) Conducta inapropiada',
                text:
                    'Ante comportamientos inapropiados, el usuario afectado debe suspender el acuerdo y reportarlo al equipo del proyecto para revisión académica.',
              ),
              _RuleItem(
                icon: Icons.privacy_tip_outlined,
                title: '8) Privacidad de información',
                text:
                    'Los datos personales y del menor deben compartirse únicamente para coordinar el cuidado. Evita difundir capturas, direcciones o teléfonos sin consentimiento.',
              ),
              _RuleItem(
                icon: Icons.gavel_outlined,
                title: '9) Responsabilidad de acuerdos',
                text:
                    'Los acuerdos finales de horario, actividades y condiciones del servicio son responsabilidad de tutor y cuidador. La app facilita la conexión y registro local.',
              ),
              SizedBox(height: 12),
              _FooterNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Este reglamento interno orienta el uso de Nanys Care en su versión MVP escolar. Está diseñado para una lectura rápida y para promover acuerdos seguros y claros.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.35),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _RuleItem({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Nota: Este contenido es académico y puede evolucionar en sprints futuros según lineamientos del curso.',
      style: TextStyle(fontSize: 11, color: AppColors.textHint),
    );
  }
}
