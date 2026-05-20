import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/hijo.dart';
import '../../models/perfil_tutor.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_header.dart';

/// Pantalla 04 - "NC_PerfilDelTutor"
/// Permite al Tutor completar / editar su perfil con hijos y necesidades (RF5).
class TutorProfileSetupScreen extends StatefulWidget {
  const TutorProfileSetupScreen({super.key});

  @override
  State<TutorProfileSetupScreen> createState() =>
      _TutorProfileSetupScreenState();
}

class _TutorProfileSetupScreenState extends State<TutorProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_HijoForm> _hijosForm = [];
  final _horarios = TextEditingController();
  final _comentarios = TextEditingController();
  String? _frecuencia;
  bool _yaCargo = false;

  static const _frecuencias = [
    'Una sola vez',
    'Días específicos',
    'Tiempo completo',
    'Fines de semana',
    'Emergencias',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precargarPerfil());
  }

  Future<void> _precargarPerfil() async {
    if (_yaCargo) return;
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    if (auth.usuario == null) return;

    await profile.cargarPerfilTutor(auth.usuario!.id);
    final perfil = profile.perfilTutor;

    if (!mounted) return;
    setState(() {
      if (perfil != null && perfil.hijos.isNotEmpty) {
        _hijosForm.clear();
        for (final h in perfil.hijos) {
          final form = _HijoForm()
            ..idExistente = h.id
            ..edad = h.edad.toString();
          form.nombre.text = h.nombre;
          form.necesidades.text = h.necesidadesEspeciales ?? '';
          _hijosForm.add(form);
        }
      } else {
        // Primera vez - un hijo vacío para empezar
        _hijosForm.add(_HijoForm());
      }
      _horarios.text = perfil?.horariosNecesitados ?? '';
      _comentarios.text = perfil?.comentariosAdicionales ?? '';
      _frecuencia = perfil?.frecuencia;
      _yaCargo = true;
    });
  }

  @override
  void dispose() {
    for (final h in _hijosForm) {
      h.dispose();
    }
    _horarios.dispose();
    _comentarios.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final usuarioId = auth.usuario!.id;

    final hijos = _hijosForm
        .where((h) => h.nombre.text.trim().isNotEmpty)
        .map((h) => Hijo(
              id: h.idExistente ?? const Uuid().v4(),
              nombre: h.nombre.text.trim(),
              edad: int.tryParse(h.edad ?? '') ?? 0,
              necesidadesEspeciales: h.necesidades.text.trim().isEmpty
                  ? null
                  : h.necesidades.text.trim(),
            ))
        .toList();

    if (hijos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un hijo o hija'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final perfil = PerfilTutor(
      usuarioId: usuarioId,
      hijos: hijos,
      horariosNecesitados:
          _horarios.text.trim().isEmpty ? null : _horarios.text.trim(),
      frecuencia: _frecuencia,
      comentariosAdicionales: _comentarios.text.trim().isEmpty
          ? null
          : _comentarios.text.trim(),
    );

    await profile.guardarPerfilTutor(perfil);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Perfil guardado correctamente')),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.go(AppRoutes.tutorHome);
  }

  @override
  Widget build(BuildContext context) {
    if (!_yaCargo) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.tutorHome),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Perfil del Tutor'),
            Text(
              'Cuéntanos sobre tu familia y necesidades',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save_outlined, color: AppColors.primary),
            label: const Text('Guardar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.family_restroom,
                            color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Bienvenido a ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const TextSpan(
                                    text: 'Nanys Care',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Completa tu perfil para que podamos encontrar al cuidador ideal para tus hijos.',
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
                SectionHeader(
                  icono: Icons.groups_outlined,
                  titulo: 'Información de tus hijos',
                  trailing: TextButton.icon(
                    onPressed: () => setState(() => _hijosForm.add(_HijoForm())),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text('Agregar hijo/a'),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                ...List.generate(_hijosForm.length, (i) {
                  final h = _hijosForm[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
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
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.child_care,
                                    color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Hijo/a ${i + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                              if (_hijosForm.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: AppColors.textHint, size: 20),
                                  onPressed: () =>
                                      setState(() => _hijosForm.removeAt(i)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  hint: 'Ej. Sofía',
                                  label: 'Nombre del niño/a',
                                  controller: h.nombre,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dropdownEdad(h),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            hint:
                                'Ej. Alergias, medicación, rutinas especiales...',
                            label: 'Necesidades especiales (opcional)',
                            controller: h.necesidades,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline,
                          color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Puedes agregar o quitar hijos en cualquier momento.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(
                  icono: Icons.schedule,
                  titulo: 'Necesidades de cuidado',
                ),
                const Divider(),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Selecciona días y horarios',
                  label: 'Horarios en los que necesitas cuidado',
                  controller: _horarios,
                  icono: Icons.calendar_today_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                const Text('Frecuencia',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _frecuencia,
                  hint: const Text('Seleccionar frecuencia'),
                  items: _frecuencias
                      .map((f) =>
                          DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _frecuencia = v),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Información importante que el cuidador deba saber...',
                  label: 'Comentarios adicionales (opcional)',
                  controller: _comentarios,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar perfil'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownEdad(_HijoForm h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edad',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: h.edad,
          hint: const Text('Seleccionar'),
          items: List.generate(15, (i) {
            final edad = i.toString();
            return DropdownMenuItem(
                value: edad, child: Text('$edad años'));
          }),
          onChanged: (v) => setState(() => h.edad = v),
        ),
      ],
    );
  }
}

class _HijoForm {
  String? idExistente;
  final nombre = TextEditingController();
  String? edad;
  final necesidades = TextEditingController();

  void dispose() {
    nombre.dispose();
    necesidades.dispose();
  }
}
