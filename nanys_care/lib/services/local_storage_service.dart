import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Servicio responsable de leer y escribir archivos JSON en la carpeta
/// privada de la aplicación.
///
/// La implementación cumple con la decisión técnica de NO usar bases de datos:
/// todos los datos se persisten como archivos JSON en
/// `<app_documents>/nanys_care/<archivo>.json`.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _carpetaDatos = 'nanys_care';

  Future<Directory> _carpetaBase() async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/$_carpetaDatos');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }

  Future<File> _archivo(String nombre) async {
    final base = await _carpetaBase();
    return File('${base.path}/$nombre.json');
  }

  /// Lee una lista de objetos desde el archivo indicado.
  /// Si el archivo no existe, devuelve una lista vacía.
  Future<List<Map<String, dynamic>>> leerLista(String nombre) async {
    try {
      final archivo = await _archivo(nombre);
      if (!await archivo.exists()) return [];
      final contenido = await archivo.readAsString();
      if (contenido.trim().isEmpty) return [];
      final data = jsonDecode(contenido) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Reescribe completamente la lista en el archivo indicado.
  Future<void> guardarLista(
    String nombre,
    List<Map<String, dynamic>> datos,
  ) async {
    final archivo = await _archivo(nombre);
    final encoder = const JsonEncoder.withIndent('  ');
    await archivo.writeAsString(encoder.convert(datos), flush: true);
  }

  /// Lee un único objeto. Devuelve null si no existe.
  Future<Map<String, dynamic>?> leerObjeto(String nombre) async {
    try {
      final archivo = await _archivo(nombre);
      if (!await archivo.exists()) return null;
      final contenido = await archivo.readAsString();
      if (contenido.trim().isEmpty) return null;
      return jsonDecode(contenido) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarObjeto(
    String nombre,
    Map<String, dynamic> datos,
  ) async {
    final archivo = await _archivo(nombre);
    final encoder = const JsonEncoder.withIndent('  ');
    await archivo.writeAsString(encoder.convert(datos), flush: true);
  }

  Future<void> eliminar(String nombre) async {
    final archivo = await _archivo(nombre);
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }
}
