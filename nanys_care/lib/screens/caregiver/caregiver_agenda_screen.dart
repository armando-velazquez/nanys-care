import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
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
                      Icon(Icons.event_busy,
                          color: AppColors.textHint, size: 56),
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

  @override
  Widget build(BuildContext context) {
    final f = DateFormat("EEEE d 'de' MMMM", 'es_MX');
    return Container(
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
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  cita.tipoCuidado,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
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
    );
  }
}
