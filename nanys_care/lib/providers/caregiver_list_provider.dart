import 'package:flutter/foundation.dart';

import '../models/perfil_cuidador.dart';
import '../models/usuario.dart';
import '../services/profile_service.dart';

typedef CuidadorEntry = ({Usuario usuario, PerfilCuidador perfil});

/// Filtros aplicables en la pantalla "Buscar Cuidador" (RF6).
class FiltrosBusqueda {
  String? ubicacion;
  double? precioMaximo;
  double? calificacionMinima;
  int? experienciaMinima; // años mínimos
  bool soloDisponibleHoy; // filtro de disponibilidad
  String? textoLibre;

  FiltrosBusqueda({
    this.ubicacion,
    this.precioMaximo,
    this.calificacionMinima,
    this.experienciaMinima,
    this.soloDisponibleHoy = false,
    this.textoLibre,
  });

  bool get vacio =>
      (ubicacion == null || ubicacion!.trim().isEmpty) &&
      precioMaximo == null &&
      calificacionMinima == null &&
      experienciaMinima == null &&
      !soloDisponibleHoy &&
      (textoLibre == null || textoLibre!.trim().isEmpty);
}

/// Estado de la pantalla de búsqueda y de la lista de cuidadores (RF6).
class CaregiverListProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService.instance;

  List<CuidadorEntry> _todos = [];
  FiltrosBusqueda _filtros = FiltrosBusqueda();
  bool _cargando = false;

  List<CuidadorEntry> get todos => _todos;
  FiltrosBusqueda get filtros => _filtros;
  bool get cargando => _cargando;

  List<CuidadorEntry> get filtrados {
    return _todos.where((e) {
      if (_filtros.ubicacion != null && _filtros.ubicacion!.isNotEmpty) {
        final ub = e.usuario.ubicacion?.toLowerCase() ?? '';
        if (!ub.contains(_filtros.ubicacion!.toLowerCase())) return false;
      }
      if (_filtros.precioMaximo != null) {
        if (e.perfil.tarifaPorHora > _filtros.precioMaximo!) return false;
      }
      if (_filtros.calificacionMinima != null) {
        if (e.perfil.calificacionPromedio < _filtros.calificacionMinima!) {
          return false;
        }
      }
      if (_filtros.experienciaMinima != null) {
        if (e.perfil.aniosExperiencia < _filtros.experienciaMinima!) {
          return false;
        }
      }
      if (_filtros.soloDisponibleHoy) {
        final hoy = DateTime.now().weekday; // 1=lunes ... 7=domingo
        final mapaDias = {
          1: 'lunes',
          2: 'martes',
          3: 'miercoles',
          4: 'jueves',
          5: 'viernes',
          6: 'sabado',
          7: 'domingo',
        };
        final nombreHoy = mapaDias[hoy];
        final disponible =
            e.perfil.disponibilidad.any((d) => d.dia.name == nombreHoy);
        if (!disponible) return false;
      }
      if (_filtros.textoLibre != null && _filtros.textoLibre!.isNotEmpty) {
        final texto = _filtros.textoLibre!.toLowerCase();
        final nombre = e.usuario.nombreCompleto.toLowerCase();
        final capacidades =
            e.perfil.capacidades.map((c) => c.toLowerCase()).join(' ');
        if (!nombre.contains(texto) && !capacidades.contains(texto)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort(
        (a, b) =>
            b.perfil.calificacionPromedio.compareTo(a.perfil.calificacionPromedio),
      );
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    _todos = await _service.listarCuidadores();
    _cargando = false;
    notifyListeners();
  }

  void actualizarFiltros(FiltrosBusqueda nuevos) {
    _filtros = nuevos;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtros = FiltrosBusqueda();
    notifyListeners();
  }

  CuidadorEntry? porId(String usuarioId) {
    try {
      return _todos.firstWhere((e) => e.usuario.id == usuarioId);
    } catch (_) {
      return null;
    }
  }
}
