/// Días de la semana para la disponibilidad del Cuidador.
enum DiaSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo;

  String get label => switch (this) {
        DiaSemana.lunes => 'Lunes',
        DiaSemana.martes => 'Martes',
        DiaSemana.miercoles => 'Miércoles',
        DiaSemana.jueves => 'Jueves',
        DiaSemana.viernes => 'Viernes',
        DiaSemana.sabado => 'Sábado',
        DiaSemana.domingo => 'Domingo',
      };

  String get labelCorto => switch (this) {
        DiaSemana.lunes => 'L',
        DiaSemana.martes => 'M',
        DiaSemana.miercoles => 'Mi',
        DiaSemana.jueves => 'J',
        DiaSemana.viernes => 'V',
        DiaSemana.sabado => 'S',
        DiaSemana.domingo => 'D',
      };

  static DiaSemana fromString(String value) =>
      DiaSemana.values.firstWhere((e) => e.name == value);
}

/// Bloque horario en el que el Cuidador está disponible.
class DisponibilidadBloque {
  final DiaSemana dia;
  final String horaInicio; // formato HH:mm
  final String horaFin;

  DisponibilidadBloque({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  Map<String, dynamic> toJson() => {
        'dia': dia.name,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      };

  factory DisponibilidadBloque.fromJson(Map<String, dynamic> json) =>
      DisponibilidadBloque(
        dia: DiaSemana.fromString(json['dia'] as String),
        horaInicio: json['horaInicio'] as String,
        horaFin: json['horaFin'] as String,
      );
}

/// Perfil extendido del Cuidador (RF3, RF4).
class PerfilCuidador {
  final String usuarioId;
  int aniosExperiencia;
  double tarifaPorHora; // en MXN, asociada al nivel (RF4)
  List<String> certificaciones;
  List<String> capacidades; // bebés, niños, tareas, adultos mayores, etc.
  List<DisponibilidadBloque> disponibilidad;
  String? sobreMi;

  /// Métricas calculadas (no se editan a mano).
  double calificacionPromedio;
  int totalResenas;

  PerfilCuidador({
    required this.usuarioId,
    this.aniosExperiencia = 0,
    this.tarifaPorHora = 0,
    List<String>? certificaciones,
    List<String>? capacidades,
    List<DisponibilidadBloque>? disponibilidad,
    this.sobreMi,
    this.calificacionPromedio = 0,
    this.totalResenas = 0,
  })  : certificaciones = certificaciones ?? [],
        capacidades = capacidades ?? [],
        disponibilidad = disponibilidad ?? [];

  Map<String, dynamic> toJson() => {
        'usuarioId': usuarioId,
        'aniosExperiencia': aniosExperiencia,
        'tarifaPorHora': tarifaPorHora,
        'certificaciones': certificaciones,
        'capacidades': capacidades,
        'disponibilidad': disponibilidad.map((d) => d.toJson()).toList(),
        'sobreMi': sobreMi,
        'calificacionPromedio': calificacionPromedio,
        'totalResenas': totalResenas,
      };

  factory PerfilCuidador.fromJson(Map<String, dynamic> json) => PerfilCuidador(
        usuarioId: json['usuarioId'] as String,
        aniosExperiencia: json['aniosExperiencia'] as int? ?? 0,
        tarifaPorHora: (json['tarifaPorHora'] as num?)?.toDouble() ?? 0,
        certificaciones: (json['certificaciones'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        capacidades: (json['capacidades'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        disponibilidad: (json['disponibilidad'] as List<dynamic>?)
                ?.map((d) =>
                    DisponibilidadBloque.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
        sobreMi: json['sobreMi'] as String?,
        calificacionPromedio:
            (json['calificacionPromedio'] as num?)?.toDouble() ?? 0,
        totalResenas: json['totalResenas'] as int? ?? 0,
      );
}
