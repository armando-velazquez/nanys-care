import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../models/perfil_cuidador.dart';
import '../models/perfil_tutor.dart';
import '../models/user_role.dart';
import '../models/usuario.dart';
import 'local_storage_service.dart';

class AuthException implements Exception {
  final String mensaje;
  AuthException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Servicio de autenticación local (RF1, RF2).
///
/// - Las contraseñas se almacenan únicamente como hash SHA-256 con sal
///   (RNF1 — Seguridad y privacidad).
/// - La sesión activa se persiste en `sesion.json` para evitar pedir
///   login en cada arranque.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _archivoUsuarios = 'usuarios';
  static const String _archivoSesion = 'sesion';
  static const String _archivoPerfilTutor = 'perfiles_tutor';
  static const String _archivoPerfilCuidador = 'perfiles_cuidador';

  final _uuid = const Uuid();
  final _storage = LocalStorageService.instance;

  /// Genera el hash SHA-256 de una contraseña con sal fija por usuario.
  /// (El correo se usa como sal para mantenerlo determinístico sin BD.)
  static String hashPassword(String password, String correo) {
    final salted = '${correo.toLowerCase()}::$password::nanys_care_v1';
    return sha256.convert(utf8.encode(salted)).toString();
  }

  /// Registra un nuevo usuario (RF1).
  /// Lanza [AuthException] si el correo ya está en uso.
  Future<Usuario> registrar({
    required String nombreCompleto,
    required String correo,
    required String password,
    required UserRole rol,
    String? telefono,
    String? ubicacion,
    String? fotoPath,
  }) async {
    final correoLimpio = correo.trim().toLowerCase();
    final usuarios = await _leerUsuarios();

    if (usuarios.any((u) => u.correo.toLowerCase() == correoLimpio)) {
      throw AuthException('Ya existe una cuenta con este correo.');
    }

    final usuario = Usuario(
      id: _uuid.v4(),
      nombreCompleto: nombreCompleto.trim(),
      correo: correoLimpio,
      passwordHash: hashPassword(password, correoLimpio),
      rol: rol,
      fechaRegistro: DateTime.now(),
      telefono: telefono,
      ubicacion: ubicacion,
      fotoPath: fotoPath,
    );

    usuarios.add(usuario);
    await _guardarUsuarios(usuarios);

    // Crear shell de perfil correspondiente
    if (rol == UserRole.tutor) {
      final perfiles = await _leerPerfilesTutor();
      perfiles.add(PerfilTutor(usuarioId: usuario.id));
      await _guardarPerfilesTutor(perfiles);
    } else {
      final perfiles = await _leerPerfilesCuidador();
      perfiles.add(PerfilCuidador(usuarioId: usuario.id));
      await _guardarPerfilesCuidador(perfiles);
    }

    await _guardarSesion(usuario.id);
    return usuario;
  }

  /// Inicia sesión con correo y contraseña (RF2).
  Future<Usuario> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final correoLimpio = correo.trim().toLowerCase();
    final usuarios = await _leerUsuarios();
    final hash = hashPassword(password, correoLimpio);

    Usuario? encontrado;
    for (final u in usuarios) {
      if (u.correo.toLowerCase() == correoLimpio && u.passwordHash == hash) {
        encontrado = u;
        break;
      }
    }

    if (encontrado == null) {
      throw AuthException('Correo o contraseña incorrectos.');
    }

    await _guardarSesion(encontrado.id);
    return encontrado;
  }

  Future<void> cerrarSesion() => _storage.eliminar(_archivoSesion);

  /// Recupera al usuario actualmente autenticado (si lo hay).
  Future<Usuario?> sesionActiva() async {
    final sesion = await _storage.leerObjeto(_archivoSesion);
    if (sesion == null) return null;
    final id = sesion['usuarioId'] as String?;
    if (id == null) return null;
    final usuarios = await _leerUsuarios();
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    final usuarios = await _leerUsuarios();
    final idx = usuarios.indexWhere((u) => u.id == usuario.id);
    if (idx == -1) return;
    usuarios[idx] = usuario;
    await _guardarUsuarios(usuarios);
  }

  // --- Helpers privados de I/O ---

  Future<List<Usuario>> _leerUsuarios() async {
    final raw = await _storage.leerLista(_archivoUsuarios);
    return raw.map(Usuario.fromJson).toList();
  }

  Future<void> _guardarUsuarios(List<Usuario> usuarios) =>
      _storage.guardarLista(
        _archivoUsuarios,
        usuarios.map((u) => u.toJson()).toList(),
      );

  Future<List<PerfilTutor>> _leerPerfilesTutor() async {
    final raw = await _storage.leerLista(_archivoPerfilTutor);
    return raw.map(PerfilTutor.fromJson).toList();
  }

  Future<void> _guardarPerfilesTutor(List<PerfilTutor> perfiles) =>
      _storage.guardarLista(
        _archivoPerfilTutor,
        perfiles.map((p) => p.toJson()).toList(),
      );

  Future<List<PerfilCuidador>> _leerPerfilesCuidador() async {
    final raw = await _storage.leerLista(_archivoPerfilCuidador);
    return raw.map(PerfilCuidador.fromJson).toList();
  }

  Future<void> _guardarPerfilesCuidador(List<PerfilCuidador> perfiles) =>
      _storage.guardarLista(
        _archivoPerfilCuidador,
        perfiles.map((p) => p.toJson()).toList(),
      );

  Future<void> _guardarSesion(String usuarioId) =>
      _storage.guardarObjeto(_archivoSesion, {'usuarioId': usuarioId});
}
