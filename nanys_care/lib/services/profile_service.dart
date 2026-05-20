import '../models/perfil_cuidador.dart';
import '../models/perfil_tutor.dart';
import '../models/usuario.dart';
import 'local_storage_service.dart';

/// Servicio que gestiona los perfiles extendidos de Tutor (RF5)
/// y Cuidador (RF3, RF4).
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const String _archivoPerfilTutor = 'perfiles_tutor';
  static const String _archivoPerfilCuidador = 'perfiles_cuidador';
  static const String _archivoUsuarios = 'usuarios';

  final _storage = LocalStorageService.instance;

  // ---------------- Tutor ----------------

  Future<PerfilTutor?> obtenerPerfilTutor(String usuarioId) async {
    final raw = await _storage.leerLista(_archivoPerfilTutor);
    final perfiles = raw.map(PerfilTutor.fromJson).toList();
    try {
      return perfiles.firstWhere((p) => p.usuarioId == usuarioId);
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarPerfilTutor(PerfilTutor perfil) async {
    final raw = await _storage.leerLista(_archivoPerfilTutor);
    final perfiles = raw.map(PerfilTutor.fromJson).toList();
    final idx = perfiles.indexWhere((p) => p.usuarioId == perfil.usuarioId);
    if (idx == -1) {
      perfiles.add(perfil);
    } else {
      perfiles[idx] = perfil;
    }
    await _storage.guardarLista(
      _archivoPerfilTutor,
      perfiles.map((p) => p.toJson()).toList(),
    );
  }

  // ---------------- Cuidador ----------------

  Future<PerfilCuidador?> obtenerPerfilCuidador(String usuarioId) async {
    final raw = await _storage.leerLista(_archivoPerfilCuidador);
    final perfiles = raw.map(PerfilCuidador.fromJson).toList();
    try {
      return perfiles.firstWhere((p) => p.usuarioId == usuarioId);
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarPerfilCuidador(PerfilCuidador perfil) async {
    final raw = await _storage.leerLista(_archivoPerfilCuidador);
    final perfiles = raw.map(PerfilCuidador.fromJson).toList();
    final idx = perfiles.indexWhere((p) => p.usuarioId == perfil.usuarioId);
    if (idx == -1) {
      perfiles.add(perfil);
    } else {
      perfiles[idx] = perfil;
    }
    await _storage.guardarLista(
      _archivoPerfilCuidador,
      perfiles.map((p) => p.toJson()).toList(),
    );
  }

  /// Devuelve todos los cuidadores junto con sus datos de Usuario
  /// para la pantalla de búsqueda (RF6).
  Future<List<({Usuario usuario, PerfilCuidador perfil})>>
      listarCuidadores() async {
    final rawPerfiles = await _storage.leerLista(_archivoPerfilCuidador);
    final perfiles = rawPerfiles.map(PerfilCuidador.fromJson).toList();

    final rawUsuarios = await _storage.leerLista(_archivoUsuarios);
    final usuarios = rawUsuarios.map(Usuario.fromJson).toList();

    final resultados = <({Usuario usuario, PerfilCuidador perfil})>[];
    for (final p in perfiles) {
      try {
        final u = usuarios.firstWhere((x) => x.id == p.usuarioId);
        resultados.add((usuario: u, perfil: p));
      } catch (_) {
        // perfil sin usuario asociado, lo omitimos
      }
    }
    return resultados;
  }
}
