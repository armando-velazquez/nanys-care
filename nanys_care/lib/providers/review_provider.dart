import 'package:flutter/foundation.dart';

import '../models/resena.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _service = ReviewService.instance;

  List<Resena> _resenasTutor = [];
  bool _cargando = false;
  String? _ultimoError;

  List<Resena> get resenasTutor => _resenasTutor;
  bool get cargando => _cargando;
  String? get ultimoError => _ultimoError;

  Resena? resenaPorCita(String citaId) {
    try {
      return _resenasTutor.firstWhere((r) => r.citaId == citaId);
    } catch (_) {
      return null;
    }
  }

  Future<void> cargarParaTutor(String tutorId) async {
    _cargando = true;
    _ultimoError = null;
    notifyListeners();
    _resenasTutor = await _service.listarPorTutor(tutorId);
    _cargando = false;
    notifyListeners();
  }

  Future<bool> crearResena({
    required String citaId,
    required String tutorId,
    required String cuidadorId,
    required String tutorNombre,
    required int calificacion,
    required String comentario,
  }) async {
    _cargando = true;
    _ultimoError = null;
    try {
      await _service.crearResena(
        citaId: citaId,
        tutorId: tutorId,
        cuidadorId: cuidadorId,
        tutorNombre: tutorNombre,
        calificacion: calificacion,
        comentario: comentario,
      );
      _resenasTutor = await _service.listarPorTutor(tutorId);
      _cargando = false;
      notifyListeners();
      return true;
    } on ReviewException catch (e) {
      _ultimoError = e.mensaje;
    } catch (_) {
      _ultimoError = 'No se pudo guardar la reseña.';
    }
    _cargando = false;
    notifyListeners();
    return false;
  }
}
