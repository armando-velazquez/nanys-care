import 'package:uuid/uuid.dart';

import '../models/resena.dart';
import 'local_storage_service.dart';
import 'profile_service.dart';

class ReviewException implements Exception {
  final String mensaje;
  ReviewException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Servicio local de reseñas de servicios completados (H11).
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const String _archivo = 'resenas';
  final _uuid = const Uuid();
  final _storage = LocalStorageService.instance;
  final _profileService = ProfileService.instance;

  Future<List<Resena>> _leerResenas() async {
    final raw = await _storage.leerLista(_archivo);
    return raw.map(Resena.fromJson).toList();
  }

  Future<void> _guardarResenas(List<Resena> resenas) => _storage.guardarLista(
        _archivo,
        resenas.map((r) => r.toJson()).toList(),
      );

  Future<List<Resena>> listarPorCuidador(String cuidadorId) async {
    final resenas = await _leerResenas();
    return resenas.where((r) => r.cuidadorId == cuidadorId).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  Future<List<Resena>> listarPorTutor(String tutorId) async {
    final resenas = await _leerResenas();
    return resenas.where((r) => r.tutorId == tutorId).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  Future<Resena?> obtenerPorCita(String citaId) async {
    final resenas = await _leerResenas();
    try {
      return resenas.firstWhere((r) => r.citaId == citaId);
    } catch (_) {
      return null;
    }
  }

  Future<Resena> crearResena({
    required String citaId,
    required String tutorId,
    required String cuidadorId,
    required String tutorNombre,
    required int calificacion,
    required String comentario,
  }) async {
    if (calificacion < 0 || calificacion > 5) {
      throw ReviewException(
        'La calificación debe estar entre 0 y 5 estrellas.',
      );
    }
    if (comentario.trim().length < 3) {
      throw ReviewException('Escribe un comentario de al menos 3 caracteres.');
    }

    final resenas = await _leerResenas();
    if (resenas.any((r) => r.citaId == citaId)) {
      throw ReviewException('Esta reserva ya tiene una reseña registrada.');
    }

    final resena = Resena(
      id: _uuid.v4(),
      citaId: citaId,
      tutorId: tutorId,
      cuidadorId: cuidadorId,
      tutorNombre: tutorNombre.trim().isEmpty ? 'Tutor' : tutorNombre.trim(),
      calificacion: calificacion,
      comentario: comentario.trim(),
      fechaCreacion: DateTime.now(),
    );

    resenas.add(resena);
    await _guardarResenas(resenas);
    await _actualizarMetricasCuidador(cuidadorId, calificacion);
    return resena;
  }

  Future<void> _actualizarMetricasCuidador(
    String cuidadorId,
    int nuevaCalificacion,
  ) async {
    final perfil = await _profileService.obtenerPerfilCuidador(cuidadorId);
    if (perfil == null) return;

    final totalAnterior = perfil.totalResenas;
    final sumaAnterior = perfil.calificacionPromedio * totalAnterior;
    final totalNuevo = totalAnterior + 1;
    perfil.totalResenas = totalNuevo;
    perfil.calificacionPromedio =
        (sumaAnterior + nuevaCalificacion) / totalNuevo;

    await _profileService.guardarPerfilCuidador(perfil);
  }
}
