# Decisiones de Arquitectura — Nanys Care (Sprint 1)

Este documento describe las decisiones técnicas tomadas al construir el Sprint 1 de Nanys Care, junto con la justificación y las alternativas consideradas. Está pensado para que cualquier integrante (o el siguiente sprint) pueda entender por qué la app está construida así.

---

## 1. Alcance y restricciones

- **Scope**: solo las 7 historias del Sprint 1 (H1, H2, H3, H5, H6, H8, H10). Cualquier funcionalidad de Sprints posteriores aparece como CTA inerte que muestra un mensaje "Disponible en próximos sprints".
- **Plataforma**: aplicación móvil únicamente (Android e iOS).
- **Equipo**: estudiantes de un curso; uso de un stack único, ampliamente documentado y multiplataforma.
- **Tiempo**: la planificación del sprint asume que el equipo no debe perder tiempo en configurar infraestructura externa.

## 2. Stack tecnológico

| Capa | Decisión | Por qué |
|------|----------|---------|
| Framework | **Flutter 3.4 / Dart 3.4** | Multiplataforma con un solo código base, documentación extensa, UI declarativa y rendimiento nativo. El curso ya define Flutter + Dart + VS Code como tooling oficial. |
| IDE | **VS Code** (también Android Studio compatible) | Lightweight, integración nativa de Flutter, definido en el documento de herramientas. |
| Manejo de estado | **Provider 6.x** (ChangeNotifier) | Simple, oficialmente recomendado para apps medianas, fácil de enseñar y entender. Alternativas como Riverpod o Bloc agregaban complejidad innecesaria para Sprint 1. |
| Navegación | **go_router 14.x** | API declarativa, soporta `refreshListenable` para auth, y permite proteger rutas con `redirect`. El equivalente imperativo (`Navigator 1.0`) hacía más difícil el flujo "splash → login → home". |
| Persistencia | **Archivos JSON** vía `dart:io` + `path_provider` | Ver sección 3. |
| Hash de contraseñas | **SHA-256 + sal** (`crypto`) | Aunque no hay servidor, evitamos guardar contraseñas en texto plano (RNF1 Seguridad). |
| Calendario | **table_calendar 3.x** | Componente listo, localizable a `es_MX`, suficiente para H8. |
| Localización fechas | **intl 0.19** | Necesario para `EEE, d MMM y` y nombres de meses en español. |

## 3. Persistencia: ¿por qué JSON y no una base de datos?

Se evaluaron tres alternativas:

| Opción | Pros | Contras |
|--------|------|---------|
| **JSON plano (elegida)** | Cero dependencias nativas. Cero setup. Fácil de inspeccionar y mockear. Inicialización con datos semilla trivial. | I/O sin índices, no escala a miles de registros. |
| sqflite | Indexado, consultas SQL. | Setup adicional, requiere binarios nativos por plataforma. Innecesario para 5–20 cuidadores. |
| Hive | Rápido, simple. | Aún introduce dependencia que el equipo tendría que aprender. |

El Sprint 1 maneja decenas de registros como máximo (un usuario, sus hijos, algunas reservas), por lo que un fichero JSON por colección es más que suficiente y elimina toda la fricción de las migraciones.

**Estructura física** (todos viven en `<app_documents>/nanys_care/`):

```
usuarios.json
sesion.json
perfiles_tutor.json
perfiles_cuidador.json
citas.json
seed_aplicado.json   # marcador para no recargar la semilla
```

Cada archivo es un array o un objeto JSON, indentado para inspección manual.

## 4. Datos semilla (seed)

Como no hay backend, un Tutor recién instalado vería una lista vacía de cuidadores y no podría probar H6 ni H8. Solución:

- `assets/data/cuidadores_semilla.json` trae 5 cuidadoras pre-pobladas en Chihuahua (María López, Laura Martínez, Ana Hernández, Carmen Ruiz, Sofía Ramírez).
- En el primer arranque (`SeedDataService.aplicarSiEsNecesario()`), la app copia esos usuarios y perfiles a los archivos locales y deja un marcador `seed_aplicado` para no volver a hacerlo.
- Los cuidadores semilla **no pueden iniciar sesión** (su hash es `demo-no-login`). Existen solo como inventario para que el Tutor los encuentre, los vea y agende con ellos.

## 5. Autenticación

- **Registro y login** (H1, H2) usan SHA-256 con el correo del usuario como sal:
  ```
  hash = sha256("<correo>::<password>::nanys_care_v1")
  ```
  - La sal es determinística porque no hay BD para guardar una sal aleatoria por usuario.
  - El esquema cumple con RNF1 (no se guarda la contraseña en claro) pero no es resistente a un atacante con acceso al dispositivo + tablas precalculadas. Para producción, se debe migrar a un esquema con sal aleatoria + KDF (Argon2 / scrypt). Documentado para el roadmap.
- La **sesión activa** se guarda como `{ "usuarioId": "..." }` en `sesion.json` para evitar el login en cada arranque.
- El cierre de sesión simplemente elimina ese archivo.

## 6. Modelado del dominio

Modelos simples, todos POJO con `toJson()` / `fromJson()`:

- `Usuario` → datos base + `rol`.
- `PerfilTutor` → 1 a 1 con `Usuario`, contiene `Hijo`s y necesidades.
- `PerfilCuidador` → 1 a 1 con `Usuario`, contiene experiencia, tarifa, certificaciones, capacidades y `DisponibilidadBloque`s.
- `Cita` → tutor + cuidador + niño + fecha/horario + estado.

Se separó **Usuario** de su **Perfil** porque cada rol pide campos diferentes y porque el flujo de registro (mínimo) está separado de la captura completa de perfil.

## 7. Organización del código

```
lib/
├── models/      # Estructuras de datos (sin Flutter)
├── services/    # Lógica de negocio + I/O (sin Flutter, salvo rootBundle)
├── providers/   # ChangeNotifier que adaptan servicios a la UI
├── routes/      # go_router config + protección de rutas
├── widgets/     # Widgets reutilizables (logo, inputs, step indicator, navs)
├── theme/       # Paleta y ThemeData Material 3
└── screens/     # Una carpeta por flujo: shared / auth / tutor / caregiver
```

Razones:
- **Models y services no dependen de Flutter** → más fácil hacer unit tests sin emulador.
- **Providers son el único punto donde la UI escucha cambios** → la UI no toca servicios directamente.
- **Una pantalla por archivo** porque cada pantalla del mockup mapea 1:1 a una historia/RF.

## 8. Sistema de diseño y theming

- Paleta tomada directamente de los mockups oficiales (`AppColors`):
  - Morado primario `#6A3DE8`
  - Rosa acento `#EC4C8B`
  - Lavanda de fondo `#FAF7FF`
  - Superficies clara morada y rosa, ambos `#F1ECFF` y `#FDE8F1`
- `AppTheme.light` define los estilos por defecto de `InputDecoration`, `ElevatedButton`, `OutlinedButton`, `Card` y `Chip` para que **toda la app respete el mismo look-and-feel** sin que cada pantalla tenga que volver a configurarlos.
- Roboto como fuente por simpleza (no se subió la fuente exacta del mockup para no inflar el bundle).

## 9. Manejo del logo

Los mockups muestran un logo gráfico que combina un corazón con la silueta de un adulto y un niño. Para Sprint 1 usamos un widget de texto (`NanysLogo`) que reproduce el contraste morado/rosa de la palabra "Nanys Care" y agrega un ícono Material como placeholder. Cuando el equipo de diseño entregue el SVG/PNG oficial, basta sustituir el contenido del widget.

## 10. Pantallas dentro / fuera del Sprint 1

**Dentro** (12 pantallas, todas implementadas con datos reales):
01, 02, 03, 04, 05*, 06, 07, 08, 09, 11, 13*, 14, + Login (nueva, diseñada por nosotros para H2).

*05 y 13 se construyen como dashboards mínimos para que el usuario pueda navegar; las tarjetas que llevan a flujos del Sprint 2 muestran "Disponible en próximos sprints".*

**Fuera** (sprints siguientes): 10 (Calificar cuidador), 12 (Perfil cuidadora), 15 (Agenda cuidador), 16 (Notas privadas), 17 (Reglamento).

## 11. Pantalla de Login (diseñada)

H2 (RF2) requiere una pantalla de inicio de sesión, pero los mockups oficiales no incluyen ninguna. Se diseñó una manteniendo el mismo estilo visual: encabezado con logo y eslogan, ilustración placeholder (icono de candado), dos inputs y los CTAs principales. Si después el equipo de diseño entrega la versión final, sustituir el contenido de `lib/screens/auth/login_screen.dart`.

## 12. Lo que sigue (recomendaciones para el Sprint 2)

1. Migrar el hash de contraseñas a Argon2 o scrypt con sal aleatoria.
2. Implementar la carga real de foto de perfil (image_picker ya está en `pubspec.yaml`).
3. Añadir las pantallas 10, 12, 15, 16, 17.
4. Reemplazar `NanysLogo` por un asset oficial.
5. Reemplazar los datos semilla con una integración real de backend cuando se decida la plataforma (Firebase, Supabase, etc.).
6. Agregar tests unitarios a `services/` y `providers/` (los modelos ya están listos para esto).

---

**Resumen de una línea**: Flutter + Provider + go_router + JSON local, con datos semilla para que la app sea inmediatamente probable sin levantar ningún servidor.
