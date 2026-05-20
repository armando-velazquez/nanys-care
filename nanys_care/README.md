# Nanys Care — Sprint 1

App móvil Flutter que conecta familias con cuidadores de confianza.

---

## Cómo abrir en Android Studio (paso a paso)

### 1. Requisitos en tu computadora

Antes de abrir el proyecto necesitas tener instalado:

- **Flutter SDK 3.4 o superior** → https://docs.flutter.dev/get-started/install
- **Android Studio** (Hedgehog 2023.1.1 o más reciente)
- En Android Studio: ir a **Settings → Plugins** e instalar los plugins **Flutter** y **Dart** (te aparecen al buscarlos).
- Un **emulador Android** (se crea desde Android Studio: **Tools → Device Manager → Create Device**) o tu celular con **depuración USB activada**.

Verifica con esto en una terminal:

```bash
flutter doctor
```

Si te aparece todo con palomita verde, vas bien.

### 2. Abrir el proyecto

1. Descomprime `nanys_care_sprint1.zip` en alguna carpeta (por ejemplo en tu Escritorio).
2. Abre Android Studio.
3. Si estás en la pantalla de bienvenida toca **Open** (o si ya tienes otro proyecto abierto: **File → Open**).
4. Selecciona la carpeta `nanys_care` (no el zip, la carpeta).
5. Android Studio detectará que es un proyecto Flutter y empezará a indexar. Aparecerá un banner amarillo arriba que dice "Pub get has not been run". Toca **Run 'pub get'**. Esto descarga las dependencias (unos 30-60 segundos).

### 3. Correr la app

1. Asegúrate que tu emulador esté arrancado **o** tu celular conectado por USB.
2. En la barra superior de Android Studio verás un dropdown con tu dispositivo y un botón verde de **Run** (▶).
3. Toca **Run**. La primera vez tarda 2-4 minutos en compilar; las siguientes son segundos.

Cuando termine, la app se abrirá automáticamente y verás la pantalla de bienvenida con el logo de Nanys Care.

---

## Si Android Studio no jala a la primera

A veces falta regenerar archivos que dependen de tu instalación local de Flutter. En la **Terminal** integrada de Android Studio (`View → Tool Windows → Terminal`) ejecuta:

```bash
flutter pub get
```

Si te dice que falta `local.properties` o algo similar:

```bash
flutter create .
```

Este comando **no borra nada** del código existente, solo regenera los archivos de configuración locales que dependen de tu máquina (ruta al SDK, etc.).

Después dale **Build → Clean Project** y **Build → Rebuild Project** y vuelve a correr.

---

## Qué hace la app

Login → registro como Tutor o como Cuidador → cada uno entra a su panel.

**Como Tutor**: completas perfil (info de tus hijos), buscas cuidadores con filtros (ubicación, precio, calificación, experiencia, disponible hoy), ves el detalle de cada uno, agendas una cita y la consultas en "Mis Reservas".

**Como Cuidador**: completas perfil (foto, experiencia, tarifa, certificaciones, días/horas disponibles), recibes solicitudes de los tutores y las aceptas o rechazas.

Hay 5 cuidadoras de prueba pre-cargadas (María López, Laura Martínez, Ana Hernández, Carmen Ruiz, Sofía Ramírez) para que el flujo del Tutor se pueda probar sin necesidad de registrar uno nuevo.

---

## Estructura del proyecto (resumen)

```
nanys_care/
├── lib/
│   ├── main.dart                # Entry point
│   ├── app.dart                 # MaterialApp + Providers
│   ├── theme/                   # Colores y tema visual
│   ├── routes/                  # Navegación
│   ├── models/                  # Modelos de datos
│   ├── services/                # Lógica de negocio + persistencia
│   ├── providers/               # Estado con Provider
│   ├── widgets/                 # Componentes reutilizables
│   └── screens/                 # Pantallas (auth, tutor, caregiver, shared)
├── assets/data/                 # Datos semilla (cuidadoras precargadas)
├── android/                     # Configuración nativa de Android
└── pubspec.yaml                 # Dependencias del proyecto
```

---

## Historias de usuario implementadas (Sprint 1)

| Historia | RF | Estado |
|---|---|---|
| H1 Registro de nuevos usuarios | RF1 | ✅ |
| H2 Inicio de sesión | RF2 | ✅ |
| H3 Creación de perfil del Cuidador | RF3, RF4 | ✅ |
| H5 Registro de perfil del Tutor | RF5 | ✅ |
| H6 Búsqueda y filtrado de Cuidadores | RF6 | ✅ |
| H8 Reserva de citas de cuidado | RF8 | ✅ |
| H10 Gestión de solicitudes de citas | RF10 | ✅ |
