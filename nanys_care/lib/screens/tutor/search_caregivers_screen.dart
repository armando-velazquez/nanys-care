import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/caregiver_list_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';

/// Pantalla 06 - "NCBuscarCuidador"
/// Búsqueda y filtrado de cuidadores (RF6, H6, H22).
class SearchCaregiversScreen extends StatefulWidget {
  const SearchCaregiversScreen({super.key});

  @override
  State<SearchCaregiversScreen> createState() => _SearchCaregiversScreenState();
}

class _SearchCaregiversScreenState extends State<SearchCaregiversScreen> {
  final _busquedaCtrl = TextEditingController();
  // H22: debounce — espera 300ms antes de aplicar el filtro de texto
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaregiverListProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String v) {
    // H22: cancela el timer anterior y arranca uno nuevo de 300ms
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = context.read<CaregiverListProvider>();
      provider.actualizarFiltros(
        FiltrosBusqueda(
          ubicacion: provider.filtros.ubicacion,
          precioMaximo: provider.filtros.precioMaximo,
          calificacionMinima: provider.filtros.calificacionMinima,
          experienciaMinima: provider.filtros.experienciaMinima,
          soloDisponibleHoy: provider.filtros.soloDisponibleHoy,
          textoLibre: v.trim().isEmpty ? null : v.trim(),
        ),
      );
    });
  }

  void _abrirFiltros() {
    final provider = context.read<CaregiverListProvider>();
    final filtros = FiltrosBusqueda(
      ubicacion: provider.filtros.ubicacion,
      precioMaximo: provider.filtros.precioMaximo,
      calificacionMinima: provider.filtros.calificacionMinima,
      experienciaMinima: provider.filtros.experienciaMinima,
      soloDisponibleHoy: provider.filtros.soloDisponibleHoy,
      textoLibre: provider.filtros.textoLibre,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FiltrosSheet(
        filtros: filtros,
        onAplicar: (f) => provider.actualizarFiltros(f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverListProvider>();
    final resultados = provider.filtrados;

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
            Text('Buscar Cuidador'),
            Text(
              'Encuentra al cuidador ideal para tu familia',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _abrirFiltros,
            icon: const Icon(Icons.tune, color: AppColors.primary),
            label: const Text('Filtros',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _busquedaCtrl,
                // H22: usa debounce en lugar de actualizar en cada tecla
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o palabra clave...',
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textHint),
                ),
              ),
            ),
            if (!provider.filtros.vacio)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtros activos',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    TextButton.icon(
                      onPressed: () {
                        _busquedaCtrl.clear();
                        provider.limpiarFiltros();
                      },
                      icon: const Icon(Icons.refresh,
                          color: AppColors.primary, size: 18),
                      label: const Text('Limpiar filtros'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${resultados.length} cuidadores encontrados',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                  const Text('Ordenar por: Mejor calificados',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: provider.cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  : resultados.isEmpty
                      ? const _Vacio()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: resultados.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final e = resultados[i];
                            return _TarjetaCuidador(entry: e);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(indexActual: 1),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppColors.textHint, size: 56),
            SizedBox(height: 12),
            Text('No encontramos cuidadores',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: 4),
            Text(
              'Intenta ajustar los filtros para ampliar tu búsqueda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCuidador extends StatelessWidget {
  final CuidadorEntry entry;
  const _TarjetaCuidador({required this.entry});

  @override
  Widget build(BuildContext context) {
    final u = entry.usuario;
    final p = entry.perfil;
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
                  u.nombreCompleto.isNotEmpty
                      ? u.nombreCompleto[0].toUpperCase()
                      : '?',
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
                      u.nombreCompleto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < p.calificacionPromedio.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.calificacionPromedio.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          ' (${p.totalResenas})',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                    if (u.ubicacion != null && u.ubicacion!.isNotEmpty)
                      _filaInfo(
                          Icons.location_on_outlined, u.ubicacion!),
                    _filaInfo(
                      Icons.workspace_premium_outlined,
                      '${p.aniosExperiencia} año${p.aniosExperiencia != 1 ? 's' : ''} de experiencia',
                    ),
                    _filaInfo(
                      Icons.attach_money,
                      '\$${p.tarifaPorHora.toStringAsFixed(0)} MXN / hora',
                    ),
                    if (p.certificaciones.isNotEmpty)
                      _filaInfo(
                        Icons.badge_outlined,
                        p.certificaciones.take(2).join(', '),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(
                    '${AppRoutes.tutorCaregiverDetail}/${u.id}',
                  ),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10)),
                  child: const Text('Ver perfil',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '${AppRoutes.tutorBook}/${u.id}',
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10)),
                  child: const Text('Agendar',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaInfo(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textHint),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet de filtros (RF6).
class _FiltrosSheet extends StatefulWidget {
  final FiltrosBusqueda filtros;
  final void Function(FiltrosBusqueda) onAplicar;
  const _FiltrosSheet({required this.filtros, required this.onAplicar});

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late TextEditingController _ubicacion;
  double _precioMax = 250;
  double _calificacionMin = 0;
  int _experienciaMin = 0;
  bool _soloHoy = false;

  @override
  void initState() {
    super.initState();
    _ubicacion =
        TextEditingController(text: widget.filtros.ubicacion ?? '');
    _precioMax = widget.filtros.precioMaximo ?? 250;
    _calificacionMin = widget.filtros.calificacionMinima ?? 0;
    _experienciaMin = widget.filtros.experienciaMinima ?? 0;
    _soloHoy = widget.filtros.soloDisponibleHoy;
  }

  @override
  void dispose() {
    _ubicacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filtros de búsqueda',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Ubicación',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _ubicacion,
              decoration: const InputDecoration(
                hintText: 'Ej. Chihuahua',
                prefixIcon: Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Solo disponibles hoy',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  Switch(
                    value: _soloHoy,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _soloHoy = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
                'Precio máximo: \$${_precioMax.toStringAsFixed(0)} / hora',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Slider(
              value: _precioMax,
              min: 50,
              max: 500,
              divisions: 18,
              activeColor: AppColors.primary,
              label: '\$${_precioMax.toStringAsFixed(0)}',
              onChanged: (v) => setState(() => _precioMax = v),
            ),
            const SizedBox(height: 4),
            Text('Experiencia mínima: $_experienciaMin años',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Slider(
              value: _experienciaMin.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: AppColors.primary,
              label: '$_experienciaMin años',
              onChanged: (v) =>
                  setState(() => _experienciaMin = v.round()),
            ),
            const SizedBox(height: 4),
            Text(
                'Calificación mínima: ${_calificacionMin.toStringAsFixed(1)} ⭐',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Slider(
              value: _calificacionMin,
              min: 0,
              max: 5,
              divisions: 10,
              activeColor: AppColors.primary,
              label: _calificacionMin.toStringAsFixed(1),
              onChanged: (v) =>
                  setState(() => _calificacionMin = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onAplicar(FiltrosBusqueda());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAplicar(
                        FiltrosBusqueda(
                          ubicacion: _ubicacion.text.trim().isEmpty
                              ? null
                              : _ubicacion.text.trim(),
                          precioMaximo: _precioMax,
                          calificacionMinima: _calificacionMin == 0
                              ? null
                              : _calificacionMin,
                          experienciaMinima: _experienciaMin == 0
                              ? null
                              : _experienciaMin,
                          soloDisponibleHoy: _soloHoy,
                          textoLibre: widget.filtros.textoLibre,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
