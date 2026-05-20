import 'package:uuid/uuid.dart';

import '../models/cita.dart';
import 'local_storage_service.dart';

/// Excepción para reglas de negocio del módulo de citas.
class BookingException implements Exception {
  final String mensaje;
  BookingException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Servicio que gestiona la creación y actualización de citas (RF8, RF10).
class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  static const String _archivo = 'citas';
  final _uuid = const Uuid();
  final _storage = LocalStorageService.instance;

  Future<List<Cita>> _leerCitas() async {
    final raw = await _storage.leerLista(_archivo);
    return raw.map(Cita.fromJson).toList();
  }

  Future<void> _guardarCitas(List<Cita> citas) => _storage.guardarLista(
        _archivo,
        citas.map((c) => c.toJson()).toList(),
      );

  /// Crea una nueva cita en estado pendiente (RF8).
  /// Lanza [BookingException] si ya existe una cita activa en el mismo
  /// horario para el mismo cuidador.
  Future<Cita> crearCita({
    required String tutorId,
    required String cuidadorId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required int duracionHoras,
    required String tipoCuidado,
    required double totalEstimado,
    String? hijoId,
    String? notas,
  }) async {
    final citas = await _leerCitas();

    // Validación de duplicados: misma fecha + hora + cuidador, en estado activo.
    final duplicada = citas.any((c) =>
        c.cuidadorId == cuidadorId &&
        c.fecha.year == fecha.year &&
        c.fecha.month == fecha.month &&
        c.fecha.day == fecha.day &&
        c.horaInicio == horaInicio &&
        c.estado != EstadoCita.rechazada &&
        c.estado != EstadoCita.canceladaPorTutor);

    if (duplicada) {
      throw BookingException(
        'Ya tienes una cita con este cuidador en ese horario.',
      );
    }

    final cita = Cita(
      id: _uuid.v4(),
      tutorId: tutorId,
      cuidadorId: cuidadorId,
      hijoId: hijoId,
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      duracionHoras: duracionHoras,
      tipoCuidado: tipoCuidado,
      notas: notas,
      totalEstimado: totalEstimado,
      fechaCreacion: DateTime.now(),
      estado: EstadoCita.pendiente,
    );

    citas.add(cita);
    await _guardarCitas(citas);
    return cita;
  }

  /// Lista todas las citas de un Tutor (RF8 - "Mis reservas").
  Future<List<Cita>> citasDeTutor(String tutorId) async {
    final citas = await _leerCitas();
    return citas.where((c) => c.tutorId == tutorId).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  /// Lista las solicitudes recibidas por un Cuidador (RF10).
  Future<List<Cita>> solicitudesDeCuidador(String cuidadorId) async {
    final citas = await _leerCitas();
    return citas.where((c) => c.cuidadorId == cuidadorId).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  /// Acepta o rechaza una cita (RF10).
  Future<void> actualizarEstado(String citaId, EstadoCita nuevo) async {
    final citas = await _leerCitas();
    final idx = citas.indexWhere((c) => c.id == citaId);
    if (idx == -1) return;
    citas[idx].estado = nuevo;
    citas[idx].fechaActualizacion = DateTime.now();
    await _guardarCitas(citas);
  }
}
