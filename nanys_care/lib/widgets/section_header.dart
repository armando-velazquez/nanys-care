import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Encabezado de sección como los que aparecen en los mockups
/// (icono + título a la izquierda, opcional acción a la derecha).
class SectionHeader extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget? trailing;
  final Color colorIcono;

  const SectionHeader({
    super.key,
    required this.icono,
    required this.titulo,
    this.trailing,
    this.colorIcono = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: colorIcono, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
