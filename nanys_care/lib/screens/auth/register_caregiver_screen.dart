import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/perfil_cuidador.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';

/// Pantalla 11 - "NCRegistro_de_cuidador"
/// Registro extendido para usuarios con rol Cuidador (RF1, RF3, RF4).
class RegisterCaregiverScreen extends StatefulWidget {
  const RegisterCaregiverScreen({super.key});

  @override
  State<RegisterCaregiverScreen> createState() =>
      _RegisterCaregiverScreenState();
}

class _RegisterCaregiverScreenState extends State<RegisterCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _pass = TextEditingController();
  final _passConfirm = TextEditingController();
  final _telefono = TextEditingController();
  final _ubicacion = TextEditingController();
  final _experiencia = TextEditingController();
  final _tarifa = TextEditingController();
  final _certificaciones = TextEditingController();

  File? _fotoSeleccionada;
  final Set<DiaSemana> _diasDisponibles = <DiaSemana>{};
  String _horaInicio = '08:00';
  String _horaFin = '18:00';

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _pass.dispose();
    _passConfirm.dispose();
    _telefono.dispose();
    _ubicacion.dispose();
    _experiencia.dispose();
    _tarifa.dispose();
    _certificaciones.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (imagen != null) {
        setState(() => _fotoSeleccionada = File(imagen.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir la galería: $e')),
        );
      }
    }
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
    final profile = context.read<ProfileProvider>();

    final ok = await auth.registrar(
      nombreCompleto: _nombre.text,
      correo: _correo.text,
      password: _pass.text,
      rol: UserRole.cuidador,
      telefono: _telefono.text.isEmpty ? null : _telefono.text,
      ubicacion: _ubicacion.text.isEmpty ? null : _ubicacion.text,
      fotoPath: _fotoSeleccionada?.path,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.ultimoError ?? 'No se pudo registrar'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final disponibilidad = _diasDisponibles
        .map((d) => DisponibilidadBloque(
              dia: d,
              horaInicio: _horaInicio,
              horaFin: _horaFin,
            ))
        .toList();

    final perfil = PerfilCuidador(
      usuarioId: auth.usuario!.id,
      aniosExperiencia: int.tryParse(_experiencia.text) ?? 0,
      tarifaPorHora: double.tryParse(_tarifa.text) ?? 0,
      certificaciones: _certificaciones.text.isEmpty
          ? []
          : _certificaciones.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
      disponibilidad: disponibilidad,
    );
    await profile.guardarPerfilCuidador(perfil);

    if (!mounted) return;
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
    context.go(AppRoutes.caregiverHome);
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final parts = (esInicio ? _horaInicio : _horaFin).split(':');
    final inicial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final hora = await showTimePicker(
      context: context,
      initialTime: inicial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hora != null) {
      final hhmm =
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (esInicio) {
          _horaInicio = hhmm;
        } else {
          _horaFin = hhmm;
        }
      });
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
        title: const Text('Registro de cuidador'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Únete a Nanys Care y comienza a cuidar con amor',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crea tu cuenta\ncomo cuidador',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Completa tu información para empezar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _bloqueFotoPerfil(),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Ej. María López',
                  label: 'Nombre completo',
                  controller: _nombre,
                  icono: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'tu@email.com',
                  label: 'Correo electrónico',
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
                  hint: 'Mínimo 8 caracteres',
                  label: 'Contraseña',
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
                  hint: 'Repite tu contraseña',
                  label: 'Confirmar contraseña',
                  controller: _passConfirm,
                  icono: Icons.lock_outline,
                  obscure: true,
                  toggleableObscure: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'Ej. 614 123 4567',
                        label: 'Teléfono',
                        controller: _telefono,
                        icono: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: 'Ciudad, Colonia',
                        label: 'Ubicación',
                        controller: _ubicacion,
                        icono: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'Ej. 3',
                        label: 'Años de experiencia',
                        controller: _experiencia,
                        icono: Icons.work_outline,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (int.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: 'Ej. 120',
                        label: 'Tarifa por hora (MXN)',
                        controller: _tarifa,
                        icono: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (double.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Primeros auxilios, enfermería, etc.',
                  label: 'Certificaciones (opcional)',
                  controller: _certificaciones,
                  icono: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 20),
                _bloqueDisponibilidad(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_outlined,
                          color: AppColors.accent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Documentos y verificación',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent)),
                            SizedBox(height: 2),
                            Text(
                              'En el siguiente paso podrás subir tus documentos para verificar tu perfil.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget _bloqueFotoPerfil() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Foto de perfil',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _seleccionarFoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    image: _fotoSeleccionada == null
                        ? null
                        : DecorationImage(
                            image: FileImage(_fotoSeleccionada!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: _fotoSeleccionada == null
                      ? const Icon(Icons.camera_alt_outlined,
                          color: AppColors.primary, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fotoSeleccionada == null
                          ? 'Agrega una foto clara y amigable.'
                          : 'Foto seleccionada ✓',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _fotoSeleccionada == null
                            ? AppColors.textPrimary
                            : AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fotoSeleccionada == null
                          ? 'Esto genera confianza en las familias.'
                          : 'Toca la imagen para cambiarla.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bloqueDisponibilidad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.event_available, color: AppColors.primary, size: 20),
              SizedBox(width: 6),
              Text('Disponibilidad',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona los días en los que puedes ofrecer tus servicios.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: DiaSemana.values.map((d) {
              final seleccionado = _diasDisponibles.contains(d);
              return GestureDetector(
                onTap: () => setState(() {
                  if (seleccionado) {
                    _diasDisponibles.remove(d);
                  } else {
                    _diasDisponibles.add(d);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.primary
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: seleccionado ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _selectorHora('Hora inicio', _horaInicio, true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _selectorHora('Hora fin', _horaFin, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectorHora(String etiqueta, String valor, bool esInicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _seleccionarHora(esInicio),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(valor,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
