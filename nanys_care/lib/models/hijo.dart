/// Información de un hijo o hija del Tutor (RF5).
class Hijo {
  final String id;
  String nombre;
  int edad;
  String? necesidadesEspeciales;

  Hijo({
    required this.id,
    required this.nombre,
    required this.edad,
    this.necesidadesEspeciales,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'edad': edad,
        'necesidadesEspeciales': necesidadesEspeciales,
      };

  factory Hijo.fromJson(Map<String, dynamic> json) => Hijo(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        edad: json['edad'] as int,
        necesidadesEspeciales: json['necesidadesEspeciales'] as String?,
      );
}
