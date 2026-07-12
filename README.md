# SkyOps — Sistema de Control de Vuelos de un Aeropuerto

App móvil en **Flutter** que consume una API REST propia desarrollada en **Django REST Framework**, con autenticación JWT, sección pública, sección privada protegida por sesión y control de acceso por rol.

## Requisitos

- Flutter SDK 3.3 o superior (probado con Flutter 3.44.x)
- Un dispositivo/emulador Android o iOS, o Chrome/Windows para pruebas de escritorio
- Backend SkyOps corriendo (local o desplegado) — repositorio del backend por separado

## Instalación

```bash
git clone https://github.com/mateoalba/skyops_ejemplo.git
cd skyops_ejemplo
flutter pub get
flutter run
```

## Configuración de la API

La URL base del backend se define en **un único lugar**:

```
lib/core/config/app_config.dart
```

```dart
static const String baseUrl = 'http://147.182.179.6/api';
```

Cambia ese valor según dónde estés probando:

| Escenario | URL |
|---|---|
| Servidor remoto desplegado | `http://147.182.179.6/api` |
| Emulador Android + backend local | `http://10.0.2.2:8000/api` |
| Chrome/Windows + backend local (misma PC) | `http://127.0.0.1:8000/api` |
| Celular físico + backend local | `http://<IP-de-tu-PC-en-la-red>:8000/api` |

No hay que tocar ningún otro archivo: todos los repositorios y el interceptor de autenticación arman sus peticiones a partir de esa constante.

## Credenciales de prueba

Depende de contra qué backend estés probando:

**Backend local (tu máquina, corriendo `manage.py runserver`).** El script `crear_grupos.py` crea usuarios de ejemplo para los tres roles:

| Usuario | Contraseña | Rol |
|---|---|---|
| `operador1` | `Operador123!` | Grupo **Operadores** (crear/editar, sin eliminar) |
| `usuario1` | `Usuario123!` | Usuario normal (solo lectura / sus propios datos) |

Para el rol **Administrador**, usa un usuario con `is_staff=True` (creado con `python manage.py createsuperuser`, o marcado como staff desde `/admin/`).

**Backend desplegado (`http://147.182.179.6/api`).** Ahí normalmente solo existe el superusuario que creó quien desplegó el servidor — `crear_grupos.py` no se ha corrido en esa base de datos, así que `operador1`/`usuario1` **no existen** ahí. Para probar los tres roles contra el servidor desplegado:

1. **Admin**: inicia sesión con las credenciales del superusuario (pídeselas a quien desplegó el backend, o créalas tú si tienes acceso al servidor).
2. **Usuario normal (sin rol especial)**: usa el botón "Crear cuenta" dentro de la propia app — llama a `POST /auth/registro/` real contra el servidor desplegado y crea una cuenta nueva, sin necesidad de sembrar datos. Sirve para probar las restricciones de un usuario no-admin.
3. **Operador** (grupo "Operadores" específicamente): no hay forma de auto-asignarse ese grupo desde la app — alguien con acceso al servidor debe correr `crear_grupos.py` contra esa base de datos, o agregar al usuario al grupo "Operadores" desde `/admin/` de Django.

## Estructura del proyecto

```
lib/
├── main.dart                     ← arma la inyección de dependencias (Dio → Repos → Providers)
├── data/
│   ├── remote/{api, dto, interceptor}
│   ├── local/secure_storage.dart
│   └── repository/               ← implementación de cada repositorio (25 entidades + auth)
├── domain/
│   ├── model/                    ← modelos de dominio
│   └── repository/                ← contratos (interfaces)
├── presentation/
│   ├── navigation/app_router.dart ← GoRouter con guard de sesión
│   ├── screens/
│   │   ├── public/                ← sección pública (sin login)
│   │   ├── auth/                  ← splash, login, registro, perfil
│   │   ├── home/                  ← dashboard privado + shell con nav inferior
│   │   └── {operaciones, infraestructura, flota, personas, administracion}/
│   ├── providers/                 ← estado (ChangeNotifier) por entidad
│   └── widgets/
├── theme/                         ← Material 3, paleta oscura + azul
└── core/{config, error, utils}
```

## Navegación pública vs. privada

- **Pública** (`/publico`, `/publico/modulos/:id`, `/publico/contacto`, `/login`, `/register`): accesible sin sesión. Presenta la app, describe los 5 módulos del sistema y da acceso a iniciar sesión o crear cuenta.
- **Privada** (`/home` y todas las rutas de las 25 entidades): protegida por `GoRouter.redirect` en `app_router.dart`. Si no hay un JWT válido en `flutter_secure_storage`, cualquier intento de entrar redirige a `/login`.

## Autenticación

- `POST /auth/login/` → guarda `access` y `refresh` en `flutter_secure_storage`.
- Interceptor de Dio (`auth_interceptor.dart`) agrega `Authorization: Bearer <token>` a cada request privado.
- En un `401`, el interceptor intenta refrescar el token automáticamente con `POST /auth/refresh/`; si falla, limpia la sesión.
- `Logout` invalida el refresh token en el backend (`POST /auth/logout/`) y borra el almacenamiento local.

## Roles y reglas de negocio (control de acceso real)

El backend Django expone permisos reales por endpoint (`airport/permissions.py`), no solo un campo de texto. Desde el perfil (`/auth/perfil/`) solo es posible verificar de forma confiable si el usuario es **administrador** (`is_staff`); esa es la señal que usa la app para habilitar o esconder acciones — **no es un texto decorativo**, condiciona lo que se renderiza:

- **Eliminar** un registro: el botón de eliminar (ícono de basurero) **solo aparece si el usuario autenticado es administrador**, en las 25 entidades — coincide exactamente con la regla del backend (`DELETE` siempre exige `is_staff`).
- **Crear/editar**: en 15 de los 25 módulos (terminales, pistas, horarios, escalas, asignaciones de pista, categorías de pasajero, equipajes, notificaciones, tarjetas de embarque, tipos de aeronave, mantenimientos, certificaciones, perfiles de usuario, sesiones de usuario y auditoría) el backend exige `is_staff` también para crear/editar — en esos módulos el botón "nuevo" se oculta y el formulario se muestra deshabilitado (con aviso "Solo un administrador puede crear o editar registros en este módulo") si el usuario no es admin.
- En los 10 módulos restantes (vuelos, aerolíneas, aeropuertos, aeronaves, puertas, pasajeros, tripulantes, asignaciones de tripulación, incidentes y reservas) cualquier usuario autenticado (operador o admin) puede crear/editar, y solo el admin puede eliminar.
- Registro de auditoría y sesiones de usuario son de solo administrador incluso para **ver** el listado (el backend rechaza el `GET` a usuarios no-staff); si un usuario no-admin entra ahí, la pantalla muestra el mensaje de error real devuelto por la API en vez de una lista vacía silenciosa.

## ⚠️ Migración pendiente en el servidor desplegado

Mientras trabajaba en esto encontré que 5 de las 25 tablas (**perfiles-usuario, sesiones-usuario, audit-log, mantenimientos, certificaciones**) nunca se migraron en Django — el modelo existía en el código pero no la tabla en la base de datos, así que esos 5 endpoints devolvían error 500. También conecté sus rutas en `urls.py`, que tampoco estaban registradas. Ya está corregido en el código del backend (`airport/models/__init__.py`, `airport/views/__init__.py`, `airport/urls.py`, migración `0008_auditlog_certificaciontripulante_and_more.py`), pero **alguien con acceso al servidor debe aplicar la migración ahí**:

```bash
git pull
python manage.py migrate
```

Sin ese paso, esos 5 módulos van a seguir fallando en el servidor desplegado aunque el código de Flutter y Django ya estén corregidos localmente.

## Registro de cuenta y perfil extendido

El formulario de "Crear cuenta" ahora pide, además de usuario/correo/contraseña: país de residencia, tipo y número de documento, nombre(s), apellidos, fecha de nacimiento, género y teléfono. Estos datos se guardan en un `PerfilUsuario` (modelo Django) vinculado al usuario, con `cargo='usuario'` por defecto (para diferenciarlo de cuentas de staff creadas por un admin). Todos los campos de perfil son opcionales a nivel de backend — si el formulario cambia, no se rompe el registro.

## Configurar Google Sign-In

El botón "Continuar con Google" / "Registrarme con Google" ya está implementado en la app y en el backend (`POST /auth/google/`), pero necesita credenciales reales de Google para funcionar. Mientras no estén configuradas, el botón muestra un aviso ("Login con Google no está configurado todavía") en vez de fallar.

Pasos para activarlo:

1. Entra a [Google Cloud Console](https://console.cloud.google.com/) → crea un proyecto (o usa uno existente) → **APIs & Services → Credentials**.
2. Crea un **OAuth 2.0 Client ID** de tipo **"Web application"** (este es el que verifica el backend). Copia el Client ID generado (termina en `.apps.googleusercontent.com`).
3. **Backend**: agrega esa variable al `.env` del servidor:
   ```
   GOOGLE_OAUTH_CLIENT_ID=tu-client-id.apps.googleusercontent.com
   ```
4. **Flutter**: pega el mismo Client ID en `lib/core/config/app_config.dart`:
   ```dart
   static const String googleServerClientId = 'tu-client-id.apps.googleusercontent.com';
   ```
5. **Android**: crea además un OAuth Client ID de tipo **"Android"** en la misma consola, con el package name (`com.skyops.skyops` o el que tengas en `android/app/build.gradle.kts`) y el SHA-1 de tu certificado de firma (`cd android && ./gradlew signingReport` te lo muestra). No hace falta pegar este Client ID en ningún lado del código — Google lo asocia automáticamente por package name + SHA-1.
6. **iOS** (si aplica): crea un Client ID tipo "iOS", agrega el `REVERSED_CLIENT_ID` como URL scheme en `ios/Runner/Info.plist` (ver documentación del paquete `google_sign_in`).

Sin el paso 3, el endpoint del backend responde `503 Login con Google no está configurado en el servidor` aunque la app sí mande el token.

## Manejo de estados y UX

- `LoadingOverlay` en cada pantalla que consume la API.
- `SnackBar` de éxito/error en cada crear, editar y eliminar.
- Validaciones en formularios (`core/utils/validators.dart`): campos requeridos y numéricos.
- Diálogo de confirmación antes de eliminar (`confirm_delete_dialog.dart`).

## Comandos útiles

```bash
flutter pub get          # instalar dependencias
flutter run               # correr en el dispositivo/emulador conectado
flutter run -d chrome     # correr en el navegador
flutter build apk         # generar APK de release
```

## Evidencia funcional

Ver `EVIDENCIA.md` para el guion de grabación y la lista de capturas obligatorias.
#   S k y O p s - - - F l u t t e r  
 