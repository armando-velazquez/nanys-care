# Setup local para ejecutar Nanys Care (MVP Sprint 1)

Este proyecto está pensado para correr **100% local** en Sprint 1:
- Sin backend
- Sin base de datos remota
- Sin autenticación real
- Sin correos, pagos ni push notifications

## 1) Qué instalar en tu computadora

1. **Git**
2. **Flutter SDK** (estable, compatible con Dart 3.4+)
3. **Android Studio** (incluye Android SDK)
4. Plugins de Android Studio: **Flutter** y **Dart**
5. En Android Studio SDK Manager:
   - Android SDK Platform (API 34 recomendada)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator
   - Intel x86 Emulator Accelerator (HAXM) o hypervisor equivalente

## 2) Variables y PATH

Agrega Flutter al PATH y valida:

```bash
flutter doctor
```

Debes ver checks en Flutter toolchain y Android toolchain.

## 3) Crear un celular virtual (emulador)

1. Android Studio → **Tools → Device Manager**
2. **Create Device**
3. Elige un teléfono (ej. Pixel 6)
4. Descarga una imagen de sistema (API 34, Google APIs)
5. Finaliza y arranca el emulador

## 4) Correr el proyecto

Desde la carpeta `nanys_care`:

```bash
flutter pub get
flutter devices
flutter run
```

Si te faltan archivos locales de Android/Flutter:

```bash
flutter create .
flutter pub get
flutter run
```

## 5) Validación mínima recomendada

```bash
flutter analyze
flutter test
```

## Nota sobre estado actual de este repositorio

El código de Sprint 1 está estructurado como app Flutter Android con rutas, pantallas y datos semilla locales. Para poder confirmar ejecución real en esta máquina, se requiere tener Flutter/Android SDK instalados.
