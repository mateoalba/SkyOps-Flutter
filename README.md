# ✈️ SkyOps — Sistema de Control de Vuelos de un Aeropuerto

App móvil desarrollada en **Flutter** que consume una API REST propia construida en **Django REST Framework**, con autenticación JWT, sección pública, sección privada protegida por sesión y control de acceso real por rol de usuario.

Proyecto académico — gestión integral de operaciones aeroportuarias: vuelos, infraestructura, flota, pasajeros/personal y administración del sistema, sobre 25 módulos CRUD conectados a la API real.

## Índice

- [Características principales](#características-principales)
- [Tecnologías](#tecnologías)
- [Arquitectura del proyecto](#arquitectura-del-proyecto)
- [Módulos del sistema](#módulos-del-sistema)
- [Roles y control de acceso](#roles-y-control-de-acceso)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Configuración de la API](#configuración-de-la-api)
- [Credenciales de prueba](#credenciales-de-prueba)
- [Comandos útiles](#comandos-útiles)
- [Evidencia funcional](#evidencia-funcional)
- [Equipo](#equipo)

## Características principales

- **Sección pública** sin necesidad de iniciar sesión: pantalla de bienvenida, carrusel informativo de los 5 módulos del sistema, detalle de cada módulo y pantalla de contacto.
- **Autenticación real contra la API**: login por correo, registro con datos de perfil extendidos (documento, fecha de nacimiento, país, teléfono), inicio de sesión con Google, y recuperación de sesión persistente.
- **Sesión con JWT**: token guardado de forma segura con `flutter_secure_storage`, adjuntado automáticamente a cada request y refrescado solo cuando expira (sin pedirle al usuario que vuelva a loguearse a media navegación).
- **Rutas protegidas**: ninguna pantalla privada es accesible sin sesión válida — lo controla el `redirect` de GoRouter, no solo un chequeo visual.
- **Control de acceso por rol real**, no cosmético: Administrador, Operador y Pasajero ven y pueden hacer cosas distintas porque el propio backend lo exige por endpoint, y la app oculta/bloquea antes de intentar la acción.
- **25 módulos CRUD** contra la API real (listar, crear, editar, eliminar según el rol), agrupados por categoría operativa.
- **Reserva de vuelos de punta a punta** para pasajeros: búsqueda de vuelos por origen/destino/fecha, mapa de asientos interactivo, y auto-vinculación de su perfil de pasajero sin depender de un administrador.
- **Notificaciones en tiempo real de uso** (no push, pero sí reactivas): cuando un administrador cambia el estado de una reserva (confirmada, cancelada, abordada), el pasajero recibe una notificación automática, con contador de no leídas en la campana del panel principal.
- **Contenido público editable por el administrador**: textos e imágenes del carrusel público, la pantalla de login y las ofertas del dashboard se administran desde la propia app, sin tocar código.
- **UX cuidada**: indicadores de carga, `SnackBar` de éxito/error, validaciones de formulario, diálogos de confirmación antes de eliminar, y un diseño oscuro consistente en toda la app.

## Tecnologías

| Categoría | Paquete |
|---|---|
| Framework | Flutter (Dart) |
| HTTP / API | `dio` |
| Navegación | `go_router` (con guards de sesión) |
| Estado | `provider` |
| Sesión / tokens | `flutter_secure_storage` |
| Fechas y formatos | `intl` |
| Login social | `google_sign_in` |
| Selección de imagen | `image_picker` |
| Backend | Django REST Framework + JWT (`simplejwt`) |

## Arquitectura del proyecto

Arquitectura limpia por capas: `data` (acceso a la API) → `domain` (modelos y contratos) → `presentation` (UI y estado), con `core` y `theme` como utilidades transversales.

```
lib/
├── main.dart                        ← inyección de dependencias (Dio → Repositorios → Providers)
│
├── data/
│   ├── remote/
│   │   ├── api/dio_client.dart      ← instancia Dio + interceptores
│   │   ├── dto/                     ← un DTO por entidad (mapeo JSON ⇄ modelo)
│   │   └── interceptor/auth_interceptor.dart
│   ├── local/secure_storage.dart    ← wrapper de FlutterSecureStorage
│   └── repository/                  ← implementación de cada repositorio (25 entidades + auth)
│
├── domain/
│   ├── model/                       ← modelos de dominio
│   └── repository/                  ← contratos (interfaces)
│
├── presentation/
│   ├── navigation/app_router.dart   ← GoRouter con guard de sesión y roles
│   ├── screens/
│   │   ├── public/                  ← sección pública (sin login)
│   │   ├── auth/                    ← splash, login, registro, perfil
│   │   ├── home/                    ← dashboard privado + menú principal
│   │   ├── operaciones/             ← vuelos, horarios, escalas, incidentes, asignaciones
│   │   ├── infraestructura/         ← aeropuertos, puertas, terminales, pistas
│   │   ├── flota/                   ← aeronaves, tipos, mantenimientos, certificaciones
│   │   ├── personas/                ← pasajeros, reservas, tripulantes, equipajes
│   │   └── administracion/          ← aerolíneas, notificaciones, usuarios, auditoría, contenido público
│   ├── providers/                   ← estado (ChangeNotifier) por entidad
│   └── widgets/                     ← componentes compartidos (tarjetas, overlays, diálogos)
│
├── theme/                           ← Material 3, paleta oscura + azul
└── core/
    ├── config/app_config.dart       ← URL base de la API (único lugar a cambiar)
    ├── error/api_exception.dart
    └── utils/{formatters,validators}.dart
```

## Módulos del sistema

25 entidades agrupadas en 5 categorías, cada una con listado, formulario de creación/edición y (según rol) eliminación:

**Operaciones de vuelo** — Vuelos, Horarios, Escalas, Incidentes, Asignaciones de tripulación, Asignaciones de pista.
**Infraestructura del aeropuerto** — Aeropuertos, Puertas de embarque, Terminales, Pistas.
**Flota y mantenimiento** — Aeronaves, Tipos de aeronave, Mantenimientos, Certificaciones.
**Pasajeros y personal** — Pasajeros, Reservas, Tripulantes, Equipajes, Tarjetas de embarque, Categorías de pasajero.
**Administración del sistema** — Aerolíneas, Notificaciones, Perfiles de usuario, Sesiones de usuario, Registro de auditoría, Contenido público (banners e imágenes editables).

## Roles y control de acceso

El backend expone permisos reales por endpoint (`airport/permissions.py`) — la app no decide nada por su cuenta, solo refleja lo que la API ya exige:

| Rol | Cómo se identifica | Puede hacer |
|---|---|---|
| **Administrador** | `is_staff = true` en Django | Acceso total: crear, editar y eliminar en los 25 módulos, gestionar usuarios, auditoría, contenido público y reglas de negocio. |
| **Operador** | Pertenece al grupo Django "Operadores" | Crear/editar en los módulos operativos (vuelos, aeronaves, pasajeros, reservas, etc.), sin poder eliminar ni acceder a módulos exclusivos de admin (auditoría, sesiones, usuarios). |
| **Pasajero / usuario normal** | Cuenta autenticada sin rol especial | Consulta pública + privada de solo lectura de sus propios datos, búsqueda y reserva de vuelos a su propio nombre, gestión de su perfil. |

El botón de eliminar solo se renderiza si el usuario es administrador (en los 25 módulos), y 15 de los 25 formularios se muestran deshabilitados con el aviso *"Solo un administrador puede crear o editar registros en este módulo"* si el usuario no tiene permiso — coincide exactamente con lo que el backend permite o rechaza.

## Requisitos

- Flutter SDK 3.3 o superior (probado con Flutter 3.44.x)
- Un dispositivo/emulador Android o iOS, o Chrome/Windows para pruebas de escritorio
- Backend SkyOps corriendo (local o desplegado)

## Instalación

```bash
git clone https://github.com/mateoalba/SkyOps---Flutter.git
cd SkyOps---Flutter
flutter pub get
flutter run
```

## Configuración de la API

La URL base del backend se define en **un único lugar**:

```dart
// lib/core/config/app_config.dart
static const String baseUrl = 'http://147.182.179.6/api';
```

Cámbiala según dónde estés probando:

| Escenario | URL |
|---|---|
| Servidor remoto desplegado | `http://147.182.179.6/api` |
| Emulador Android + backend local | `http://10.0.2.2:8000/api` |
| Chrome/Windows + backend local (misma PC) | `http://127.0.0.1:8000/api` |
| Celular físico + backend local | `http://<IP-de-tu-PC-en-la-red>:8000/api` |

No hay que tocar ningún otro archivo: todos los repositorios y el interceptor de autenticación arman sus peticiones a partir de esa constante.

## Credenciales de prueba

| Usuario | Contraseña | Rol |
|---|---|---|
| `operador1` | `Operador123!` | Operador (crear/editar, sin eliminar) |
| `usuario1` | `Usuario123!` | Usuario normal (pasajero) |

Para el rol **Administrador**, usa una cuenta con `is_staff = true` (creada con `python manage.py createsuperuser` en el backend, o marcada como staff desde `/admin/`).

Si estás probando contra el servidor desplegado y esas cuentas no existen ahí, puedes crear una cuenta de pasajero nueva desde el botón "Crear cuenta" de la propia app (llama al registro real de la API).

## Comandos útiles

```bash
flutter pub get          # instalar dependencias
flutter run               # correr en el dispositivo/emulador conectado
flutter run -d chrome      # correr en el navegador
flutter build apk         # generar APK de release
flutter analyze           # verificar errores de compilación/lint
```

## Evidencia funcional

Ver [`EVIDENCIA.md`](./EVIDENCIA.md) para el guion de grabación del video y la lista de capturas obligatorias de la rúbrica.

## Equipo

Proyecto desarrollado en equipo, dividido por módulos funcionales:

- **Mateo Alba** — Operaciones de vuelo e Infraestructura
- **Marcelo Bacon** — Flota y mantenimiento + Pasajeros y personal
- **Heymi de la Cruz** — Administración del sistema + Autenticación
