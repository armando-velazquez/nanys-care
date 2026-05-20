import 'hijo.dart';

/// Perfil extendido del Tutor (RF5).
/// Contiene la información sobre los hijos y las necesidades de cuidado.
class PerfilTutor {
  /// ID del Usuario asociado.
  final String usuarioId;
  List<Hijo> hijos;
  String? horariosNecesitados;
  String? frecuencia;
  String? comentariosAdicionales;

  PerfilTutor({
    required this.usuarioId,
    List<Hijo>? hijos,
    this.horariosNecesitados,
    this.frecuencia,
    this.comentariosAdicionales,
  }) : hijos = hijos ?? [];

  bool get estaCompleto => hijos.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'usuarioId': usuarioId,
        'hijos': hijos.map((h) => h.toJson()).toList(),
        'horariosNecesitados': horariosNecesitados,
        'frecuencia': frecuencia,
        'comentariosAdicionales': comentariosAdicionales,
      };

  factory PerfilTutor.fromJson(Map<String, dynamic> json) => PerfilTutor(
        usuarioId: json['usuarioId'] as String,
        hijos: (json['hijos'] as List<dynamic>?)
                ?.map((h) => Hijo.fromJson(h as Map<String, dynamic>))
                .toList() ??
            [],
        horariosNecesitados: json['horariosNecesitados'] as String?,
        frecuencia: json['frecuencia'] as String?,
        comentariosAdicionales: json['comentariosAdicionales'] as String?,
      );
}
