import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/seed_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos formatos de fecha en español (necesario para intl).
  await initializeDateFormatting('es_MX', null);

  // Aplicamos los datos semilla la primera vez que la app arranca,
  // para que el Tutor pueda encontrar Cuidadores aunque no haya backend.
  await SeedDataService.instance.aplicarSiEsNecesario();

  runApp(const NanysCareApp());
}
