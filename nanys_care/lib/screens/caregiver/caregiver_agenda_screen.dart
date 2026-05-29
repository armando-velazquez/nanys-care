import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cita.dart';
import '../../models/hijo.dart';
import '../../models/nota_privada.dart';
import '../../models/perfil_tutor.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/private_notes_provider.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';

class CaregiverAgendaScreen extends StatefulWidget {
  const CaregiverAgendaScreen({super.key});

  @override
  State<CaregiverAgendaScreen> createState() => _CaregiverAgendaScreenState();
}

class _CaregiverAgendaScreenState extends State<CaregiverAgendaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null) return;
    final id = auth.usuario!.id;
    await context.read<BookingProvider>().cargarParaCuidador(id);
    await context.read<PrivateNotesProvider>().cargar(id);
  }

  @override
  Widget build(BuildContext context) {
    final solicitudes = context.watch<BookingProvider>().solicitudesCuidador;
    final agenda = solicitudes
        .where((c) => c.estado == EstadoCita.confirmada)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final notas = context.watch<PrivateNotesProvider>().notas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi agenda'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.border,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Mis citas (${agenda.length})'),
            Tab(text: 'Notas (${notas.length})'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: [
            // ── Tab 1: Citas confirmadas ──────────────────────────
            agenda.isEmpty
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
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: agenda.length,
                    itemBuilder: (_, i) =>
                        _AgendaItem(cita: agenda[i]),
                  ),

            // ── Tab 2: Notas privadas ─────────────────────────────
            _TabNotas(notas: notas),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Tarjeta de cita con acceso al detalle + notas
// ══════════════════════════════════════════════════════════════════════

class _AgendaItem extends StatelessWidget {
  final Cita cita;
  const _AgendaItem({required this.cita});

  Future<void> _mostrarDetalles(BuildContext context) async {
    final profileService = ProfileService.instance;
    final Usuario? tutor =
        await profileService.obtenerUsuarioPorId(cita.tutorId);
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
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
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                    label: 'Tutor',
                    value: tutor?.nombreCompleto ?? 'Sin dato'),
                _InfoRow(
                    label: 'Contacto',
                    value: tutor?.telefono ??
                        tutor?.correo ??
                        'Sin dato'),
                _InfoRow(
                    label: 'Niño/a',
                    value: hijo?.nombre ?? 'Sin dato'),
                _InfoRow(
                  label: 'Edad',
                  value: hijo != null
                      ? '${hijo.edad} años'
                      : 'Sin dato',
                ),
                if ((hijo?.necesidadesEspeciales ?? '').trim().isNotEmpty)
                  _InfoRow(
                    label: 'Necesidades especiales',
                    value: hijo!.necesidadesEspeciales!,
                  ),
                _InfoRow(
                    label: 'Servicio', value: cita.tipoCuidado),
                _InfoRow(
                    label: 'Horario',
                    value:
                        '${cita.horaInicio} - ${cita.horaFin}'),
                const Divider(height: 24),
                // ── Sección de nota privada (H12) ──────────────
                _NotaSection(
                  cuidadorId: cita.cuidadorId,
                  tutorId: cita.tutorId,
                  tutorNombre: tutor?.nombreCompleto ?? 'Tutor',
                ),
              ],
            ),
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
              child: const Icon(Icons.event_available,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.format(cita.fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cita.horaInicio} - ${cita.horaFin} (${cita.duracionHoras}h)',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                  Text(
                    cita.tipoCuidado,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toca para ver detalles',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.primary),
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

// ══════════════════════════════════════════════════════════════════════
// Sección de nota privada dentro del detalle de cita (H12)
// ══════════════════════════════════════════════════════════════════════

class _NotaSection extends StatefulWidget {
  final String cuidadorId;
  final String tutorId;
  final String tutorNombre;

  const _NotaSection({
    required this.cuidadorId,
    required this.tutorId,
    required this.tutorNombre,
  });

  @override
  State<_NotaSection> createState() => _NotaSectionState();
}

class _NotaSectionState extends State<_NotaSection> {
  final _ctrl = TextEditingController();
  bool _editando = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrivateNotesProvider>();
    final auth = context.read<AuthProvider>();
    final nota = provider.notaPorTutor(widget.tutorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            const Text(
              'Nota privada',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Solo tú la ves',
                style: TextStyle(
                    fontSize: 10, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Modo lectura ──────────────────────────────────────
        if (!_editando && nota == null)
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _editando = true;
              _ctrl.text = '';
            }),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar nota',
                style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36)),
          ),

        if (!_editando && nota != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nota.texto,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _editando = true;
                        _ctrl.text = nota.texto;
                      }),
                      icon: const Icon(Icons.edit_outlined,
                          size: 14),
                      label: const Text('Editar',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await provider.eliminar(
                            nota.id, widget.cuidadorId);
                      },
                      icon: const Icon(Icons.delete_outline,
                          size: 14),
                      label: const Text('Eliminar',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // ── Modo edición ──────────────────────────────────────
        if (_editando) ...[
          TextField(
            controller: _ctrl,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Escribe tu nota aquí...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    setState(() => _editando = false),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final texto = _ctrl.text.trim();
                  if (texto.isEmpty) return;
                  final ok = await provider.guardar(
                    cuidadorId: widget.cuidadorId,
                    tutorId: widget.tutorId,
                    tutorNombre: widget.tutorNombre,
                    texto: texto,
                    notaId: nota?.id,
                  );
                  if (ok && context.mounted) {
                    setState(() => _editando = false);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Tab 2: Lista de todas las notas privadas
// ══════════════════════════════════════════════════════════════════════

class _TabNotas extends StatelessWidget {
  final List<NotaPrivada> notas;
  const _TabNotas({required this.notas});

  @override
  Widget build(BuildContext context) {
    if (notas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notes, color: AppColors.textHint, size: 56),
              SizedBox(height: 12),
              Text(
                'Aún no tienes notas privadas.\nAgrégalas desde el detalle de una cita.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notas.length,
      itemBuilder: (_, i) => _TarjetaNota(nota: notas[i]),
    );
  }
}

class _TarjetaNota extends StatelessWidget {
  final NotaPrivada nota;
  const _TarjetaNota({required this.nota});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PrivateNotesProvider>();
    final auth = context.read<AuthProvider>();
    final f = DateFormat("d MMM y", 'es_MX');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  nota.tutorNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                f.format(nota.fechaActualizacion ?? nota.fechaCreacion),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            nota.texto,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.danger),
                onPressed: () async {
                  final cuidadorId = auth.usuario?.id;
                  if (cuidadorId == null) return;
                  await provider.eliminar(nota.id, cuidadorId);
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.dangerSurface,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Widgets auxiliares
// ══════════════════════════════════════════════════════════════════════

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
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
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
