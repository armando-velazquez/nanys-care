import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/nanys_logo.dart';

/// Pantalla 13 - "NCInicioDeCuidador_DashBoard"
/// Dashboard principal del Cuidador.
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null) return;
    await context.read<ProfileProvider>().cargarPerfilCuidador(auth.usuario!.id);
    await context.read<BookingProvider>().cargarParaCuidador(auth.usuario!.id);
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().cerrarSesion();
    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final booking = context.watch<BookingProvider>();
    final nombre = auth.usuario?.nombreCompleto.split(' ').first ?? 'Cuidador';

    final solicitudes = booking.solicitudesCuidador;
    final nuevas =
        solicitudes.where((c) => c.estado == EstadoCita.pendiente).length;
    final confirmadas =
        solicitudes.where((c) => c.estado == EstadoCita.confirmada).length;
    final proximos = solicitudes
        .where((c) =>
            c.estado == EstadoCita.confirmada &&
            c.fecha.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final horasProgramadas =
        confirmadas == 0 ? 0 : proximos.fold(0, (acc, c) => acc + c.duracionHoras);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primary),
                    onPressed: _cerrarSesion,
                    tooltip: 'Cerrar sesión',
                  ),
                  const NanysLogo(fontSize: 20),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.primary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Notificaciones próximamente')),
                          );
                        },
                      ),
                      if (nuevas > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$nuevas',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('¡Hola, $nombre! 👋',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Text('Gracias por cuidar con amor',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Disponible para nuevas solicitudes',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                            fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _resumenDeHoy(
                solicitudesNuevas: nuevas,
                serviciosConfirmados: confirmadas,
                horasProgramadas: horasProgramadas,
                calificacion: profile.perfilCuidador?.calificacionPromedio ?? 0,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mantén tu perfil actualizado',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent)),
                          SizedBox(height: 2),
                          Text(
                            'Completa tu información y documentos para recibir más oportunidades.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Editor de perfil en próximos sprints')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent),
                        foregroundColor: AppColors.accent,
                        minimumSize: const Size(100, 36),
                      ),
                      child: const Text('Actualizar',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Próximos servicios',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Agenda detallada en próximos sprints')),
                      );
                    },
                    child: const Text('Ver agenda',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              if (proximos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.event_busy,
                          color: AppColors.textHint, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aún no tienes servicios confirmados.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _tarjetaProximoServicio(proximos.first),
              const SizedBox(height: 16),
              const Text('Herramientas rápidas',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  _Herramienta(
                    icono: Icons.assignment_outlined,
                    titulo: 'Solicitudes\nde cuidado',
                    colorFondo: AppColors.accentSurface,
                    colorIcono: AppColors.accent,
                    onTap: () => context.push(AppRoutes.caregiverRequests),
                  ),
                  _Herramienta(
                    icono: Icons.event_note_outlined,
                    titulo: 'Mi agenda',
                    colorFondo: AppColors.primarySurface,
                    colorIcono: AppColors.primary,
                    onTap: _proximo,
                  ),
                  _Herramienta(
                    icono: Icons.chat_bubble_outline,
                    titulo: 'Notas\nprivadas',
                    colorFondo: AppColors.accentSurface,
                    colorIcono: AppColors.accent,
                    onTap: _proximo,
                  ),
                  _Herramienta(
                    icono: Icons.description_outlined,
                    titulo: 'Reglamento',
                    colorFondo: AppColors.primarySurface,
                    colorIcono: AppColors.primary,
                    onTap: _proximo,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tu seguridad es importante',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text(
                            'Sigue nuestras recomendaciones y el reglamento de la comunidad.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _proximo,
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(80, 36)),
                      child: const Text('Ver reglamento',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CaregiverBottomNav(indexActual: 0),
    );
  }

  void _proximo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponible en próximos sprints')),
    );
  }

  Widget _resumenDeHoy({
    required int solicitudesNuevas,
    required int serviciosConfirmados,
    required int horasProgramadas,
    required double calificacion,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu resumen de hoy',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Indicador(
                  icono: Icons.assignment,
                  valor: '$solicitudesNuevas',
                  etiqueta: 'Solicitudes\nnuevas',
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _Indicador(
                  icono: Icons.event_available,
                  valor: '$serviciosConfirmados',
                  etiqueta: 'Servicios\nconfirmados',
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _Indicador(
                  icono: Icons.access_time,
                  valor: '$horasProgramadas h',
                  etiqueta: 'Horas\nprogramadas',
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _Indicador(
                  icono: Icons.star,
                  valor: calificacion.toStringAsFixed(1),
                  etiqueta: 'Calificación\npromedio',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaProximoServicio(Cita cita) {
    final dia = DateFormat('d', 'es_MX').format(cita.fecha);
    final mes = DateFormat('MMM', 'es_MX').format(cita.fecha).toUpperCase();
    final diaSemana =
        DateFormat('EEE', 'es_MX').format(cita.fecha).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(mes,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
              Text(dia,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text(diaSemana,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Servicio confirmado',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(cita.tipoCuidado,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('${cita.horaInicio} - ${cita.horaFin}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Confirmado',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;
  const _Indicador({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icono, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(valor,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Herramienta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color colorFondo;
  final Color colorIcono;
  final VoidCallback onTap;
  const _Herramienta({
    required this.icono,
    required this.titulo,
    required this.colorFondo,
    required this.colorIcono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorFondo,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: colorIcono, size: 20),
            ),
            const SizedBox(height: 6),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
