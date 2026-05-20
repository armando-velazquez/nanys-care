import 'package:flutter/foundation.dart';

import '../models/cita.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService.instance;

  List<Cita> _citasTutor = [];
  List<Cita> _solicitudesCuidador = [];

  List<Cita> get citasTutor => _citasTutor;
  List<Cita> get solicitudesCuidador => _solicitudesCuidador;

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

  Future<void> cargarParaTutor(String tutorId) async {
    _citasTutor = await _service.citasDeTutor(tutorId);
    notifyListeners();
  }

  Future<void> cargarParaCuidador(String cuidadorId) async {
    _solicitudesCuidador = await _service.solicitudesDeCuidador(cuidadorId);
    notifyListeners();
  }

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
}
