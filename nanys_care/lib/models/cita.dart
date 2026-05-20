/// Estado actual de una cita (RF8, RF10).
enum EstadoCita {
  pendiente,
  confirmada,
  rechazada,
  completada,
  canceladaPorTutor;

  String get label => switch (this) {
        EstadoCita.pendiente => 'Pendiente',
        EstadoCita.confirmada => 'Confirmada',
        EstadoCita.rechazada => 'Rechazada',
        EstadoCita.completada => 'Completada',
        EstadoCita.canceladaPorTutor => 'Cancelada por el tutor',
      };

  static EstadoCita fromString(String value) =>
      EstadoCita.values.firstWhere(
        (e) => e.name == value,
        orElse: () => EstadoCita.pendiente,
      );
}

/// Solicitud de servicio agendada por un Tutor a un Cuidador (RF8, RF10).
class Cita {
  final String id;
  final String tutorId;
  final String cuidadorId;

  /// Hijo del Tutor que recibirá el cuidado.
  final String? hijoId;
  final DateTime fecha;
  final String horaInicio; // HH:mm
  final String horaFin;
  final int duracionHoras;
  final String tipoCuidado; // ej. Cuidado ocasional, recurrente
  final String? notas;
  final double totalEstimado;
  EstadoCita estado;
  final DateTime fechaCreacion;
  DateTime? fechaActualizacion;

  Cita({
    required this.id,
    required this.tutorId,
    required this.cuidadorId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionHoras,
    required this.tipoCuidado,
    required this.totalEstimado,
    required this.fechaCreacion,
    this.hijoId,
    this.notas,
    this.estado = EstadoCita.pendiente,
    this.fechaActualizacion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tutorId': tutorId,
        'cuidadorId': cuidadorId,
        'hijoId': hijoId,
        'fecha': fecha.toIso8601String(),
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'duracionHoras': duracionHoras,
        'tipoCuidado': tipoCuidado,
        'notas': notas,
        'totalEstimado': totalEstimado,
        'estado': estado.name,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      };

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        id: json['id'] as String,
        tutorId: json['tutorId'] as String,
        cuidadorId: json['cuidadorId'] as String,
        hijoId: json['hijoId'] as String?,
        fecha: DateTime.parse(json['fecha'] as String),
        horaInicio: json['horaInicio'] as String,
        horaFin: json['horaFin'] as String,
        duracionHoras: json['duracionHoras'] as int,
        tipoCuidado: json['tipoCuidado'] as String,
        notas: json['notas'] as String?,
        totalEstimado: (json['totalEstimado'] as num).toDouble(),
        estado: EstadoCita.fromString(json['estado'] as String),
        fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
        fechaActualizacion: json['fechaActualizacion'] != null
            ? DateTime.parse(json['fechaActualizacion'] as String)
            : null,
      );
}
