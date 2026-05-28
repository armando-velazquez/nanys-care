import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/perfil_cuidador.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  static const double _tarifaMinima = 1;
  static const double _tarifaMaxima = 5000;
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _ubicacion = TextEditingController();
  final _experiencia = TextEditingController();
  final _tarifa = TextEditingController();
  final _certificaciones = TextEditingController();

  File? _fotoSeleccionada;
  final Set<DiaSemana> _diasDisponibles = <DiaSemana>{};
  String _horaInicio = '08:00';
  String _horaFin = '18:00';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precargar());
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _ubicacion.dispose();
    _experiencia.dispose();
    _tarifa.dispose();
    _certificaciones.dispose();
    super.dispose();
  }

  Future<void> _precargar() async {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final usuario = auth.usuario;
    if (usuario == null) return;

    await profile.cargarPerfilCuidador(usuario.id);
    final p = profile.perfilCuidador;

    _nombre.text = usuario.nombreCompleto;
    _telefono.text = usuario.telefono ?? '';
    _ubicacion.text = usuario.ubicacion ?? '';

    if (p != null) {
      _experiencia.text = p.aniosExperiencia.toString();
      _tarifa.text = p.tarifaPorHora.toStringAsFixed(0);
      _certificaciones.text = p.certificaciones.join(', ');
      _diasDisponibles
        ..clear()
        ..addAll(p.disponibilidad.map((b) => b.dia));
      if (p.disponibilidad.isNotEmpty) {
        _horaInicio = p.disponibilidad.first.horaInicio;
        _horaFin = p.disponibilidad.first.horaFin;
      }
      if (usuario.fotoPath != null && usuario.fotoPath!.isNotEmpty) {
        _fotoSeleccionada = File(usuario.fotoPath!);
      }
    }

    if (!mounted) return;
    setState(() => _cargando = false);
  }

  Future<void> _seleccionarFoto() async {
    final imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (imagen != null && mounted) {
      setState(() => _fotoSeleccionada = File(imagen.path));
    }
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
    if (hora != null && mounted) {
      setState(() {
        final hhmm =
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
        if (esInicio) {
          _horaInicio = hhmm;
        } else {
          _horaFin = hhmm;
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final usuario = auth.usuario;
    if (usuario == null) return;

    final disponibilidad = _diasDisponibles
        .map((d) => DisponibilidadBloque(
              dia: d,
              horaInicio: _horaInicio,
              horaFin: _horaFin,
            ))
        .toList();

    final actualizado = Usuario(
      id: usuario.id,
      nombreCompleto: _nombre.text.trim(),
      correo: usuario.correo,
      passwordHash: usuario.passwordHash,
      rol: usuario.rol,
      fechaRegistro: usuario.fechaRegistro,
      telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      ubicacion: _ubicacion.text.trim().isEmpty ? null : _ubicacion.text.trim(),
      fotoPath: _fotoSeleccionada?.path,
    );
    await auth.actualizarUsuarioActual(actualizado);

    final tarifa = double.parse(_tarifa.text.trim());
    final perfil = PerfilCuidador(
      usuarioId: usuario.id,
      aniosExperiencia: int.tryParse(_experiencia.text) ?? 0,
      tarifaPorHora: tarifa,
      certificaciones: _certificaciones.text.trim().isEmpty
          ? []
          : _certificaciones.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
      disponibilidad: disponibilidad,
      calificacionPromedio: profile.perfilCuidador?.calificacionPromedio ?? 0,
      totalResenas: profile.perfilCuidador?.totalResenas ?? 0,
    );
    await profile.guardarPerfilCuidador(perfil);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi perfil de cuidador'),
        actions: [
          TextButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save_outlined, color: AppColors.primary),
            label: const Text('Guardar', style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: InkWell(
                    onTap: _seleccionarFoto,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primarySurface,
                      backgroundImage: _fotoSeleccionada != null
                          ? FileImage(_fotoSeleccionada!)
                          : null,
                      child: _fotoSeleccionada == null
                          ? const Icon(Icons.add_a_photo_outlined, color: AppColors.primary)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Nombre completo',
                  controller: _nombre,
                  icono: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Teléfono',
                  controller: _telefono,
                  icono: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Ubicación',
                  controller: _ubicacion,
                  icono: Icons.location_on_outlined,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Años de experiencia',
                  controller: _experiencia,
                  icono: Icons.workspace_premium_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Tarifa por hora',
                  controller: _tarifa,
                  icono: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final valor = v?.trim() ?? '';
                    if (valor.isEmpty) return 'La tarifa es requerida';
                    final tarifa = double.tryParse(valor);
                    if (tarifa == null) {
                      return 'Ingresa una tarifa numérica válida';
                    }
                    if (tarifa < _tarifaMinima || tarifa > _tarifaMaxima) {
                      return 'La tarifa debe estar entre 1 y 5000 MXN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Certificaciones (separadas por coma)',
                  controller: _certificaciones,
                  icono: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                const Text('Disponibilidad semanal', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DiaSemana.values.map((d) {
                    final seleccionado = _diasDisponibles.contains(d);
                    return FilterChip(
                      label: Text(d.labelCorto),
                      selected: seleccionado,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _diasDisponibles.add(d);
                          } else {
                            _diasDisponibles.remove(d);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _seleccionarHora(true),
                        child: Text('Desde: $_horaInicio'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _seleccionarHora(false),
                        child: Text('Hasta: $_horaFin'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
