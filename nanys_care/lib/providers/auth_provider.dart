import 'package:flutter/foundation.dart';

import '../models/user_role.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

/// Maneja el estado de autenticación de la aplicación (RF1, RF2).
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _ultimoError;
  String? get ultimoError => _ultimoError;

  /// Restaura la sesión si el usuario ya había iniciado antes.
  Future<void> cargarSesion() async {
    _usuario = await _service.sesionActiva();
    notifyListeners();
  }

  Future<bool> registrar({
    required String nombreCompleto,
    required String correo,
    required String password,
    required UserRole rol,
    String? telefono,
    String? ubicacion,
    String? fotoPath,
  }) async {
    _setCargando(true);
    try {
      _usuario = await _service.registrar(
        nombreCompleto: nombreCompleto,
        correo: correo,
        password: password,
        rol: rol,
        telefono: telefono,
        ubicacion: ubicacion,
        fotoPath: fotoPath,
      );
      _ultimoError = null;
      return true;
    } on AuthException catch (e) {
      _ultimoError = e.mensaje;
      return false;
    } catch (e) {
      _ultimoError = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> iniciarSesion(String correo, String password) async {
    _setCargando(true);
    try {
      _usuario = await _service.iniciarSesion(
        correo: correo,
        password: password,
      );
      _ultimoError = null;
      return true;
    } on AuthException catch (e) {
      _ultimoError = e.mensaje;
      return false;
    } catch (e) {
      _ultimoError = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cerrarSesion() async {
    await _service.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  Future<void> actualizarUsuarioActual(Usuario actualizado) async {
    await _service.actualizarUsuario(actualizado);
    _usuario = actualizado;
    notifyListeners();
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}
