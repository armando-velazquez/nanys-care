/// Rol del usuario dentro de Nanys Care.
/// El sistema distingue dos roles principales (ver actores 2.4 del SRS).
enum UserRole {
  tutor,
  cuidador;

  String get label => switch (this) {
        UserRole.tutor => 'Tutor',
        UserRole.cuidador => 'Cuidador',
      };

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.tutor,
    );
  }
}
