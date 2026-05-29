import 'package:flutter/foundation.dart';

import '../models/cita.dart';
import '../models/perfil_cuidador.dart';
import '../services/booking_service.dart';
import '../services/profile_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService.instance;
  final ProfileService _profileService = ProfileService.instance;

  List<Cita> _citasTutor = [];
  List<Cita> _solicitudesCuidador = [];
  PerfilCuidador? _perfilCuidador;

  List<Cita> get citasTutor => _citasTutor;
  List<Cita> get solicitudesCuidador => _solicitudesCuidador;

  /// Solicitudes cuyo día y horario son compatibles con la disponibilidad
  /// configurada del cuidador (H7).
  /// Si el perfil no tiene disponibilidad registrada, devuelve todas.
  List<Cita> get solicitudesCompatibles {
    final perfil = _perfilCuidador;
    if (perfil == null || perfil.disponibilidad.isEmpty) {
      return _solicitudesCuidador;
    }
    return _solicitudesCuidador
        .where((c) => _citaEsCompatible(c, perfil))
        .toList();
  }

  /// Consulta pública para que la UI verifique si una cita específica
  /// es compatible con la disponibilidad del cuidador (H7).
  bool esCitaCompatible(Cita cita) =>
      _citaEsCompatible(cita, _perfilCuidador);

  // ── Lógica de compatibilidad ─────────────────────────────────────────────

  static bool _citaEsCompatible(Cita cita, PerfilCuidador? perfil) {
    if (perfil == null || perfil.disponibilidad.isEmpty) return true;
    final diaCita = _weekdayToDiaSemana(cita.fecha.weekday);
    return perfil.disponibilidad.any((bloque) {
      if (bloque.dia != diaCita) return false;
      final citaInicio = _hhmm(cita.horaInicio);
      final citaFin = _hhmm(cita.horaFin);
      final bloqueInicio = _hhmm(bloque.horaInicio);
      final bloqueFin = _hhmm(bloque.horaFin);
      return citaInicio >= bloqueInicio && citaFin <= bloqueFin;
    });
  }

  /// Mapea el weekday de Dart (1=lunes … 7=domingo) a DiaSemana.
  static DiaSemana _weekdayToDiaSemana(int weekday) => switch (weekday) {
        1 => DiaSemana.lunes,
        2 => DiaSemana.martes,
        3 => DiaSemana.miercoles,
        4 => DiaSemana.jueves,
        5 => DiaSemana.viernes,
        6 => DiaSemana.sabado,
        _ => DiaSemana.domingo,
      };

  /// Convierte "HH:mm" a minutos desde medianoche para comparar rangos.
  static int _hhmm(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // ── Getters de citas del Tutor (sin cambios) ─────────────────────────────

  List<Cita> citasProximasTutor() => _citasTutor
      .where((c) =>
          c.fecha.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
          c.estado != EstadoCita.rechazada &&
          c.estado != EstadoCita.canceladaPorTutor)
      .toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));

  List<Cita> citasPasadasTutor() => _citasTutor
      .where((c) =>
          c.fecha.isBefore(DateTime.now()) ||
          c.estado == EstadoCita.completada)
      .toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));

  List<Cita> citasCanceladasTutor() => _citasTutor
      .where((c) =>
          c.estado == EstadoCita.rechazada ||
          c.estado == EstadoCita.canceladaPorTutor)
      .toList();

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> cargarParaTutor(String tutorId) async {
    _citasTutor = await _service.citasDeTutor(tutorId);
    notifyListeners();
  }

  /// Carga solicitudes del cuidador Y su perfil de disponibilidad (H7).
  Future<void> cargarParaCuidador(String cuidadorId) async {
    _solicitudesCuidador = await _service.solicitudesDeCuidador(cuidadorId);
    _perfilCuidador = await _profileService.obtenerPerfilCuidador(cuidadorId);
    notifyListeners();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

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
    final c = await _service.crearCita(
      tutorId: tutorId,
      cuidadorId: cuidadorId,
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      duracionHoras: duracionHoras,
      tipoCuidado: tipoCuidado,
      totalEstimado: totalEstimado,
      hijoId: hijoId,
      notas: notas,
    );
    await cargarParaTutor(tutorId);
    return c;
  }

  Future<void> aceptarSolicitud(String citaId, String cuidadorId) async {
    await _service.actualizarEstado(citaId, EstadoCita.confirmada);
    await cargarParaCuidador(cuidadorId);
  }

  Future<void> rechazarSolicitud(String citaId, String cuidadorId) async {
    await _service.actualizarEstado(citaId, EstadoCita.rechazada);
    await cargarParaCuidador(cuidadorId);
  }

  Future<void> cancelarSolicitudTutor({
    required String citaId,
    required String tutorId,
  }) async {
    await _service.actualizarEstado(citaId, EstadoCita.canceladaPorTutor);
    await cargarParaTutor(tutorId);
  }
}
