import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/caregiver_list_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

/// Pantalla 09 - "NCMisReservas_tutor"
/// Lista de reservas del Tutor con pestañas Próximas / Pasadas / Canceladas (RF8).
class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null) return;
    await context.read<CaregiverListProvider>().cargar();
    await context.read<BookingProvider>().cargarParaTutor(auth.usuario!.id);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final proximas = booking.citasProximasTutor();
    final pasadas = booking.citasPasadasTutor();
    final canceladas = booking.citasCanceladasTutor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mis reservas'),
            Text(
              'Consulta y gestiona todas tus citas',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.calendar_today, color: AppColors.primary),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Próximas (${proximas.length})'),
                    Tab(text: 'Pasadas (${pasadas.length})'),
                    Tab(text: 'Canceladas (${canceladas.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _listaCitas(proximas, mensaje: 'No tienes próximas citas'),
                  _listaCitas(pasadas, mensaje: 'Aún no tienes historial'),
                  _listaCitas(canceladas,
                      mensaje: 'No tienes citas canceladas'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Necesitas agendar otra cita?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Encuentra rápidamente al cuidador ideal para tu familia.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.tutorSearch),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40)),
                      child: const Text('Buscar cuidador',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(indexActual: 2),
    );
  }

  Widget _listaCitas(List<Cita> citas, {required String mensaje}) {
    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 12),
            Text(mensaje,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: citas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TarjetaCita(cita: citas[i]),
    );
  }
}

class _TarjetaCita extends StatelessWidget {
  final Cita cita;
  const _TarjetaCita({required this.cita});

  @override
  Widget build(BuildContext context) {
    final caregivers = context.watch<CaregiverListProvider>();
    final entry = caregivers.porId(cita.cuidadorId);
    final nombre = entry?.usuario.nombreCompleto ?? 'Cuidador';
    final formato = DateFormat("EEE, d MMM y", 'es_MX');

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            color: AppColors.primary, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(formato.format(cita.fecha),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '${cita.horaInicio} - ${cita.horaFin} (${cita.duracionHoras}h)',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _badgeEstado(cita.estado),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cita.totalEstimado.toStringAsFixed(0)} MXN',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Detalles disponibles en próximos sprints')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8)),
                  child: const Text('Ver detalles',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Mensajería disponible en próximos sprints')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8)),
                  child: const Text('Mensaje',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
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
