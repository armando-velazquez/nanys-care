import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Campo de texto reutilizable con icono a la izquierda, sufijo opcional
/// y validación integrada con FormField.
class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final IconData? icono;
  final TextEditingController controller;
  final bool obscure;
  final bool toggleableObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.label,
    this.icono,
    this.obscure = false,
    this.toggleableObscure = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffix = widget.suffix;
    if (widget.toggleableObscure) {
      suffix = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textHint,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icono == null
                ? null
                : Icon(widget.icono, color: AppColors.primary, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
