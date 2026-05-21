# Integracion con Firebase y arquitectura hexagonal

Este documento explica como esta integrada Firebase en PetControl y como se organiza el proyecto bajo una arquitectura hexagonal. La idea principal es que la UI y la logica de negocio no dependan directamente de Firebase: Firebase queda encapsulado en la capa de infraestructura.

## Resumen rapido

La aplicacion usa Firebase para:

- Inicializar el proyecto con `firebase_core`.
- Autenticar usuarios con `firebase_auth`.
- Persistir datos en Cloud Firestore con `cloud_firestore`.
- Leer y escribir colecciones como `usuarios`, `mascotas`, `citas`, `personal_medico`, `historial_clinico`, `preferencia_medico` y `catalogos`.
- Mantener datos en tiempo real mediante `snapshots()`.
- Aplicar seguridad desde `firestore.rules`.

El patron hexagonal se ve asi:

```text
features/ UI
   |
   v
application/services
   |
   v
domain/repositories  <--- contratos / puertos
   ^
   |
infrastructure/repositories/firebase  <--- adaptadores Firebase
```

## Dependencias Firebase

Las dependencias principales estan en `pubspec.yaml`:

```yaml
firebase_core
firebase_auth
cloud_firestore
```

Tambien se usa `crypto` para generar hashes de correo en algunos flujos de autenticacion y usuarios pendientes.

## Configuracion del proyecto Firebase

### `firebase_options.dart`

Archivo generado por FlutterFire CLI. Contiene las opciones de Firebase por plataforma.

Ruta:

```text
lib/firebase_options.dart
```

En este proyecto tiene configuracion para:

- Web.
- Android.

El `projectId` configurado es:

```text
vetcontrol-fb44b
```

Las plataformas iOS, macOS, Windows y Linux no estan configuradas en ese archivo. Si se quiere soportarlas, hay que ejecutar de nuevo FlutterFire CLI para generar sus opciones.

### `.firebaserc`

Define el proyecto Firebase activo para Firebase CLI:

```json
{
  "projects": {
    "default": "vetcontrol-fb44b"
  }
}
```

### `firebase.json`

Declara configuracion local de Firebase:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "auth": {
    "providers": {
      "emailPassword": true
    }
  }
}
```

Aqui se indica que las reglas de Firestore estan en `firestore.rules` y que el proveedor de autenticacion por correo y contrasena esta habilitado.

## Inicializacion de Firebase

El punto de entrada esta en:

```text
lib/main.dart
```

El flujo de arranque es:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `configurarEstrategiaUrl()`.
3. `FirebaseInitializer.inicializar()`.
4. `AppDependencies.inicializar()`.
5. `runApp(const PetControlApp())`.

El inicializador esta en:

```text
lib/infrastructure/firebase/firebase_initializer.dart
```

Su responsabilidad es llamar:

```dart
Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Tambien valida `Firebase.apps.isNotEmpty` para no inicializar Firebase mas de una vez.

## Inyeccion de dependencias

El archivo central es:

```text
lib/core/di/app_dependencies.dart
```

Este archivo conecta la capa de aplicacion con la infraestructura Firebase. Por ejemplo:

```dart
static final FirebaseCitaRepository _citaRepository =
    FirebaseCitaRepository();

static final CitaService citaService = CitaService(
  citaRepository: _citaRepository,
);
```

Esto significa que `CitaService` no conoce Firestore directamente. Solo conoce el contrato `CitaRepository`. La implementacion concreta actualmente es `FirebaseCitaRepository`.

El mismo patron se repite para:

- `UsuarioService` con `FirebaseUsuarioRepository`.
- `MascotaService` con `FirebaseMascotaRepository`.
- `CitaService` con `FirebaseCitaRepository`.
- `PersonalMedicoService` con `FirebasePersonalMedicoRepository`.
- `PreferenciaMedicoService` con `FirebasePreferenciaMedicoRepository`.
- `HistorialClinicoService` con `FirebaseHistorialClinicoRepository`.
- `CatalogosJsonService` con `FirebaseCatalogosRepository`.
- `AuthService` con `FirebaseAuthIdentityRepository`, `UsuarioService` y `SessionService`.

## Archivos importantes de Firebase

### Inicializacion y configuracion

| Archivo | Responsabilidad |
| --- | --- |
| `lib/main.dart` | Punto de entrada de la app. Inicializa Firebase antes de renderizar. |
| `lib/firebase_options.dart` | Opciones generadas por FlutterFire para conectar con el proyecto Firebase. |
| `lib/infrastructure/firebase/firebase_initializer.dart` | Encapsula `Firebase.initializeApp`. |
| `.firebaserc` | Define el proyecto Firebase por defecto para CLI. |
| `firebase.json` | Configura Firestore rules, indexes y Auth provider. |
| `firestore.rules` | Reglas de seguridad de Firestore. |

### Helpers Firebase

| Archivo | Responsabilidad |
| --- | --- |
| `lib/infrastructure/firebase/firebase_paths.dart` | Centraliza nombres de colecciones. |
| `lib/infrastructure/firebase/firestore_mapper.dart` | Normaliza lectura y escritura entre Firestore y entidades Dart. |
| `lib/infrastructure/firebase/firebase_auth_profile_helper.dart` | Determina si el usuario autenticado es admin. |
| `lib/infrastructure/firebase/firebase_email_helper.dart` | Normaliza correo y genera hashes usados en usuarios pendientes. |
| `lib/infrastructure/firebase/firebase_seed_service.dart` | Migra datos iniciales desde assets a Firebase cuando es posible. |

### Repositorios Firebase

| Archivo | Coleccion / responsabilidad |
| --- | --- |
| `firebase_usuario_repository.dart` | `usuarios`, `usuarios_auth`, `usuarios_pendientes`, `accesos_iniciales`. |
| `firebase_auth_identity_repository.dart` | Firebase Auth: registro, login, logout y acceso inicial. |
| `firebase_session_repository.dart` | Obtiene la sesion actual desde `FirebaseAuth.currentUser`. |
| `firebase_mascota_repository.dart` | Coleccion `mascotas`. |
| `firebase_cita_repository.dart` | Coleccion `citas`. |
| `firebase_personal_medico_repository.dart` | Coleccion `personal_medico`. |
| `firebase_preferencia_medico_repository.dart` | Coleccion `preferencia_medico`. |
| `firebase_historial_clinico_repository.dart` | Coleccion `historial_clinico`. |
| `firebase_catalogos_repository.dart` | Coleccion `catalogos`, documento `config`. |

## Colecciones usadas en Firestore

Los nombres estan centralizados en:

```text
lib/infrastructure/firebase/firebase_paths.dart
```

Colecciones principales:

| Coleccion | Uso |
| --- | --- |
| `usuarios` | Perfil completo de usuarios. |
| `usuarios_auth` | Resumen de autenticacion por UID, usado para validar roles. |
| `usuarios_pendientes` | Usuarios creados por admin que aun no configuran contrasena. |
| `accesos_iniciales` | Marca correos pendientes para flujo de contrasena inicial. |
| `mascotas` | Mascotas registradas. |
| `citas` | Citas veterinarias. |
| `personal_medico` | Medicos / profesionales. |
| `preferencia_medico` | Preferencias de medico por usuario. |
| `historial_clinico` | Historias clinicas. |
| `catalogos` | Catalogos de motivos, estados, especialidades, filtros, etc. |

## Como funciona la autenticacion

La UI no llama directamente a Firebase Auth. El flujo pasa por:

```text
features/autenticacion
  -> AuthService
  -> AuthIdentityRepository
  -> FirebaseAuthIdentityRepository
  -> FirebaseAuth
```

Archivo principal:

```text
lib/application/services/auth_service.dart
```

Responsabilidades de `AuthService`:

- Registrar clientes.
- Iniciar sesion.
- Evaluar si un correo necesita contrasena inicial.
- Configurar contrasena inicial para usuarios pendientes.
- Resolver usuario actual.
- Cerrar sesion.

La implementacion Firebase esta en:

```text
lib/infrastructure/repositories/firebase/firebase_auth_identity_repository.dart
```

Responsabilidades de `FirebaseAuthIdentityRepository`:

- Crear cuenta con `createUserWithEmailAndPassword`.
- Iniciar sesion con `signInWithEmailAndPassword`.
- Cerrar sesion con `signOut`.
- Consultar `accesos_iniciales` para saber si un correo tiene acceso pendiente.

### Usuarios autenticados y perfiles

Firebase Auth guarda la identidad tecnica del usuario. Firestore guarda el perfil de negocio.

Cuando se registra un usuario:

1. Firebase Auth crea la cuenta y entrega un `uid`.
2. `AuthService` crea un `Usuario` de dominio.
3. `UsuarioService` guarda el perfil.
4. `FirebaseUsuarioRepository` escribe en:
   - `usuarios`.
   - `usuarios_auth`.

`usuarios_auth` es importante porque permite verificar rapidamente si el usuario actual es admin.

## Como funciona Firestore en los repositorios

Los repositorios Firebase implementan contratos definidos en `domain/repositories`.

Ejemplo:

```text
lib/domain/repositories/cita_repository.dart
```

Define el puerto:

```dart
abstract class CitaRepository {
  Future<List<Cita>> obtenerCitas();
  Stream<List<Cita>> observarCitas();
  Future<void> guardarCita(Cita cita);
  Future<void> guardarCitas(List<Cita> citas);
}
```

La implementacion concreta esta en:

```text
lib/infrastructure/repositories/firebase/firebase_cita_repository.dart
```

Ese repositorio:

- Lee citas desde Firestore.
- Observa cambios con `snapshots()`.
- Guarda una cita con `set(..., SetOptions(merge: true))`.
- Guarda varias citas usando `WriteBatch`.
- Filtra datos visibles segun si el usuario es admin o cliente.

El mismo esquema se aplica para mascotas, historial clinico y preferencias.

## Datos en tiempo real

Algunos repositorios exponen metodos `observar...()` que devuelven streams.

Ejemplo en citas:

```dart
Stream<List<Cita>> observarCitas()
```

Internamente usa:

```dart
query.snapshots()
```

Esto permite que pantallas como la agenda admin se actualicen cuando cambia Firestore.

## Reglas de seguridad

Las reglas estan en:

```text
firestore.rules
```

Ideas principales:

- Un usuario debe estar autenticado para acceder a la mayoria de datos.
- Los admin pueden leer y escribir datos globales.
- Los clientes solo pueden acceder a documentos asociados a su `id_usuario`.
- Se validan estructuras de datos con funciones como `validUsuario`, `validMascota` y `validCita`.
- Las citas validas solo aceptan estados definidos:

```text
proxima, pendiente, confirmada, finalizada, cancelada, reprogramada
```

Ejemplo de regla para citas:

```text
match /citas/{id} {
  allow read: if isAdmin() || (signedIn() && resource.data.id_usuario == request.auth.uid);
  allow create, update: if validCita(request.resource.data)
    && request.resource.data.id_cita == id
    && (isAdmin() || validOwned(request.resource.data));
  allow delete: if isAdmin() || (signedIn() && resource.data.id_usuario == request.auth.uid);
}
```

## Migracion inicial de datos

El archivo:

```text
lib/infrastructure/firebase/firebase_seed_service.dart
```

intenta migrar datos iniciales desde:

```text
assets/data/local_db_seed.json
assets/data/catalogos.json
```

El flujo se ejecuta desde:

```text
AppDependencies.inicializar()
```

El seed:

- Crea o ingresa usuarios iniciales en Firebase Auth.
- Guarda perfiles en `usuarios` y `usuarios_auth`.
- Migra catalogos al documento `catalogos/config`.
- Cierra sesion al terminar cada usuario de seed.

Si falla, captura el error y lo escribe con `debugPrint`, evitando que la app se rompa al iniciar.

## Catalogos

Los catalogos se leen mediante:

```text
lib/application/services/catalogos_json_service.dart
```

La implementacion Firebase:

```text
lib/infrastructure/repositories/firebase/firebase_catalogos_repository.dart
```

Busca primero:

```text
catalogos/config
```

Si no hay datos en Firestore, usa como respaldo:

```text
assets/data/catalogos.json
```

Esto permite que la app funcione aunque el documento de catalogos aun no exista en Firebase.

## Estructura hexagonal del proyecto

La arquitectura hexagonal separa el sistema en tres ideas:

1. Dominio: el centro de la aplicacion.
2. Aplicacion: casos de uso y reglas de orquestacion.
3. Infraestructura: adaptadores externos como Firebase o almacenamiento local.

En este proyecto se refleja asi:

```text
lib/
  domain/
    entities/
    repositories/
    constants/

  application/
    services/

  infrastructure/
    firebase/
    repositories/
      firebase/
      local/
    storage/

  features/
    admin/
    cliente/
    autenticacion/

  core/
    di/
    routes/
    theme/
```

## Capa de dominio

Ruta:

```text
lib/domain
```

Contiene:

- Entidades de negocio.
- Contratos de repositorios.
- Constantes de dominio.

Ejemplos de entidades:

- `Cita`.
- `Usuario`.
- `Mascota`.
- `PersonalMedico`.
- `HistorialClinico`.
- `PreferenciaMedico`.

Ejemplos de puertos:

- `CitaRepository`.
- `UsuarioRepository`.
- `MascotaRepository`.
- `AuthIdentityRepository`.
- `CatalogosRepository`.

La capa de dominio no debe depender de Flutter, Firebase ni detalles visuales. Su trabajo es representar el negocio.

## Capa de aplicacion

Ruta:

```text
lib/application/services
```

Contiene servicios que coordinan reglas de negocio y operaciones.

Ejemplos:

- `AuthService`.
- `CitaService`.
- `UsuarioService`.
- `MascotaService`.
- `PersonalMedicoService`.
- `HistorialClinicoService`.

Los servicios reciben repositorios por constructor. Esto permite cambiar Firebase por otra persistencia sin reescribir la logica principal.

Ejemplo conceptual:

```dart
class CitaService {
  CitaService({required CitaRepository citaRepository})
      : _citaRepository = citaRepository;

  final CitaRepository _citaRepository;
}
```

## Capa de infraestructura

Ruta:

```text
lib/infrastructure
```

Contiene adaptadores concretos para tecnologias externas.

Subcarpetas importantes:

- `firebase/`: helpers de inicializacion, rutas, mapeo y seed.
- `repositories/firebase/`: implementaciones Firestore/Auth.
- `repositories/local/`: implementaciones locales alternativas.
- `storage/`: servicios de almacenamiento local JSON.

Firebase vive aqui porque es un detalle externo. La aplicacion deberia poder seguir teniendo los mismos servicios y entidades aunque manana se cambie Firestore por otra base de datos.

## Capa de presentacion

Ruta:

```text
lib/features
```

Contiene pantallas, widgets y modelos visuales.

Ejemplos:

- `features/admin`.
- `features/cliente`.
- `features/autenticacion`.

La UI normalmente llama a servicios desde `AppDependencies`, por ejemplo:

```dart
final CitaService _citaService = AppDependencies.citaService;
```

La UI no deberia llamar directamente a `FirebaseFirestore.instance` ni a `FirebaseAuth.instance`.

## Flujo completo de una operacion

Ejemplo: confirmar una cita desde admin.

```text
Detalle de cita admin
  -> CitaService.confirmarCitaAdmin(...)
  -> CitaRepository.guardarCita(...)
  -> FirebaseCitaRepository.guardarCita(...)
  -> Firestore collection "citas"
```

Lo importante es que el widget solo dispara una intencion. El servicio define la accion de negocio y el repositorio Firebase se encarga del detalle tecnico de persistencia.

## Ventajas de esta estructura

- Menos acoplamiento con Firebase.
- Servicios mas faciles de probar.
- Posibilidad de cambiar adaptadores sin tocar la UI.
- Entidades reutilizables.
- Reglas de negocio centralizadas en servicios.
- Firestore queda aislado en infraestructura.
- Las reglas de seguridad quedan separadas en `firestore.rules`.

## Recomendaciones para mantener la arquitectura

- No usar `FirebaseFirestore.instance` dentro de widgets.
- No usar `FirebaseAuth.instance` dentro de pantallas.
- Crear o actualizar primero el contrato en `domain/repositories` cuando aparezca una nueva necesidad de persistencia.
- Implementar el contrato en `infrastructure/repositories/firebase`.
- Inyectar la implementacion desde `AppDependencies`.
- Mantener las entidades sin dependencias de Firebase.
- Usar `FirestoreMapper` para normalizar datos entre Firestore y Dart.
- Actualizar `firestore.rules` cuando se agreguen campos nuevos a una coleccion validada.
- Evitar guardar contrasenas en Firestore; la autenticacion debe manejarse con Firebase Auth.

## Resumen final

Firebase esta integrado como adaptador externo de infraestructura. La app inicia Firebase en `main.dart`, configura la instancia con `firebase_options.dart`, inyecta repositorios Firebase desde `AppDependencies` y ejecuta la logica mediante servicios de aplicacion. El dominio conserva entidades y contratos independientes. Esta separacion es la base del patron hexagonal aplicado en el proyecto.
