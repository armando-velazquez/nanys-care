import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../models/hijo.dart';
import '../../models/perfil_tutor.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';

class CaregiverAgendaScreen extends StatefulWidget {
  const CaregiverAgendaScreen({super.key});

  @override
  State<CaregiverAgendaScreen> createState() => _CaregiverAgendaScreenState();
}

class _CaregiverAgendaScreenState extends State<CaregiverAgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null) return;
    await context.read<BookingProvider>().cargarParaCuidador(auth.usuario!.id);
  }

  @override
  Widget build(BuildContext context) {
    final solicitudes = context.watch<BookingProvider>().solicitudesCuidador;
    final agenda = solicitudes
        .where((c) => c.estado == EstadoCita.confirmada)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi agenda'),
      ),
      body: SafeArea(
        child: agenda.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy, color: AppColors.textHint, size: 56),
                      SizedBox(height: 12),
                      Text(
                        'Aún no tienes citas confirmadas.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agenda.length,
                itemBuilder: (_, i) => _AgendaItem(cita: agenda[i]),
              ),
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final Cita cita;
  const _AgendaItem({required this.cita});

  Future<void> _mostrarDetalles(BuildContext context) async {
    final profileService = ProfileService.instance;
    final Usuario? tutor = await profileService.obtenerUsuarioPorId(cita.tutorId);
    final PerfilTutor? perfilTutor =
        await profileService.obtenerPerfilTutor(cita.tutorId);
    Hijo? hijo;
    if (cita.hijoId != null && perfilTutor != null) {
      for (final h in perfilTutor.hijos) {
        if (h.id == cita.hijoId) {
          hijo = h;
          break;
        }
      }
    }

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Text(
                'Detalles del servicio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Tutor', value: tutor?.nombreCompleto ?? 'Sin dato'),
              _InfoRow(label: 'Contacto', value: tutor?.telefono ?? tutor?.correo ?? 'Sin dato'),
              _InfoRow(label: 'Niño/a', value: hijo?.nombre ?? 'Sin dato'),
              _InfoRow(
                label: 'Edad',
                value: hijo != null ? '${hijo.edad} años' : 'Sin dato',
              ),
              if ((hijo?.necesidadesEspeciales ?? '').trim().isNotEmpty)
                _InfoRow(
                  label: 'Necesidades especiales',
                  value: hijo!.necesidadesEspeciales!,
                ),
              _InfoRow(label: 'Servicio', value: cita.tipoCuidado),
              _InfoRow(label: 'Horario', value: '${cita.horaInicio} - ${cita.horaFin}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat("EEEE d 'de' MMMM", 'es_MX');
    return InkWell(
      onTap: () => _mostrarDetalles(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.format(cita.fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cita.horaInicio} - ${cita.horaFin} (${cita.duracionHoras}h)',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    cita.tipoCuidado,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toca para ver detalles',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Text(
              '\$${cita.totalEstimado.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
