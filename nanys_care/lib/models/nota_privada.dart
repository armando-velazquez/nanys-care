/// Nota privada que un Cuidador registra sobre un Tutor (H12).
/// Solo visible para el Cuidador que la creó.
class NotaPrivada {
  final String id;
  final String cuidadorId;
  final String tutorId;
  final String tutorNombre;
  String texto;
  final DateTime fechaCreacion;
  DateTime? fechaActualizacion;

  NotaPrivada({
    required this.id,
    required this.cuidadorId,
    required this.tutorId,
    required this.tutorNombre,
    required this.texto,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cuidadorId': cuidadorId,
        'tutorId': tutorId,
        'tutorNombre': tutorNombre,
        'texto': texto,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      };

  factory NotaPrivada.fromJson(Map<String, dynamic> json) => NotaPrivada(
        id: json['id'] as String,
        cuidadorId: json['cuidadorId'] as String,
        tutorId: json['tutorId'] as String,
        tutorNombre: json['tutorNombre'] as String? ?? 'Tutor',
        texto: json['texto'] as String,
        fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
        fechaActualizacion: json['fechaActualizacion'] != null
            ? DateTime.parse(json['fechaActualizacion'] as String)
            : null,
      );
}
