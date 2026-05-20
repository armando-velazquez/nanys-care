import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/nanys_logo.dart';

/// Pantalla 14 - "NCSolicitudDeCuidado"
/// Gestión de solicitudes de cuidado por parte del Cuidador (RF10, H10).
class CareRequestsScreen extends StatefulWidget {
  const CareRequestsScreen({super.key});

  @override
  State<CareRequestsScreen> createState() => _CareRequestsScreenState();
}

class _CareRequestsScreenState extends State<CareRequestsScreen> {
  String _tab = 'todas';

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
    final booking = context.watch<BookingProvider>();
    final todas = booking.solicitudesCuidador;
    final nuevas =
        todas.where((c) => c.estado == EstadoCita.pendiente).toList();
    final aceptadas =
        todas.where((c) => c.estado == EstadoCita.confirmada).toList();
    final enRevision = <Cita>[]; // estado intermedio futuro

    final mostradas = switch (_tab) {
      'nuevas' => nuevas,
      'revision' => enRevision,
      'aceptadas' => aceptadas,
      _ => todas,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primary),
                    onPressed: () => context.pop(),
                  ),
                  const NanysLogo(fontSize: 20),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.primary),
                        onPressed: () {},
                      ),
                      if (nuevas.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle),
                            child: Text('${nuevas.length}',
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solicitudes de cuidado',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Revisa y acepta las oportunidades que mejor se adapten a ti',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ChipTab(
                          label: 'Todas (${todas.length})',
                          activo: _tab == 'todas',
                          onTap: () => setState(() => _tab = 'todas'),
                        ),
                        const SizedBox(width: 6),
                        _ChipTab(
                          label: 'Nuevas (${nuevas.length})',
                          activo: _tab == 'nuevas',
                          onTap: () => setState(() => _tab = 'nuevas'),
                        ),
                        const SizedBox(width: 6),
                        _ChipTab(
                          label: 'En revisión (${enRevision.length})',
                          activo: _tab == 'revision',
                          onTap: () => setState(() => _tab = 'revision'),
                        ),
                        const SizedBox(width: 6),
                        _ChipTab(
                          label: 'Aceptadas (${aceptadas.length})',
                          activo: _tab == 'aceptadas',
                          onTap: () => setState(() => _tab = 'aceptadas'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: mostradas.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                color: AppColors.textHint, size: 56),
                            SizedBox(height: 12),
                            Text('No hay solicitudes en esta categoría',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: mostradas.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _TarjetaSolicitud(cita: mostradas[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.tips_and_updates_outlined,
                        color: AppColors.accent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Consejo: Mantén tu perfil actualizado y responde rápido para recibir más solicitudes.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CaregiverBottomNav(indexActual: 1),
    );
  }
}

class _ChipTab extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _ChipTab(
      {required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: activo ? Colors.white : AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  final Cita cita;
  const _TarjetaSolicitud({required this.cita});

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat("d MMM y", 'es_MX');
    final esNueva = cita.estado == EstadoCita.pendiente;
    final esAceptada = cita.estado == EstadoCita.confirmada;
    final esRechazada = cita.estado == EstadoCita.rechazada;
    final auth = context.read<AuthProvider>();
    final booking = context.read<BookingProvider>();

    String etiqueta;
    Color etiquetaBg;
    Color etiquetaFg;
    if (esNueva) {
      etiqueta = 'NUEVA';
      etiquetaBg = AppColors.dangerSurface;
      etiquetaFg = AppColors.danger;
    } else if (esAceptada) {
      etiqueta = 'ACEPTADA';
      etiquetaBg = AppColors.successSurface;
      etiquetaFg = AppColors.success;
    } else if (esRechazada) {
      etiqueta = 'RECHAZADA';
      etiquetaBg = AppColors.dangerSurface;
      etiquetaFg = AppColors.danger;
    } else {
      etiqueta = cita.estado.label.toUpperCase();
      etiquetaBg = AppColors.primarySurface;
      etiquetaFg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: etiquetaBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(etiqueta,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: etiquetaFg,
                )),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primarySurface,
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solicitud de ${cita.tipoCuidado}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    if (cita.notas != null)
                      Text(cita.notas!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
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
                  Text(
                    '\$${(cita.totalEstimado / cita.duracionHoras).toStringAsFixed(0)} MXN/h',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: \$${cita.totalEstimado.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary),
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
                  onPressed: () => _verDetalles(context),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 38)),
                  child: const Text('Ver detalles',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
              if (esNueva) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await booking.aceptarSolicitud(
                          cita.id, auth.usuario!.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Solicitud aceptada'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 38)),
                    child: const Text('Aceptar',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    await booking.rechazarSolicitud(
                        cita.id, auth.usuario!.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solicitud rechazada')),
                      );
                    }
                  },
                  icon: const Icon(Icons.close, color: AppColors.danger),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.dangerSurface,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _verDetalles(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalles de la solicitud',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _detalleLinea('Tipo de cuidado', cita.tipoCuidado),
            _detalleLinea('Fecha',
                DateFormat('EEE, d MMM y', 'es_MX').format(cita.fecha)),
            _detalleLinea('Horario',
                '${cita.horaInicio} - ${cita.horaFin} (${cita.duracionHoras}h)'),
            _detalleLinea(
                'Total estimado', '\$${cita.totalEstimado.toStringAsFixed(0)} MXN'),
            if (cita.notas != null)
              _detalleLinea('Notas', cita.notas!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detalleLinea(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(valor,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
