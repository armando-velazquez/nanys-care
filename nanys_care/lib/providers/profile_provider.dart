import 'package:flutter/foundation.dart';

import '../models/perfil_cuidador.dart';
import '../models/perfil_tutor.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService.instance;

  PerfilTutor? _perfilTutor;
  PerfilTutor? get perfilTutor => _perfilTutor;

  PerfilCuidador? _perfilCuidador;
  PerfilCuidador? get perfilCuidador => _perfilCuidador;

  Future<void> cargarPerfilTutor(String usuarioId) async {
    _perfilTutor = await _service.obtenerPerfilTutor(usuarioId);
    notifyListeners();
  }

  Future<void> cargarPerfilCuidador(String usuarioId) async {
    _perfilCuidador = await _service.obtenerPerfilCuidador(usuarioId);
    notifyListeners();
  }

  Future<void> guardarPerfilTutor(PerfilTutor perfil) async {
    await _service.guardarPerfilTutor(perfil);
    _perfilTutor = perfil;
    notifyListeners();
  }

  Future<void> guardarPerfilCuidador(PerfilCuidador perfil) async {
    await _service.guardarPerfilCuidador(perfil);
    _perfilCuidador = perfil;
    notifyListeners();
  }

  void limpiar() {
    _perfilTutor = null;
    _perfilCuidador = null;
    notifyListeners();
  }
}
