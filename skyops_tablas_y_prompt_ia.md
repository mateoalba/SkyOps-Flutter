# SkyOps — Tablas del backend y prompt para generar pantallas Flutter

Backend: Django REST Framework, base URL `http://147.182.179.6/api/`, autenticación JWT (login, refresh, registro, perfil).

## 1. Tablas / entidades (25)

### Operaciones de vuelo

| Tabla | Endpoint | Campos (`*` = requerido, `FK→` = referencia a otra tabla) |
|---|---|---|
| Vuelos | `/vuelos/` | numero_vuelo*, aerolinea*(FK→aerolineas), aeronave*(FK→aeronaves), aeropuerto_origen*(FK→aeropuertos), aeropuerto_destino*(FK→aeropuertos), puerta(FK→puertas), fecha_salida*(datetime), fecha_llegada*(datetime), estado |
| Asignaciones (tripulación) | `/asignaciones/` | tripulante*(FK→tripulantes), vuelo*(FK→vuelos), rol*, estado |
| Incidentes | `/incidentes/` | vuelo(FK→vuelos), tipo*, descripcion*, gravedad, fecha*(datetime), estado |
| Asignaciones de pista | `/asignaciones-pista/` | pista*(FK→pistas), vuelo*(FK→vuelos), fecha_hora*(datetime), tipo_operacion* |
| Horarios | `/horarios/` | vuelo*(FK→vuelos), dia_semana, hora_salida*, hora_llegada*, frecuencia |
| Escalas | `/escalas/` | vuelo*(FK→vuelos), aeropuerto*(FK→aeropuertos), orden(int), duracion_minutos(int) |

### Infraestructura del aeropuerto

| Tabla | Endpoint | Campos |
|---|---|---|
| Aeropuertos | `/aeropuertos/` | nombre*, codigo_iata*, codigo_icao, ciudad*, pais*, zona_horaria |
| Puertas | `/puertas/` | numero*, terminal*(FK→terminales), estado, tipo |
| Terminales | `/terminales/` | nombre*, codigo*, aeropuerto*(FK→aeropuertos), capacidad(int) |
| Pistas | `/pistas/` | codigo*, longitud(double), estado, aeropuerto*(FK→aeropuertos) |

### Flota y mantenimiento

| Tabla | Endpoint | Campos |
|---|---|---|
| Aeronaves | `/aeronaves/` | matricula*, modelo*, aerolinea*(FK→aerolineas), tipo_aeronave*(FK→tipos-aeronave), capacidad*(int), estado |
| Tipos de aeronave | `/tipos-aeronave/` | nombre*, fabricante, capacidad_maxima(int), alcance_km(double) |
| Mantenimientos | `/mantenimientos/` | aeronave*(FK→aeronaves), tipo*, descripcion, fecha_inicio*(datetime), fecha_fin(datetime), estado |
| Certificaciones | `/certificaciones/` | tripulante*(FK→tripulantes), tipo*, numero_certificado, fecha_emision(datetime), fecha_vencimiento(datetime), estado |

### Pasajeros y personal

| Tabla | Endpoint | Campos |
|---|---|---|
| Pasajeros | `/pasajeros/` | nombre*, apellido*, documento*, pasaporte, nacionalidad, categoria_pasajero(FK→categorias-pasajero), email, telefono |
| Reservas | `/reservas/` | codigo_reserva*, pasajero*(FK→pasajeros), vuelo*(FK→vuelos), asiento, clase, estado |
| Tripulantes | `/tripulantes/` | nombre*, apellido*, documento*, cargo*, licencia, aerolinea(FK→aerolineas), estado |
| Equipajes | `/equipajes/` | pasajero*(FK→pasajeros), reserva(FK→reservas), peso(double), tipo, codigo_etiqueta, estado |
| Tarjetas de embarque | `/tarjetas-embarque/` | reserva*(FK→reservas), pasajero*(FK→pasajeros), vuelo*(FK→vuelos), asiento, puerta(FK→puertas), hora_embarque(datetime), codigo_barras |
| Categorías de pasajero | `/categorias-pasajero/` | nombre*, descripcion, prioridad(int) |

### Administración del sistema

| Tabla | Endpoint | Campos |
|---|---|---|
| Aerolíneas | `/aerolineas/` | nombre*, codigo_iata*, codigo_icao, pais, activa(bool) |
| Notificaciones | `/notificaciones/` | titulo*, mensaje*, tipo, leida(bool) |
| Perfiles de usuario | `/perfiles-usuario/` | usuario*(int, referencia al User de Django), rol*, telefono |
| Sesiones de usuario | `/sesiones-usuario/` | usuario*(int), ip, fecha_inicio(datetime), activa(bool) |
| Registro de auditoría | `/audit-log/` | usuario(int), accion*, tabla_afectada, detalle, fecha(datetime) |

**Nota:** los campos `usuario` de perfiles-usuario, sesiones-usuario y audit-log apuntan al modelo `User` propio de Django, que no es una de las 25 tablas del dominio — no tienen una entidad relacionada de la que sacar un desplegable.

---

## 2. Prompt listo para pedirle a una IA que genere las pantallas Flutter

Copia y pega esto tal cual (ajusta la URL del backend si cambia):

```
Necesito que generes una app móvil en Flutter para "SkyOps", un sistema de control de vuelos de aeropuerto. El backend ya existe: Django REST Framework en http://147.182.179.6/api/, con autenticación JWT (login, refresh token, registro, perfil de usuario).

ARQUITECTURA: Clean Architecture con esta estructura de carpetas exacta:
lib/
  main.dart
  data/
    remote/{api, dto, interceptor}
    local/
    repository/
  domain/
    model/
    repository/
  presentation/
    navigation/
    screens/
    providers/
    widgets/
  theme/
  core/{config, error, utils}

STACK: Provider (ChangeNotifier) para estado, GoRouter para navegación con guard de autenticación (redirect según JWT válido), Dio como cliente HTTP con interceptor que agrega el Bearer token y refresca en 401, flutter_secure_storage para persistir el token.

DISEÑO: Material 3, tema oscuro (fondo casi negro #0A0A0F, superficies #16161D) con acento azul (#2E5CFF). Pantalla de splash, login y registro con header tipo hero (ícono de avión, gradiente), formularios en tarjeta. Después de iniciar sesión, un "shell" principal con barra de navegación inferior custom (Home / Flights / Bookings / Profile). La pantalla Home muestra tarjetas de estadísticas (vuelos hoy, programados, retrasados, incidentes) y una lista de próximos vuelos.

ENTIDADES (25 tablas, todas necesitan pantalla de lista + formulario de creación/edición con validación):

[Pega aquí la tabla completa de la sección 1 de este documento]

REQUISITOS PARA LOS FORMULARIOS:
- Cada campo marcado como FK→otra_tabla debe mostrarse como un DropdownButtonFormField que carga las opciones de la entidad relacionada (vía su Provider) y muestra un texto legible (ej. nombre, código IATA + nombre, matrícula + modelo), NUNCA un campo de texto para escribir el ID a mano.
- Campos booleanos → Switch. Campos de fecha/hora → selector de fecha y hora. Campos numéricos → teclado numérico con validación.
- Los repositorios deben manejar la paginación de Django REST Framework (respuesta con clave "results").
- Cada entidad necesita: modelo de dominio, DTO, interfaz de repositorio, implementación de repositorio, Provider (ChangeNotifier) con listar/crear/actualizar/eliminar, pantalla de lista y pantalla de formulario.

ENTREGABLE: el código Flutter completo, organizado en los archivos de la estructura de carpetas indicada, listo para correr con `flutter run`.
```

---

Si prefieres, puedo generar automáticamente ese bloque de "ENTIDADES" ya formateado para pegarlo directo en el prompt — solo dímelo.
