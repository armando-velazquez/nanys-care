import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/perfil_cuidador.dart';
import '../../providers/caregiver_list_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

/// Pantalla 07 - "NCPerfildelCuidador_vista_tutor"
/// Detalle del Cuidador desde el punto de vista del Tutor (RF6).
class CaregiverDetailScreen extends StatelessWidget {
  final String cuidadorId;
  const CaregiverDetailScreen({super.key, required this.cuidadorId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverListProvider>();
    final entry = provider.porId(cuidadorId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Cuidador no encontrado',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final u = entry.usuario;
    final p = entry.perfil;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Perfil del Cuidador'),
        actions: const [
          Icon(Icons.favorite_outline, color: AppColors.primary),
          SizedBox(width: 12),
          Icon(Icons.share_outlined, color: AppColors.primary),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          u.nombreCompleto[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 32),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                u.nombreCompleto,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < p.calificacionPromedio.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.primary,
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '${p.calificacionPromedio.toStringAsFixed(1)} (${p.totalResenas} reseñas)',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.textHint),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(u.ubicacion ?? '—',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _chipEstado('Disponible hoy', AppColors.successSurface,
                      AppColors.success),
                  const SizedBox(width: 6),
                  _chipEstado('Tiempo completo', AppColors.primarySurface,
                      AppColors.primary),
                ],
              ),
              const SizedBox(height: 16),
              if (p.sobreMi != null) ...[
                _bloqueSobreMi(p),
                const SizedBox(height: 16),
              ],
              _gridCualidades(p),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _tarjetaTarifa(p)),
                  const SizedBox(width: 12),
                  Expanded(child: _tarjetaDisponibilidad(p)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text('Reseñas destacadas',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        Text('Ver todas',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (p.totalResenas == 0)
                      const Text(
                        'Este cuidador todavía no tiene reseñas.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      const _ResenaDemo(),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Mensajería disponible en próximos sprints')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Enviar mensaje'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .push('${AppRoutes.tutorBook}/${u.id}'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Agendar cita'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(indexActual: 1),
    );
  }

  Widget _chipEstado(String texto, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _bloqueSobreMi(PerfilCuidador p) {
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
            children: const [
              Icon(Icons.person, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Sobre mí',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(p.sobreMi!,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _gridCualidades(PerfilCuidador p) {
    final items = [
      _Cualidad(Icons.work_outline, 'Experiencia',
          '${p.aniosExperiencia} años'),
      _Cualidad(Icons.child_care_outlined, 'Edades que cuida',
          p.capacidades.isEmpty ? '0 - 12 años' : '0 - 12 años'),
      _Cualidad(
          Icons.workspace_premium_outlined,
          'Certificaciones',
          p.certificaciones.isEmpty
              ? 'Sin certificaciones'
              : p.certificaciones.first),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: items
            .map((it) => Expanded(
                  child: Column(
                    children: [
                      Icon(it.icono, color: AppColors.primary, size: 24),
                      const SizedBox(height: 6),
                      Text(it.titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(it.valor,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _tarjetaTarifa(PerfilCuidador p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Tarifa por hora',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_money,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$${p.tarifaPorHora.toStringAsFixed(0)} MXN',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          const Text('Tarifa adicional',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const Text(
            '+ \$20 MXN / hora extra',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaDisponibilidad(PerfilCuidador p) {
    final dias = p.disponibilidad;
    final tieneLunVie = dias
        .any((d) => d.dia.name == 'lunes' || d.dia.name == 'viernes');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Disponibilidad',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success)),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (dias.isEmpty)
            const Text('Por confirmar',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary))
          else ...[
            _filaDispo(
              tieneLunVie ? 'Lunes a Viernes' : dias.first.dia.label,
              '${dias.first.horaInicio} - ${dias.first.horaFin}',
            ),
            if (dias.any((d) => d.dia.name == 'sabado'))
              _filaDispo(
                'Sábados',
                _rangoPorDia(p, 'sabado'),
              ),
            if (!dias.any((d) => d.dia.name == 'domingo'))
              _filaDispo('Domingos', 'No disponible',
                  color: AppColors.danger),
          ],
        ],
      ),
    );
  }

  String _rangoPorDia(PerfilCuidador p, String dia) {
    final encontrado = p.disponibilidad
        .where((d) => d.dia.name == dia)
        .toList();
    if (encontrado.isEmpty) return '—';
    final d = encontrado.first;
    return '${d.horaInicio} - ${d.horaFin}';
  }

  Widget _filaDispo(String dia, String rango, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            color == AppColors.danger
                ? Icons.cancel_outlined
                : Icons.check_circle_outline,
            size: 14,
            color: color ?? AppColors.success,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dia,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(rango,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cualidad {
  final IconData icono;
  final String titulo;
  final String valor;
  _Cualidad(this.icono, this.titulo, this.valor);
}

class _ResenaDemo extends StatelessWidget {
  const _ResenaDemo();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.accentSurface,
          child: const Text('A',
              style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Ana G.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 6),
                  ...List.generate(
                      5,
                      (i) => const Icon(Icons.star,
                          color: AppColors.primary, size: 14)),
                  const SizedBox(width: 4),
                  const Text('5.0',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  const Spacer(),
                  const Text('Hace 2 semanas',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Mis hijos la adoran. Es puntual, atenta y muy cariñosa. ¡Totalmente recomendada!',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
