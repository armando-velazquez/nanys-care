import 'package:flutter/foundation.dart';

import '../models/nota_privada.dart';
import '../services/private_notes_service.dart';

/// Provider de notas privadas del Cuidador (H12).
class PrivateNotesProvider extends ChangeNotifier {
  final PrivateNotesService _service = PrivateNotesService.instance;

  List<NotaPrivada> _notas = [];
  bool _cargando = false;
  String? _ultimoError;

  List<NotaPrivada> get notas => _notas;
  bool get cargando => _cargando;
  String? get ultimoError => _ultimoError;

  /// Devuelve la nota del cuidador sobre un tutor específico, o null si no existe.
  NotaPrivada? notaPorTutor(String tutorId) {
    try {
      return _notas.firstWhere((n) => n.tutorId == tutorId);
    } catch (_) {
      return null;
    }
  }

  Future<void> cargar(String cuidadorId) async {
    _cargando = true;
    notifyListeners();
    _notas = await _service.listarPorCuidador(cuidadorId);
    _cargando = false;
    notifyListeners();
  }

  Future<bool> guardar({
    required String cuidadorId,
    required String tutorId,
    required String tutorNombre,
    required String texto,
    String? notaId,
  }) async {
    _ultimoError = null;
    try {
      await _service.guardar(
        cuidadorId: cuidadorId,
        tutorId: tutorId,
        tutorNombre: tutorNombre,
        texto: texto,
        notaId: notaId,
      );
      _notas = await _service.listarPorCuidador(cuidadorId);
      notifyListeners();
      return true;
    } catch (_) {
      _ultimoError = 'No se pudo guardar la nota.';
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminar(String notaId, String cuidadorId) async {
    await _service.eliminar(notaId);
    _notas = await _service.listarPorCuidador(cuidadorId);
    notifyListeners();
  }
}
