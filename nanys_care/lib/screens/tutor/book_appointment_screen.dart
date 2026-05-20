import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/hijo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/caregiver_list_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../services/booking_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

/// Pantalla 08 - "NCAgendarCita"
/// Reserva de una cita de cuidado (RF8, H8).
class BookAppointmentScreen extends StatefulWidget {
  final String cuidadorId;
  const BookAppointmentScreen({super.key, required this.cuidadorId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  DateTime _mesEnfocado = DateTime.now();
  String? _horaSeleccionada;
  int _duracion = 4;
  Hijo? _hijoSeleccionado;
  String _tipoCuidado = 'Cuidado ocasional';
  final _notasCtrl = TextEditingController();

  static const _horasDisponibles = [
    '07:00 AM',
    '09:00 AM',
    '11:00 AM',
    '01:00 PM',
    '03:00 PM',
    '05:00 PM',
    '07:00 PM',
  ];

  static const _tiposCuidado = [
    'Cuidado ocasional',
    'Cuidado recurrente',
    'Tiempo completo',
    'Emergencia',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.usuario != null) {
        context.read<ProfileProvider>().cargarPerfilTutor(auth.usuario!.id);
      }
    });
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona una hora'),
            backgroundColor: AppColors.danger),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final booking = context.read<BookingProvider>();
    final caregivers = context.read<CaregiverListProvider>();
    final entry = caregivers.porId(widget.cuidadorId);
    if (entry == null || auth.usuario == null) return;

    final tarifa = entry.perfil.tarifaPorHora;
    final total = tarifa * _duracion;
    final inicio = _convertirA24(_horaSeleccionada!);
    final fin = _sumarHoras(inicio, _duracion);

    try {
      await booking.crearCita(
        tutorId: auth.usuario!.id,
        cuidadorId: widget.cuidadorId,
        fecha: _fechaSeleccionada,
        horaInicio: inicio,
        horaFin: fin,
        duracionHoras: _duracion,
        tipoCuidado: _tipoCuidado,
        totalEstimado: total,
        hijoId: _hijoSeleccionado?.id,
        notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      );
    } on BookingException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensaje),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo crear la cita: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Solicitud enviada'),
          ],
        ),
        content: const Text(
          'Tu solicitud fue enviada al cuidador. Te avisaremos cuando responda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go(AppRoutes.tutorReservations);
  }

  @override
  Widget build(BuildContext context) {
    final caregivers = context.watch<CaregiverListProvider>();
    final entry = caregivers.porId(widget.cuidadorId);
    final profile = context.watch<ProfileProvider>();
    final hijos = profile.perfilTutor?.hijos ?? [];

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: Text('Cuidador no encontrado',
                style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final u = entry.usuario;
    final p = entry.perfil;
    final total = p.tarifaPorHora * _duracion;
    final formatoFecha = DateFormat("EEEE, d 'de' MMMM y", 'es_MX');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Agendar cita'),
            Text(
              'Selecciona fecha, hora y detalles',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.favorite_outline, color: AppColors.primary),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(
                        u.nombreCompleto[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 22),
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
                                child: Text(u.nombreCompleto,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: AppColors.primary, size: 16),
                            ],
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                  5,
                                  (i) => Icon(
                                        i < p.calificacionPromedio.floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: AppColors.primary,
                                        size: 14,
                                      )),
                              const SizedBox(width: 4),
                              Text(
                                '${p.calificacionPromedio.toStringAsFixed(1)} (${p.totalResenas} reseñas)',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Text(
                            '${p.aniosExperiencia} años exp. · ${u.ubicacion ?? "—"}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('1. Selecciona fecha y hora',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _calendario(),
              const SizedBox(height: 8),
              const Text('Horas disponibles',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _horasDisponibles.map((h) {
                  final sel = _horaSeleccionada == h;
                  return GestureDetector(
                    onTap: () => setState(() => _horaSeleccionada = h),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        h,
                        style: TextStyle(
                          color:
                              sel ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('2. Detalles del cuidado',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _detallesCuidado(hijos),
              const SizedBox(height: 20),
              const Text('3. Resumen',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _resumen(u.nombreCompleto, total, formatoFecha),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El pago se realiza de forma segura dentro de la app.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmar,
                child: const Text('Continuar y confirmar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(indexActual: 2),
    );
  }

  Widget _calendario() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 1)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _mesEnfocado,
        locale: 'es_MX',
        selectedDayPredicate: (d) => isSameDay(d, _fechaSeleccionada),
        onDaySelected: (d, f) {
          setState(() {
            _fechaSeleccionada = d;
            _mesEnfocado = f;
          });
        },
        onPageChanged: (f) => _mesEnfocado = f,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.25),
              shape: BoxShape.circle),
          weekendTextStyle: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _detallesCuidado(List<Hijo> hijos) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _dropdownHijo(hijos)),
              const SizedBox(width: 8),
              Expanded(child: _dropdownDuracion()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _dropdownTipo()),
              const SizedBox(width: 8),
              Expanded(child: _campoNotas()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdownHijo(List<Hijo> hijos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.child_care, color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Text('Niño/a',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<Hijo>(
          value: _hijoSeleccionado,
          isExpanded: true,
          hint: const Text('Seleccionar'),
          items: hijos
              .map((h) => DropdownMenuItem(
                  value: h,
                  child: Text('${h.nombre} (${h.edad} años)',
                      overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _hijoSeleccionado = v),
        ),
      ],
    );
  }

  Widget _dropdownDuracion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.schedule, color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Text('Duración',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: _duracion,
          isExpanded: true,
          items: const [1, 2, 3, 4, 5, 6, 7, 8]
              .map((h) =>
                  DropdownMenuItem(value: h, child: Text('$h horas')))
              .toList(),
          onChanged: (v) => setState(() => _duracion = v ?? 4),
        ),
      ],
    );
  }

  Widget _dropdownTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.list_alt, color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Text('Tipo de cuidado',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _tipoCuidado,
          isExpanded: true,
          items: _tiposCuidado
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _tipoCuidado = v ?? _tipoCuidado),
        ),
      ],
    );
  }

  Widget _campoNotas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.note_alt_outlined,
                color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Expanded(
              child: Text('Notas (opcional)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _notasCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Ej. detalles importantes...',
          ),
        ),
      ],
    );
  }

  Widget _resumen(
      String nombreCuidador, double total, DateFormat formatoFecha) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _filaResumen(Icons.calendar_today_outlined, 'Fecha',
                    formatoFecha.format(_fechaSeleccionada)),
              ),
              Expanded(
                child: _filaResumen(Icons.access_time, 'Hora',
                    '${_horaSeleccionada ?? "—"} ($_duracion h)'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _filaResumen(
                    Icons.child_care,
                    'Niño/a',
                    _hijoSeleccionado == null
                        ? 'Sin seleccionar'
                        : '${_hijoSeleccionado!.nombre} (${_hijoSeleccionado!.edad} años)'),
              ),
              Expanded(
                child: _filaResumen(
                    Icons.person, 'Cuidador', nombreCuidador),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total estimado',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(
                '\$${total.toStringAsFixed(0)} MXN',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(IconData icono, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: AppColors.primary, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  String _convertirA24(String hora12) {
    final partes = hora12.split(' ');
    final hm = partes[0].split(':');
    var h = int.parse(hm[0]);
    final m = hm[1];
    final pm = partes[1] == 'PM';
    if (pm && h != 12) h += 12;
    if (!pm && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  String _sumarHoras(String hhmm, int horas) {
    final hm = hhmm.split(':');
    var h = (int.parse(hm[0]) + horas) % 24;
    return '${h.toString().padLeft(2, '0')}:${hm[1]}';
  }
}
