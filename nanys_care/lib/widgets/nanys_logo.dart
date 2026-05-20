import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Logo de Nanys Care en versión texto.
/// Reemplázame por la imagen oficial cuando el equipo de diseño la entregue.
class NanysLogo extends StatelessWidget {
  final double fontSize;
  final bool conIcono;
  final MainAxisAlignment alignment;

  const NanysLogo({
    super.key,
    this.fontSize = 28,
    this.conIcono = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        if (conIcono) ...[
          _LogoIcono(size: fontSize * 1.1),
          SizedBox(width: fontSize * 0.25),
        ],
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Nanys ',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Care',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoIcono extends StatelessWidget {
  final double size;
  const _LogoIcono({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.favorite_outline,
              size: size, color: AppColors.primary),
          Positioned(
            top: size * 0.25,
            child: Icon(Icons.child_care,
                size: size * 0.55, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
