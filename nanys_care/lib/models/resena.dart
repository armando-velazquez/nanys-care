/// Reseña que un Tutor deja sobre un servicio recibido de un Cuidador (H11).
class Resena {
  final String id;
  final String citaId;
  final String tutorId;
  final String cuidadorId;
  final String tutorNombre;
  final int calificacion;
  final String comentario;
  final DateTime fechaCreacion;

  Resena({
    required this.id,
    required this.citaId,
    required this.tutorId,
    required this.cuidadorId,
    required this.tutorNombre,
    required this.calificacion,
    required this.comentario,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'citaId': citaId,
        'tutorId': tutorId,
        'cuidadorId': cuidadorId,
        'tutorNombre': tutorNombre,
        'calificacion': calificacion,
        'comentario': comentario,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory Resena.fromJson(Map<String, dynamic> json) => Resena(
        id: json['id'] as String,
        citaId: json['citaId'] as String,
        tutorId: json['tutorId'] as String,
        cuidadorId: json['cuidadorId'] as String,
        tutorNombre: json['tutorNombre'] as String? ?? 'Tutor',
        calificacion: json['calificacion'] as int,
        comentario: json['comentario'] as String,
        fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      );
}
