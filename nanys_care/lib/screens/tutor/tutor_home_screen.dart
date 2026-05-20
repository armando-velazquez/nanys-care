import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/caregiver_list_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

/// Pantalla 05 - "NC InicioTutor"
/// Dashboard del Tutor con accesos rápidos.
class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  Future<void> _cargarDatos() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null) return;
    await context.read<ProfileProvider>().cargarPerfilTutor(auth.usuario!.id);
    await context.read<CaregiverListProvider>().cargar();
    await context.read<BookingProvider>().cargarParaTutor(auth.usuario!.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final booking = context.watch<BookingProvider>();
    final nombre = auth.usuario?.nombreCompleto.split(' ').first ?? 'Tutor';
    final proximas = booking.citasProximasTutor();

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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, $nombre!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Text(
                          'Bienvenida de nuevo 👋',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.primary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Notificaciones disponibles en próximos sprints')),
                          );
                        },
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _heroBuscar(),
              const SizedBox(height: 20),
              Text('¿Qué quieres hacer hoy?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _gridAcciones(),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.schedule, color: AppColors.primary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Próxima reserva',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (proximas.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.event_busy,
                          color: AppColors.textHint, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aún no tienes reservas. Busca un cuidador para empezar.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _tarjetaProxima(proximas.first),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
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
                      child: const Icon(Icons.lightbulb_outline,
                          color: AppColors.warning),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Consejo del día',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text(
                            'Revisa los perfiles, reseñas y certificaciones para elegir al cuidador ideal para tu familia.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(indexActual: 0),
    );
  }

  Widget _heroBuscar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primarySurface, AppColors.accentSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encuentra al cuidador\nideal para tu familia',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conectamos familias con cuidadores de confianza.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.tutorSearch),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Buscar cuidador'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 44),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite,
                color: AppColors.accent, size: 44),
          ),
        ],
      ),
    );
  }

  Widget _gridAcciones() {
    final acciones = [
      _Accion(
        icono: Icons.search,
        titulo: 'Buscar cuidador',
        descripcion: 'Encuentra el mejor cuidador para tus hijos',
        colorFondo: AppColors.primarySurface,
        colorIcono: AppColors.primary,
        onTap: () => context.push(AppRoutes.tutorSearch),
      ),
      _Accion(
        icono: Icons.calendar_month_outlined,
        titulo: 'Mis reservas',
        descripcion: 'Consulta y gestiona tus reservas',
        colorFondo: AppColors.accentSurface,
        colorIcono: AppColors.accent,
        onTap: () => context.push(AppRoutes.tutorReservations),
      ),
      _Accion(
        icono: Icons.event_note_outlined,
        titulo: 'Agenda',
        descripcion: 'Revisa tu calendario de citas',
        colorFondo: AppColors.successSurface,
        colorIcono: AppColors.success,
        onTap: _proximoSprint,
      ),
      _Accion(
        icono: Icons.chat_bubble_outline,
        titulo: 'Mensajes',
        descripcion: 'Conversaciones y notificaciones',
        colorFondo: AppColors.primarySurface,
        colorIcono: AppColors.primary,
        onTap: _proximoSprint,
      ),
      _Accion(
        icono: Icons.person_outline,
        titulo: 'Mi perfil',
        descripcion: 'Edita tu información y la de tus hijos',
        colorFondo: AppColors.warningSurface,
        colorIcono: AppColors.warning,
        onTap: () => context.push(AppRoutes.tutorProfileSetup),
      ),
      _Accion(
        icono: Icons.settings_outlined,
        titulo: 'Configuración',
        descripcion: 'Ajustes de la aplicación',
        colorFondo: AppColors.primarySurface,
        colorIcono: AppColors.primary,
        onTap: _proximoSprint,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: acciones.length,
      itemBuilder: (_, i) => acciones[i].build(),
    );
  }

  void _proximoSprint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disponible en próximos sprints'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _tarjetaProxima(Cita cita) {
    final formato = DateFormat("d MMM y", 'es_MX');
    final caregivers = context.read<CaregiverListProvider>();
    final entry = caregivers.porId(cita.cuidadorId);
    final nombre = entry?.usuario.nombreCompleto ?? 'Cuidador';
    final ubicacion = entry?.usuario.ubicacion ?? '—';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              nombre[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified,
                        color: AppColors.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(ubicacion,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  '${formato.format(cita.fecha)} · ${cita.horaInicio} - ${cita.horaFin}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _badgeEstado(cita.estado),
        ],
      ),
    );
  }

  Widget _badgeEstado(EstadoCita estado) {
    Color bg, fg;
    switch (estado) {
      case EstadoCita.confirmada:
        bg = AppColors.successSurface;
        fg = AppColors.success;
        break;
      case EstadoCita.pendiente:
        bg = AppColors.warningSurface;
        fg = AppColors.warning;
        break;
      case EstadoCita.rechazada:
      case EstadoCita.canceladaPorTutor:
        bg = AppColors.dangerSurface;
        fg = AppColors.danger;
        break;
      case EstadoCita.completada:
        bg = AppColors.primarySurface;
        fg = AppColors.primary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(estado.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _Accion {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color colorFondo;
  final Color colorIcono;
  final VoidCallback onTap;
  _Accion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.colorFondo,
    required this.colorIcono,
    required this.onTap,
  });

  Widget build() {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorFondo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: colorIcono, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
