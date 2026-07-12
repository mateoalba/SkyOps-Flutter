# Guion de evidencia — video y capturas (rúbrica del profesor)

## Video (3-5 minutos)

Graba pantalla del emulador/celular narrando en voz mientras navegas. Indica al inicio si es emulador o dispositivo físico.

1. **Parte pública (30-40 seg).** Abre la app, muestra el splash → toca "Continuar". Recorre `/publico`: home informativo, toca un módulo (ej. "Operaciones de vuelo") para ver el detalle, vuelve, toca "Contacto". Aclara en voz: "esto es accesible sin iniciar sesión".
2. **Login (30 seg).** Vuelve al home público, toca "Iniciar sesión". Entra con `operador1` / `Operador123!`. Muestra que redirige al dashboard privado.
3. **Dashboard privado (20 seg).** Muestra las tarjetas de estadísticas y la lista de próximos vuelos. Señala la barra inferior (Home/Flights/Bookings/Profile).
4. **Consumo real de API — listado (40 seg).** Entra a "Vuelos" (o cualquier módulo). Muestra la lista cargando datos reales del backend. Haz *pull to refresh*.
5. **Formulario — crear o editar (40 seg).** Crea un registro nuevo (ej. un vuelo) o edita uno existente. Muestra el SnackBar de éxito. Vuelve a la lista y muestra que el cambio quedó reflejado.
6. **Restricción por rol — logueado como Operador (30 seg).** Entra a un módulo donde el operador SÍ puede escribir (ej. Vuelos) y muestra que el botón "+" está visible, pero el ícono de eliminar en cada tarjeta **no aparece**. Entra a un módulo admin-only (ej. "Terminales" o "Registro de auditoría") y muestra que el botón "+" no aparece / el formulario está bloqueado con el aviso "Solo un administrador puede...".
7. **Restricción por rol — logueado como Admin (40 seg).** Cierra sesión, entra con el usuario administrador (`is_staff=True`). Repite el mismo módulo admin-only y muestra que ahora sí puede crear/editar. Muestra el ícono de eliminar visible en un listado y elimina un registro de prueba (con el diálogo de confirmación).
8. **Logout (10 seg).** Cierra sesión desde el perfil y muestra que vuelve a pedir login al intentar entrar a `/home`.

## Capturas obligatorias

Guarda estas 6 capturas (PNG) en una carpeta `capturas/` o pégalas en el PDF/README:

1. Pantalla pública principal (`/publico`).
2. Pantalla de login.
3. Dashboard privado (menú/inicio tras iniciar sesión).
4. Un listado consumiendo la API (con datos reales, no vacío).
5. Un formulario creando o editando, justo después de un guardado exitoso (con el SnackBar visible si es posible).
6. Ejemplo de restricción por rol: botón de eliminar ausente para un usuario no-admin, o el aviso "Solo un administrador puede crear o editar registros en este módulo" en un formulario bloqueado.

## Cómo capturar

- **Emulador Android**: botón de cámara en la barra de controles del emulador, o `flutter screenshot`.
- **Dispositivo físico**: combinación de botones de tu celular (ej. Power + Volumen abajo en Android).
- **Video**: grabador de pantalla nativo del emulador/Android, o herramienta de grabación de Windows (Win+G) si usas `flutter run -d chrome`.
