import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/step_indicator.dart';

/// Pantalla 03 - "NC_CreaTuCuentaComoTutor"
/// Formulario de registro para usuarios con rol Tutor (RF1).
class RegisterTutorScreen extends StatefulWidget {
  const RegisterTutorScreen({super.key});

  @override
  State<RegisterTutorScreen> createState() => _RegisterTutorScreenState();
}

class _RegisterTutorScreenState extends State<RegisterTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _pass = TextEditingController();
  final _passConfirm = TextEditingController();
  final _telefono = TextEditingController();
  final _ubicacion = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _pass.dispose();
    _passConfirm.dispose();
    _telefono.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text != _passConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.registrar(
      nombreCompleto: _nombre.text,
      correo: _correo.text,
      password: _pass.text,
      rol: UserRole.tutor,
      telefono: _telefono.text.isEmpty ? null : _telefono.text,
      ubicacion: _ubicacion.text.isEmpty ? null : _ubicacion.text,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('¡Cuenta creada correctamente!')),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      context.go(AppRoutes.tutorProfileSetup);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.ultimoError ?? 'No se pudo registrar'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const StepIndicator(
            pasoActual: 3, total: 4, completados: [true, true, false, false]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Crea tu cuenta como Tutor',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completa la información para registrarte',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.center,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.family_restroom,
                      size: 72, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  hint: 'Nombre completo',
                  controller: _nombre,
                  icono: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Correo electrónico',
                  controller: _correo,
                  icono: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Contraseña',
                  controller: _pass,
                  icono: Icons.lock_outline,
                  obscure: true,
                  toggleableObscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Confirmar contraseña',
                  controller: _passConfirm,
                  icono: Icons.lock_outline,
                  obscure: true,
                  toggleableObscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Teléfono (opcional)',
                  controller: _telefono,
                  icono: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Ej. Chihuahua, Chihuahua',
                  label: 'Ubicación aproximada',
                  controller: _ubicacion,
                  icono: Icons.location_on_outlined,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: cargando ? null : _enviar,
                  child: cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('o',
                          style: TextStyle(color: AppColors.textHint)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Inicio con Google disponible en próximos sprints'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata,
                      size: 28, color: Color(0xFF4285F4)),
                  label: const Text('Continuar con Google'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta? ',
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
