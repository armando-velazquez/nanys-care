import 'package:uuid/uuid.dart';

import '../models/nota_privada.dart';
import 'local_storage_service.dart';

/// Servicio local de notas privadas del Cuidador sobre tutores (H12).
class PrivateNotesService {
  PrivateNotesService._();
  static final PrivateNotesService instance = PrivateNotesService._();

  static const String _archivo = 'notas_privadas';
  final _uuid = const Uuid();
  final _storage = LocalStorageService.instance;

  Future<List<NotaPrivada>> _leer() async {
    final raw = await _storage.leerLista(_archivo);
    return raw.map(NotaPrivada.fromJson).toList();
  }

  Future<void> _guardarTodas(List<NotaPrivada> notas) =>
      _storage.guardarLista(
        _archivo,
        notas.map((n) => n.toJson()).toList(),
      );

  /// Devuelve todas las notas del cuidador ordenadas de más reciente a más antigua.
  Future<List<NotaPrivada>> listarPorCuidador(String cuidadorId) async {
    final notas = await _leer();
    return notas.where((n) => n.cuidadorId == cuidadorId).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  /// Crea o actualiza una nota.
  /// Si se proporciona [notaId] actualiza el texto; de lo contrario crea una nueva.
  Future<NotaPrivada> guardar({
    required String cuidadorId,
    required String tutorId,
    required String tutorNombre,
    required String texto,
    String? notaId,
  }) async {
    final notas = await _leer();

    if (notaId != null) {
      final idx = notas.indexWhere((n) => n.id == notaId);
      if (idx != -1) {
        notas[idx].texto = texto.trim();
        notas[idx].fechaActualizacion = DateTime.now();
        await _guardarTodas(notas);
        return notas[idx];
      }
    }

    final nota = NotaPrivada(
      id: _uuid.v4(),
      cuidadorId: cuidadorId,
      tutorId: tutorId,
      tutorNombre: tutorNombre.trim().isEmpty ? 'Tutor' : tutorNombre.trim(),
      texto: texto.trim(),
      fechaCreacion: DateTime.now(),
    );
    notas.add(nota);
    await _guardarTodas(notas);
    return nota;
  }

  Future<void> eliminar(String notaId) async {
    final notas = await _leer();
    notas.removeWhere((n) => n.id == notaId);
    await _guardarTodas(notas);
  }
}
