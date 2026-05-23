import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/perfil_cuidador.dart';
import '../models/perfil_tutor.dart';
import '../models/usuario.dart';
import 'auth_service.dart';
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
  static const _archivoPerfilTutor = 'perfiles_tutor';
  static const _archivoPerfilCuidador = 'perfiles_cuidador';
  static const _rutaAsset = 'assets/data/cuidadores_semilla.json';

  Future<void> aplicarSiEsNecesario() async {
    final storage = LocalStorageService.instance;
    final marcador = await storage.leerObjeto(_archivoMarcador);
    final yaAplicado = marcador != null && marcador['aplicado'] == true;

    final usuariosExistentes = await storage.leerLista(_archivoUsuarios);
    final perfilesTutorExistentes = await storage.leerLista(_archivoPerfilTutor);
    final perfilesExistentes =
        await storage.leerLista(_archivoPerfilCuidador);

    // La semilla de listado de cuidadores solo se carga una vez.
    if (!yaAplicado) {
      final contenido = await rootBundle.loadString(_rutaAsset);
      final lista = jsonDecode(contenido) as List<dynamic>;

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
    }

    _inyectarUsuariosPrueba(
      usuariosExistentes: usuariosExistentes,
      perfilesTutorExistentes: perfilesTutorExistentes,
      perfilesCuidadorExistentes: perfilesExistentes,
    );

    // Validamos que se puedan parsear antes de guardar.
    usuariosExistentes.map(Usuario.fromJson).toList();
    perfilesTutorExistentes.map(PerfilTutor.fromJson).toList();
    perfilesExistentes.map(PerfilCuidador.fromJson).toList();

    await storage.guardarLista(_archivoUsuarios, usuariosExistentes);
    await storage.guardarLista(_archivoPerfilTutor, perfilesTutorExistentes);
    await storage.guardarLista(_archivoPerfilCuidador, perfilesExistentes);
    await storage.guardarObjeto(_archivoMarcador, {'aplicado': true});
  }

  void _inyectarUsuariosPrueba({
    required List<Map<String, dynamic>> usuariosExistentes,
    required List<Map<String, dynamic>> perfilesTutorExistentes,
    required List<Map<String, dynamic>> perfilesCuidadorExistentes,
  }) {
    const tutorId = 'seed-tutor-sprint1';
    const cuidadorId = 'seed-cuidador-sprint1';
    final fecha = DateTime.utc(2026, 5, 1).toIso8601String();

    final usuarioTutor = {
      'id': tutorId,
      'nombreCompleto': 'Ana López',
      'correo': 'tutor@test.com',
      'passwordHash': AuthService.hashPassword('123456', 'tutor@test.com'),
      'telefono': '614 111 1111',
      'ubicacion': 'Chihuahua',
      'rol': 'tutor',
      'fechaRegistro': fecha,
      'fotoPath': null,
    };

    final usuarioCuidador = {
      'id': cuidadorId,
      'nombreCompleto': 'Sofía Ramírez',
      'correo': 'cuidador@test.com',
      'passwordHash':
          AuthService.hashPassword('123456', 'cuidador@test.com'),
      'telefono': '614 222 2222',
      'ubicacion': 'Chihuahua',
      'rol': 'cuidador',
      'fechaRegistro': fecha,
      'fotoPath': null,
    };

    _agregarSiNoExisteUsuario(usuariosExistentes, usuarioTutor);
    _agregarSiNoExisteUsuario(usuariosExistentes, usuarioCuidador);

    if (!perfilesTutorExistentes.any((p) => p['usuarioId'] == tutorId)) {
      perfilesTutorExistentes.add({'usuarioId': tutorId, 'hijos': []});
    }

    if (!perfilesCuidadorExistentes
        .any((p) => p['usuarioId'] == cuidadorId)) {
      perfilesCuidadorExistentes.add({
        'usuarioId': cuidadorId,
        'aniosExperiencia': 3,
        'tarifaPorHora': 150,
        'certificaciones': ['Primeros auxilios básicos'],
        'capacidades': ['Niños pequeños', 'Apoyo con tareas'],
        'sobreMi': 'Disponibilidad básica en Chihuahua.',
        'calificacionPromedio': 4.8,
        'totalResenas': 8,
        'disponibilidad': [
          {'dia': 'lunes', 'horaInicio': '09:00', 'horaFin': '13:00'},
          {'dia': 'miercoles', 'horaInicio': '09:00', 'horaFin': '13:00'},
          {'dia': 'viernes', 'horaInicio': '16:00', 'horaFin': '20:00'},
        ],
      });
    }
  }

  void _agregarSiNoExisteUsuario(
    List<Map<String, dynamic>> usuarios,
    Map<String, dynamic> nuevoUsuario,
  ) {
    final correoNuevo = (nuevoUsuario['correo'] as String).toLowerCase();
    final yaExiste = usuarios.any(
      (u) => (u['correo'] as String?)?.toLowerCase() == correoNuevo,
    );
    if (!yaExiste) {
      usuarios.add(nuevoUsuario);
    }
  }
}
