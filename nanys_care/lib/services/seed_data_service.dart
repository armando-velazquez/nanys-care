import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/perfil_cuidador.dart';
import '../models/usuario.dart';
import 'local_storage_service.dart';

/// Inicializa la base de datos JSON local con datos semilla de Cuidadores
/// cuando la app se ejecuta por primera vez.
///
/// Esto es necesario porque la aplicación no tiene backend: un Tutor que
/// instala la app debe encontrar Cuidadores con los que interactuar para
/// poder probar el flujo de búsqueda (RF6) y reserva (RF8).
class SeedDataService {
  SeedDataService._();
  static final SeedDataService instance = SeedDataService._();

  static const _archivoMarcador = 'seed_aplicado';
  static const _archivoUsuarios = 'usuarios';
  static const _archivoPerfilCuidador = 'perfiles_cuidador';
  static const _rutaAsset = 'assets/data/cuidadores_semilla.json';

  Future<void> aplicarSiEsNecesario() async {
    final storage = LocalStorageService.instance;
    final marcador = await storage.leerObjeto(_archivoMarcador);
    if (marcador != null && marcador['aplicado'] == true) {
      return; // ya se aplicó antes
    }

    final contenido = await rootBundle.loadString(_rutaAsset);
    final lista = jsonDecode(contenido) as List<dynamic>;

    final usuariosExistentes = await storage.leerLista(_archivoUsuarios);
    final perfilesExistentes =
        await storage.leerLista(_archivoPerfilCuidador);

    for (final raw in lista) {
      final mapa = raw as Map<String, dynamic>;
      final perfilJson = mapa['perfil'] as Map<String, dynamic>;
      final usuarioJson = Map<String, dynamic>.from(mapa)..remove('perfil');

      // Validar para no duplicar si el usuario re-ejecuta la primera vez.
      if (!usuariosExistentes
          .any((u) => u['id'] == usuarioJson['id'])) {
        usuariosExistentes.add(usuarioJson);
      }

      perfilJson['usuarioId'] = usuarioJson['id'];
      if (!perfilesExistentes
          .any((p) => p['usuarioId'] == usuarioJson['id'])) {
        perfilesExistentes.add(perfilJson);
      }
    }

    // Validamos que se puedan parsear antes de guardar.
    usuariosExistentes.map(Usuario.fromJson).toList();
    perfilesExistentes.map(PerfilCuidador.fromJson).toList();

    await storage.guardarLista(_archivoUsuarios, usuariosExistentes);
    await storage.guardarLista(_archivoPerfilCuidador, perfilesExistentes);
    await storage.guardarObjeto(_archivoMarcador, {'aplicado': true});
  }
}
