# Manual de Usuario — Nanys Care (Sprint 1)

Este manual cubre las funcionalidades entregadas en el **Sprint 1** de Nanys Care: registro, inicio de sesión, perfil del tutor, perfil del cuidador, búsqueda y filtrado de cuidadores, agenda de citas y gestión de solicitudes para el cuidador.

---

## 1. Primer arranque

Al abrir Nanys Care por primera vez verás la pantalla de bienvenida con el logo y dos opciones:

- **Iniciar sesión**: para usuarios que ya tienen cuenta.
- **Registrarme**: para crear una cuenta nueva.

> La primera vez que se ejecuta la app, se cargan 5 cuidadoras de muestra (María López, Laura Martínez, Ana Hernández, Carmen Ruiz, Sofía Ramírez) para que el Tutor pueda probar las funciones de búsqueda y reserva.

## 2. Registro de usuario (H1)

1. Toca **Registrarme** en la pantalla de bienvenida.
2. Selecciona tu rol:
   - **Soy Tutor**: buscas un cuidador para tu familia.
   - **Soy Cuidador**: ofreces servicios de cuidado.
3. Llena el formulario correspondiente. La contraseña debe tener al menos 8 caracteres y se guarda cifrada (hash SHA-256).
4. Toca **Crear cuenta**.

Al terminar:
- El **Tutor** pasa a completar su perfil (información de hijos y necesidades).
- El **Cuidador** pasa directamente a su panel principal.

## 3. Inicio de sesión (H2)

1. Toca **Iniciar sesión** en la pantalla de bienvenida.
2. Ingresa tu correo y contraseña.
3. Toca **Iniciar sesión**.

La sesión queda guardada y la próxima vez que abras la app entrarás directo a tu panel.

> Para cerrar sesión: en la pantalla principal del cuidador toca el ícono de menú (☰). En la versión actual del tutor el cierre de sesión se hará desde el menú de Perfil (Sprint 2).

## 4. Perfil del Tutor (H5)

Disponible justo después de crear cuenta como Tutor, o desde **Mi perfil** en el dashboard.

Capturas:
- **Información de tus hijos**: nombre, edad y necesidades especiales (alergias, medicación, etc.). Puedes agregar más de uno con **+ Agregar hijo/a**.
- **Necesidades de cuidado**: horarios, frecuencia (única, recurrente, tiempo completo, fines de semana, emergencias) y comentarios.

Toca **Guardar perfil** para persistir todos los cambios.

## 5. Perfil del Cuidador (H3, H4)

El cuidador captura su perfil durante el registro (pantalla 11):
- Foto de perfil (placeholder en Sprint 1).
- Datos personales y de contacto.
- **Años de experiencia** y **tarifa por hora en MXN** (RF4).
- **Certificaciones** (separadas por coma): primeros auxilios, enfermería, educación infantil, etc.

## 6. Buscar Cuidador (H6)

Desde el dashboard del Tutor toca **Buscar cuidador** o el botón **Buscar** de la barra inferior.

- **Búsqueda libre**: escribe nombre o palabras clave (capacidades).
- **Filtros (botón superior derecho)**:
  - Ubicación
  - Precio máximo por hora
  - Calificación mínima
- **Limpiar filtros** restaura los valores por defecto.

La lista se ordena por mejor calificación. Cada tarjeta muestra calificación, reseñas, años de experiencia, certificación destacada y tarifa.

Acciones por tarjeta:
- **Ver perfil**: detalle completo del cuidador.
- **Agendar**: salta directo a la pantalla de reserva.

## 7. Detalle del cuidador (pantalla 07)

Muestra:
- Foto, nombre y verificación.
- Calificación, reseñas, ubicación.
- Estado (Disponible hoy / Tiempo completo).
- Sección **Sobre mí**.
- Cualidades: experiencia, edades que cuida, certificaciones.
- Tarifa por hora y disponibilidad por día.
- Reseñas destacadas.

Botones inferiores:
- **Enviar mensaje** (Sprint 2+).
- **Agendar cita**: lleva a la pantalla 08.

## 8. Agendar una cita (H8)

En la pantalla **Agendar cita**:

1. **Selecciona fecha y hora**:
   - Toca el día en el calendario.
   - Elige uno de los horarios disponibles.
2. **Detalles del cuidado**:
   - Niño/a (de la lista capturada en tu perfil).
   - Duración (1 a 8 horas).
   - Tipo de cuidado (ocasional, recurrente, tiempo completo, emergencia).
   - Notas opcionales.
3. **Resumen**: verifica fecha, hora, niño, cuidador y total estimado.
4. Toca **Continuar y confirmar**.

La cita queda en estado **Pendiente** hasta que el cuidador la acepte o rechace.

## 9. Mis Reservas (parte de H8)

Desde el dashboard del Tutor toca **Mis reservas** o el ícono de calendario en la barra inferior.

Tres pestañas:
- **Próximas**: citas con fecha futura, pendientes o confirmadas.
- **Pasadas**: citas ya transcurridas o marcadas como completadas.
- **Canceladas**: citas rechazadas o canceladas por el tutor.

En cada tarjeta verás el cuidador, fecha, horario, estado y total. **Ver detalles** y **Mensaje** están reservados para próximos sprints.

## 10. Solicitudes de cuidado (H10)

Es la pantalla principal de gestión del **Cuidador**.

Pestañas:
- **Todas**: todas las solicitudes recibidas.
- **Nuevas**: aún sin responder.
- **En revisión**: estado intermedio (placeholder, sprint 2).
- **Aceptadas**: las que confirmaste.

Para una solicitud nueva:
- **Ver detalles**: abre un panel con la información completa.
- **Aceptar**: marca la cita como confirmada y aparece en el dashboard del tutor.
- **Cerrar (X)**: rechaza la solicitud.

## 11. Cerrar sesión

Cuidador: toca el ícono de menú (☰) en la parte superior izquierda del dashboard.

Tutor: en este sprint, cierre desde menú lateral en próximos sprints. Mientras tanto, desinstalar/limpiar datos de la app.

---

## Glosario

- **Tutor**: persona que busca contratar un cuidador para su familia.
- **Cuidador**: persona que ofrece servicios de cuidado a familias.
- **H1, H2 ...**: historias de usuario del backlog.
- **RF1, RF2 ...**: requisitos funcionales del documento SRS.

---

## Solución de problemas

- **No me deja iniciar sesión** → revisa que el correo y la contraseña sean los que usaste al registrarte (la contraseña distingue mayúsculas).
- **No veo cuidadores** → toca **Limpiar filtros**. Los datos semilla son 5 cuidadores en Chihuahua, Chih.
- **Reinicio total** → desinstala la app del emulador y vuelve a instalar; los datos viven en su sandbox.
