import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Indicador de pasos (los círculos numerados 1-2-3-4 que aparecen
/// en las pantallas de onboarding 02 y 03).
class StepIndicator extends StatelessWidget {
  final int pasoActual; // 1-based
  final int total;
  final List<bool> completados;

  const StepIndicator({
    super.key,
    required this.pasoActual,
    this.total = 4,
    this.completados = const [],
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 1; i <= total; i++) {
      final esActual = i == pasoActual;
      final esCompletado = i < pasoActual ||
          (completados.length >= i && completados[i - 1]);
      children.add(_Circulo(
        numero: i,
        activo: esActual,
        completado: esCompletado,
      ));
      if (i != total) {
        children.add(
          Container(
            width: 24,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: AppColors.border,
          ),
        );
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _Circulo extends StatelessWidget {
  final int numero;
  final bool activo;
  final bool completado;
  const _Circulo({
    required this.numero,
    required this.activo,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Widget contenido;
    if (completado) {
      bg = AppColors.primary;
      fg = Colors.white;
      contenido = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (activo) {
      bg = AppColors.primary;
      fg = Colors.white;
      contenido = Text('$numero',
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w700, fontSize: 13));
    } else {
      bg = AppColors.primarySurface;
      fg = AppColors.primary;
      contenido = Text('$numero',
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w700, fontSize: 13));
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: contenido,
    );
  }
}
