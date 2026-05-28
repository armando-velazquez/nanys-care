import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/caregiver_list_provider.dart';
import '../../providers/review_provider.dart';
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
    await context.read<ReviewProvider>().cargarParaTutor(auth.usuario!.id);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.tutorHome);
          },
        ),
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

class _ResenaFormData {
  final int calificacion;
  final String comentario;

  const _ResenaFormData({
    required this.calificacion,
    required this.comentario,
  });
}

class _TarjetaCita extends StatelessWidget {
  final Cita cita;
  const _TarjetaCita({required this.cita});

  @override
  Widget build(BuildContext context) {
    final caregivers = context.watch<CaregiverListProvider>();
    final booking = context.read<BookingProvider>();
    final auth = context.read<AuthProvider>();
    final reviews = context.watch<ReviewProvider>();
    final entry = caregivers.porId(cita.cuidadorId);
    final nombre = entry?.usuario.nombreCompleto ?? 'Cuidador';
    final formato = DateFormat("EEE, d MMM y", 'es_MX');
    final resena = reviews.resenaPorCita(cita.id);
    final puedeCalificar = _puedeCalificar(cita);

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
                  onPressed: puedeCalificar && resena == null
                      ? () => _mostrarDialogoResena(context, nombre)
                      : puedeCalificar
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mensajería disponible en próximos sprints',
                                  ),
                                ),
                              );
                            },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    puedeCalificar
                        ? (resena == null ? 'Calificar' : 'Reseña enviada')
                        : 'Mensaje',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          if (cita.estado == EstadoCita.pendiente) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Cancelar solicitud'),
                      content: const Text('¿Deseas cancelar esta solicitud?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Sí, cancelar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmar != true || auth.usuario == null) return;
                  await booking.cancelarSolicitudTutor(
                    citaId: cita.id,
                    tutorId: auth.usuario!.id,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud cancelada')),
                    );
                  }
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancelar solicitud'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }


  bool _puedeCalificar(Cita cita) {
    final estaCancelada = cita.estado == EstadoCita.rechazada ||
        cita.estado == EstadoCita.canceladaPorTutor;
    if (estaCancelada) return false;
    return cita.estado == EstadoCita.completada || cita.fecha.isBefore(DateTime.now());
  }

  Future<void> _mostrarDialogoResena(
    BuildContext context,
    String nombreCuidador,
  ) async {
    final comentarioCtrl = TextEditingController();
    var calificacion = 5;

    final envio = await showModalBottomSheet<_ResenaFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const Text(
                    'Califica tu servicio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuidador: $nombreCuidador',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => calificacion = 0),
                        child: Text(
                          '0',
                          style: TextStyle(
                            color: calificacion == 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...List.generate(5, (i) {
                        final valor = i + 1;
                        return IconButton(
                          onPressed: () => setState(() => calificacion = valor),
                          icon: Icon(
                            valor <= calificacion
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        );
                      }),
                    ],
                  ),
                  Center(
                    child: Text(
                      '$calificacion de 5 estrellas',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: comentarioCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Escribe cómo fue tu experiencia...',
                      prefixIcon: Icon(Icons.rate_review_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop(
                              _ResenaFormData(
                                calificacion: calificacion,
                                comentario: comentarioCtrl.text,
                              ),
                            );
                          },
                          child: const Text('Enviar reseña'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    comentarioCtrl.dispose();
    if (envio == null || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final usuario = auth.usuario;
    if (usuario == null) return;

    final reviewProvider = context.read<ReviewProvider>();
    final ok = await reviewProvider.crearResena(
      citaId: cita.id,
      tutorId: usuario.id,
      cuidadorId: cita.cuidadorId,
      tutorNombre: usuario.nombreCompleto,
      calificacion: envio.calificacion,
      comentario: envio.comentario,
    );

    if (!context.mounted) return;
    if (ok) {
      await context.read<CaregiverListProvider>().cargar();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gracias, tu reseña fue enviada.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reviewProvider.ultimoError ?? 'No se pudo guardar la reseña.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
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
