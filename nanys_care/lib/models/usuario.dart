import 'user_role.dart';

/// Modelo base de usuario para registro y autenticación (RF1, RF2).
class Usuario {
  final String id;
  final String nombreCompleto;
  final String correo;
  final String passwordHash;
  final String? telefono;
  final String? ubicacion;
  final UserRole rol;
  final DateTime fechaRegistro;

  /// Foto de perfil almacenada como ruta absoluta del archivo local.
  final String? fotoPath;

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.passwordHash,
    required this.rol,
    required this.fechaRegistro,
    this.telefono,
    this.ubicacion,
    this.fotoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombreCompleto': nombreCompleto,
        'correo': correo,
        'passwordHash': passwordHash,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'rol': rol.name,
        'fechaRegistro': fechaRegistro.toIso8601String(),
        'fotoPath': fotoPath,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombreCompleto: json['nombreCompleto'] as String,
        correo: json['correo'] as String,
        passwordHash: json['passwordHash'] as String,
        telefono: json['telefono'] as String?,
        ubicacion: json['ubicacion'] as String?,
        rol: UserRole.fromString(json['rol'] as String),
        fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
        fotoPath: json['fotoPath'] as String?,
      );

  Usuario copyWith({
    String? nombreCompleto,
    String? telefono,
    String? ubicacion,
    String? fotoPath,
  }) =>
      Usuario(
        id: id,
        nombreCompleto: nombreCompleto ?? this.nombreCompleto,
        correo: correo,
        passwordHash: passwordHash,
        rol: rol,
        fechaRegistro: fechaRegistro,
        telefono: telefono ?? this.telefono,
        ubicacion: ubicacion ?? this.ubicacion,
        fotoPath: fotoPath ?? this.fotoPath,
      );
}
