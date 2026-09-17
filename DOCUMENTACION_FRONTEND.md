# Documentación Frontend

> Generado a partir de una lectura directa del código fuente en `lib/`. Todo lo aquí descrito refleja el estado real del proyecto al momento del análisis (nombre del paquete: `personal`, ver `pubspec.yaml:1`). Donde no fue posible determinar algo con certeza a partir del código, se indica explícitamente **"No identificado"**.

## 1. Resumen

`personal` es una aplicación Flutter móvil de gestión de cobros/préstamos ("CobroAPP", nombre visible en `lib/src/ui/admin/pages/home/views/drawer_home.dart:253`). Permite administrar rutas de cobro, cobradores, clientes, préstamos, pagos, cajas (apertura/cierre de caja diaria) y gastos, con dos roles de usuario diferenciados por JWT: `ADMIN` y `COBRADOR` (`lib/src/ui/auth/cubit/auth_cubit.dart:99-104`).

Paquetes clave identificados en `pubspec.yaml`:
- **Manejo de estado**: `bloc` ^9.2.1 + `flutter_bloc` ^9.1.1 (patrón Cubit, no se usan Events/BLoC completos).
- **Inyección de dependencias**: `get_it` ^9.2.1 (service locator global).
- **Manejo funcional de errores**: `dartz` ^0.10.1 (tipo `Either<Failure, T>`).
- **Comparación de objetos/inmutabilidad de estados**: `equatable` ^2.1.0.
- **Cliente HTTP**: `dio` ^5.11.0.
- **Persistencia local**: `flutter_secure_storage` ^11.0.0 (solo almacenamiento seguro de token; no hay `shared_preferences`, `hive` ni `sqlite`).
- **JWT**: `jwt_decoder` ^2.0.1 (decodifica el rol y expiración del token en el cliente).
- **Internacionalización**: `intl` + `flutter_localizations` (locale `es_CO`).
- **Otros**: `url_launcher` (llamadas/WhatsApp), `cupertino_icons`.
- **No hay** paquete de routing declarativo (`go_router`, `auto_route`, etc.). La navegación es 100% Navigator 1.0 imperativo (`Navigator.push`, `MaterialPageRoute`, `Navigator.pushAndRemoveUntil`).

No existen archivos de configuración de ambientes (`.env`, `flavor`, `--dart-define`, etc.). La URL base de la API está *hardcodeada* en `lib/src/common/network/api_config.dart:2` (`http://192.168.1.3:3000`), es decir, apunta a una IP local de desarrollo.

## 2. Arquitectura

El proyecto sigue una **arquitectura en capas de tipo Clean Architecture simplificada**, organizada primero por capa técnica (`data/`, `domain/`, `ui/`) y, dentro de `ui/`, por **feature-first** (cada módulo de negocio tiene su propia carpeta con página, cubit y vistas).

Capas identificadas en `lib/src/`:

- **`domain/`**: capa de contrato, sin dependencias de Flutter en su mayoría.
  - `entities/`: modelos de dominio puros (lo que consume la UI).
  - `dto/`: objetos de transferencia usados para enviar datos al backend (`toJson()`).
  - `repository/`: interfaces abstractas (`abstract class XxxRepo`) que declaran los casos de uso disponibles, devolviendo `Either<Failure, T>`.
- **`data/`**: capa de implementación/infraestructura.
  - `model/`: subclases de las entidades de dominio que agregan `fromJson()` (patrón Model extends Entity).
  - `services/`: acceso HTTP crudo con `dio`, lanza excepciones (`ServerExceptions`).
  - `repository/`: implementaciones concretas de las interfaces de `domain/repository`, atrapan excepciones y las convierten en `Failure`.
- **`ui/`**: capa de presentación, organizada por feature (`ui/admin/pages/<feature>/`, `ui/auth/`, `ui/cobrador/`) más una carpeta transversal `ui/widgets/` con componentes reutilizables.
- **`common/`**: utilidades transversales (`network/`, `error/`, `utils/`, `theme/`, `shared/`) usadas por todas las capas.

No hay `usecases/` ni `bloc` con eventos (`Bloc<Event, State>`); el proyecto usa **Cubits** (`Cubit<State>`) que llaman directamente a los repositorios desde métodos públicos.

**No se usa** `Provider` ni `Riverpod` ni `GetX` para estado (a pesar de que existe una carpeta `common/shared` que actúa como un singleton simple de caché en memoria, ver sección 6).

### Diagrama de flujo (patrón real observado)

```
┌──────────────┐      llama métodos      ┌───────────────┐
│   Pantalla   │ ───────────────────────▶│  Cubit (BLoC)  │
│ (StatelessWidget/          ▲            │ Cubit<State>   │
│  StatefulWidget)           │            └───────┬────────┘
│  - BlocProvider            │ context.read<Cubit>()      │
│  - BlocBuilder<Cubit,State>│                    │ usa sl<Repo>() (get_it)
└──────────────┬─────────────┘                    ▼
       state.child / state.loading         ┌────────────────┐
       (la propia página se re-renderiza   │  Repository     │  (domain/repository -> interfaz)
        según los campos del State)        │  Impl           │  (data/repository -> implementación)
                                            └───────┬────────┘
                                                    │ try/catch
                                                    ▼
                                            ┌────────────────┐
                                            │    Service      │  (data/services)
                                            │  (dio.get/post) │
                                            └───────┬────────┘
                                                    ▼
                                            ┌────────────────┐
                                            │   API REST      │  (dio + interceptor Bearer token)
                                            │  (baseUrl fijo) │
                                            └───────┬────────┘
                                                    │ JSON
                                        Model.fromJson (extends Entity)
                                                    │
                                Right(Entity) ◀─────┴─────▶ Left(Failure)  (dartz Either)
                                        │                        │
                                        ▼                        ▼
                            cubit.emit(state.copyWith(...))  AppDialogUtil.error(context,...)
                                        │
                                        ▼
                            BlocBuilder reconstruye la UI
```

Particularidad del proyecto: muchas pantallas (Caja, Cliente, Ruta, Cobrador, Prestamos, Cobrador-app) **no navegan con `Navigator.push` para sub-vistas internas del mismo feature**. En su lugar, el Cubit mantiene un campo `Widget child` en el estado (`state.child`) y el `Scaffold.body` simplemente pinta `state.child`. Cambiar de "pantalla" dentro del feature es literalmente `emit(state.copyWith(child: OtraVista()))`. Ver ejemplos: `lib/src/ui/admin/pages/caja/cubit/caja_cubit.dart:37-39`, `lib/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart:52-54`, `lib/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart:44-46`.

## 3. Estructura del proyecto

```
lib/
├── main.dart                         # entry point, MaterialApp, home: AuthPage
├── get_it.dart                       # registro de dependencias (DI) con GetIt
└── src/
    ├── common/
    │   ├── error/                    # exceptions.dart, failures.dart, erros.dart (variables globales legacy)
    │   ├── network/                  # api_client.dart (Dio + interceptors), api_config.dart (baseUrl)
    │   ├── shared/                   # shared.dart: caché estática en memoria (config, rutas, cobradores, clientes)
    │   ├── theme/                    # theme.dart: AppTheme.primaryColor
    │   └── utils/                    # app_dialog_util, date_util, contact_util, update_util, secure_storage_util
    ├── data/
    │   ├── model/                    # *Model extends *Entity + fromJson()
    │   ├── repository/                # *RepoImpl implements domain/repository/*
    │   └── services/                  # *Service / *ServiceImpl (llamadas Dio)
    ├── domain/
    │   ├── dto/                       # *Dto (toJson()) para requests
    │   ├── entities/                  # *Entity (modelos de dominio)
    │   └── repository/                # interfaces abstractas *Repo / *Repository
    └── ui/
        ├── auth/                      # login (AuthPage, AuthCubit)
        ├── admin/
        │   ├── pages/
        │   │   ├── home/              # HomePage + bottom nav (shell del rol ADMIN)
        │   │   ├── caja/              # apertura/cierre de caja, arqueo
        │   │   ├── clientes/          # CRUD de clientes
        │   │   ├── cobradores/        # CRUD de cobradores
        │   │   ├── config/            # configuración de negocio (intereses, días, periodos)
        │   │   ├── contabilidad/      # pantalla de reportes (datos mock, sin cubit)
        │   │   ├── prestamos/         # creación y gestión de préstamos
        │   │   └── rutas/             # CRUD de rutas, histórico de caja
        │   └── views/                 # vistas compartidas entre features admin (form_client_view, detalle_cliente_view)
        ├── cobrador/                  # shell y flujo específico del rol COBRADOR (cobro en calle)
        └── widgets/                   # BtnWidget, InputWidget, HeaderWidget (componentes reutilizables)
```

Convención de carpetas por feature (ver sección 10): `cubit/` (con `*_cubit.dart` + `*_state.dart` como `part of`), `views/` (subvistas mostradas vía `state.child`), y el archivo raíz `*_page.dart` que hace de shell/`BlocProvider`.

## 4. Features

### 4.1 Auth (login)
- **Ubicación**: `lib/src/ui/auth/`
- **Pantalla principal**: `AuthPage` (`auth_page.dart`) — formulario de usuario/contraseña.
- **Estado**: `AuthCubit` / `AuthState` (`cubit/auth_cubit.dart`, `cubit/auth_state.dart`).
- **Repository/Service**: `AuthRepository` → `AuthRepoImpl` → `AuthService`/`AuthServiceImpl` (`POST /credencial/login`).
- **Models**: `AuthModel`/`AuthEntity`, `UsuarioModel`/`UsuarioEntity`.
- **Rutas relacionadas**: pantalla inicial de la app (`home` de `MaterialApp`, `main.dart:45`).
- **Funcionalidad**: autentica, guarda el token en `flutter_secure_storage`, decodifica el JWT para leer `rol` y redirige a `HomePage` (ADMIN) o `HomeCobrador` (COBRADOR). Al abrir la app también revalida el token existente (`_validateToken`) para auto-login.

### 4.2 Home (shell ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/home/`
- **Pantalla**: `HomePage` — `Scaffold` con `Drawer` (`DrawerHome`) y `BottomNavWidget` de 4 pestañas: Inicio (`ResumeHomeView`), Cobradores (`CobradorPage`), Clientes (`Clientepage`), Préstamos (`PrestamosPage`).
- **Estado**: `HomeCubit`/`HomeState` — maneja `currentIndex` (tab activo), `loadPay` (overlay de carga global al pagar) y `asignarPrestamo` (bandera para saltar directo a crear préstamo tras crear un cliente).
- **Repository**: `PagoRepo` (acción `pagar`, usada desde el resumen de inicio).
- **Funcionalidad**: actúa como shell/contenedor de navegación con `IndexedStack`-like `switch` (`getChild`), y como puente entre features (ClienteCubit y PrestamoCubit disparan cambios de tab en `HomeCubit` vía `context.read<HomeCubit>()`).

### 4.3 Drawer / navegación secundaria
- **Ubicación**: `lib/src/ui/admin/pages/home/views/drawer_home.dart`
- Da acceso a: Rutas (`RutaPage`), Contabilidad (`ContabilidadPage`), Configuración (`ConfigPage`) y Cerrar sesión (borra el storage seguro y navega a `AuthPage`). El ítem "Mi perfil" está comentado/no implementado (`drawer_home.dart:36-42`).

### 4.4 Cobradores (gestión, vista ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/cobradores/`
- **Estado**: `CobradorCubit`/`CobradorState` — usa patrón `child` interno (`CobradorHome`, formularios de creación/edición/detalle).
- **Repository/Service**: `UsuarioRepository`/`UsuarioRepoImpl`/`UsuarioService` (`GET /usuario/cobradores`, `GET /usuario/cobrador/:id`, `POST` crear, `PATCH` editar) y `RutaRepo` (para el selector de rutas al crear).
- **Models/DTO**: `CobradorEntity`/`DatumCEntity`, `CrearCobradorDto`.
- **Funcionalidad**: listar, crear, editar y ver detalle de cobradores; valida campos obligatorios con `enbaledBtn`.

### 4.5 Clientes (ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/clientes/`
- **Estado**: `ClienteCubit`/`ClienteState` — listar, crear, editar, buscar y ver detalle de clientes; sub-vistas vía `state.child` (`ClientHome`, `CreateClientView`, `ClienteDetalleView`).
- **Repository/Service**: `ClienteRepository`/`ClienteRepoImpl`/`ClienteService` (`GET /cliente`, `POST /cliente`, `GET /cliente/:id`, `GET /cliente/buscar?q=`, `PATCH` editar) y `RutaRepo` (carga rutas para el formulario).
- **Models/DTO**: `ClienteEntity`/`DatumClEntity`, `CrearClienteDto`.
- **Integración cruzada**: al crear un cliente, dispara `HomeCubit.onCurrenteIndex(3)` y `onAsignarPrestamo(true)` para llevar al usuario directo a crear un préstamo en la pestaña de Préstamos (`cliente_cubit.dart:88-91`), y guarda el id en `Shared.setIdCliente`.

### 4.6 Rutas (ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/rutas/`
- **Estado**: `RutaCubit`/`RutaState` — CRUD de rutas, asignación de cobrador, listado paginado de clientes por ruta, histórico de cajas por ruta.
- **Repository/Service**: `RutaRepo`/`RutaRepoImpl`/`RutaService` (`GET/POST /ruta`, `PATCH /ruta/:id`, `GET /ruta/cobrador`, `GET /ruta/resumen/:ids`, `GET /ruta/movimiento/:id`), además `CajaRepo` (histórico), `ClienteRepository` y `UsuarioRepository` (selección de cobrador).
- **Models/DTO**: `RutasEntity`/`DatumREntity`, `RutaDto`, `MovimientoRutaEntity`.
- **Funcionalidad**: crear/editar rutas con capital y cobrador asignado, ver movimientos e histórico de cajas cerradas.

### 4.7 Préstamos (ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/prestamos/`
- **Estado**: `PrestamoCubit`/`PrestamoState` — el cubit más complejo del proyecto: calcula interés, valor de cuota, genera fechas de pago según configuración de días habilitados (`Shared.getConfig`), genera cuotas esperadas para préstamos "históricos" (retroactivos), crea préstamos nuevos y revierte pagos.
- **Repository/Service**: `PresamoRepo`/`PrestamoRepoImpl`/`PrestamoService` (`POST /prestamo`, `POST /pago/historico`, `GET /prestamo`, `GET /prestamo/:id`), `ClienteRepository`, `ConfiguracionRepository`, `PagoRepo` (`revertirPago` vía `PATCH /pago/:id/reversar`).
- **Models/DTO**: `PrestamoEntity`/`DatumPEntity`, `CrearPrestamoDto`, `CuotaEsperadaDto`, `PrestamoFechaDto`, `RevertirPagoDto`.
- **Funcionalidad**: crear préstamo (con cálculo de interés/seguro/cuota), asignar préstamo automáticamente a un cliente recién creado (flag `asignarPrestamo` desde `HomeCubit`), listar y ver detalle, revertir pagos.

### 4.8 Caja
- **Ubicación**: `lib/src/ui/admin/pages/caja/`
- **Pantalla**: `CajaPage(rutaId)` — `StatefulWidget` que crea su propio `CajaCubit` en `initState` (no usa `BlocProvider.create` inline con `context`, sino que guarda instancia en el State).
- **Estado**: `CajaCubit`/`CajaState` — abre caja (`AbrirCajaView`), consulta caja del día (`obtenerCajas`), muestra detalle (`DetalleCaja`), gestiona gastos asociados a la caja, hace arqueo (calcula diferencia entre dinero esperado y recibido) y cierra caja (`dialogo_cerrar_caja.dart`, `dialogo_arqueo.dart`).
- **Repository/Service**: `CajaRepo`/`CajaRepoImpl`/`CajaService` (`GET /caja/:rutaId?q=fecha`, `POST /caja`, `POST /caja/cerrar/:cajaId`, `GET /caja/detalle/:rutaId`) y `GastosRepo`.
- **Models/DTO**: `CajaEntity`/`DatumCajaEntity`, `CajaDto`.
- **Funcionalidad**: control diario de caja por ruta (apertura con monto inicial, seguimiento de cobros/gastos/interés/esperado, cierre con arqueo de diferencia).

### 4.9 Gastos
- No tiene página propia independiente; se consume desde `CajaCubit` (ADMIN) y desde `CobradorRCubit` (rol COBRADOR, `dialogo_gasto.dart`).
- **Repository/Service**: `GastosRepo`/`GastosRepoImpl`/`GastosService` (`POST /gastos`, `GET /gastos/:cajaId`).
- **Models/DTO**: `GastoEntity`/`GastoElementEntity`, `CrearGastoDto`.

### 4.10 Configuración (ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/config/`
- **Estado**: `ConfigCubit`/`ConfigState` — configura interés/seguro por defecto, días de cobro habilitados y periodos de cobro (con su cantidad de días).
- **Repository/Service**: `ConfiguracionRepository`/`ConfiguracionRepoImpl`/`ConfiguracionService` (`GET /confi-prestamo/prestamos`, `POST` guardar — endpoint exacto de guardado no confirmado visualmente pero sigue el mismo patrón `apiClient.dio.post`).
- **Models/DTO**: `ConfigEntity`/`DataConEntity`/`ConfiguracionEntity`/`SCobroEntity`, `ConfigDto`/`ConfiguracionDto`/`DiasCobroDto`/`PeriodosCobroDto`.
- **Funcionalidad**: esta configuración se cachea en `Shared.setConfig` y es consumida por `PrestamoCubit` para generar fechas de pago automáticamente.

### 4.11 Contabilidad (ADMIN)
- **Ubicación**: `lib/src/ui/admin/pages/contabilidad/contabilidad_page.dart`
- **Estado**: **No tiene Cubit**. Es un `StatefulWidget` con estado local (`_fechaSeleccionada`) que renderiza **datos hardcodeados/mock** (`'\$850.000'`, `'125'`, etc., ver líneas 53-89). No consume ningún repository/service.
- **Estado actual**: **No implementado / prototipo visual** (ver sección 11).

### 4.12 Módulo Cobrador (shell y flujo del rol COBRADOR)
- **Ubicación**: `lib/src/ui/cobrador/`
- **Pantalla**: `HomeCobrador` (`home_cobrador.dart`) — shell equivalente a `HomePage` pero para el rol de cobrador en campo.
- **Estado**: `CobradorRCubit`/`CobradorRState` (nombrado distinto al `CobradorCubit` de administración, aunque cubre un dominio similar desde otra perspectiva) — obtiene las rutas asignadas al cobrador logueado, resumen de ruta, mapa `rutaId → cajaId`, gastos por ruta, lista de clientes pendientes/pagados de la ruta, registra pagos y gastos.
- **Repository/Service**: `RutaRepo` (`rutaCobrador`, `resumen`, `detalleRuta`), `PagoRepo` (`pagar`), `GastosRepo` (`crearGasto`, `listarGastos`).
- **Sub-vistas** (vía `state.child`): `CHome` (home del cobrador), `Clientes` (listado de clientes a cobrar/cobrados).
- **Models/DTO**: `DetalleRutaEntity`, `PagoDto`, `CrearGastoDto`.
- **Funcionalidad**: pantalla operativa para que el cobrador vea su ruta del día, cobre cuotas y registre gastos de caja en calle.

## 5. Navegación

**Mecanismo**: Navigator 1.0 imperativo puro. No hay `go_router`, `auto_route` ni tabla de rutas nombradas (`routes:` no se usa en `MaterialApp`, ver `main.dart:22-47`). Toda navegación entre pantallas de alto nivel se hace con `Navigator.push(context, MaterialPageRoute(builder: (_) => Pantalla()))` o `Navigator.pushAndRemoveUntil(...)` (para login/logout, limpiando el stack).

**Pantalla inicial**: `AuthPage` (`main.dart:45`, `home: const AuthPage()`).

**Guards/redirecciones**: no hay un guard declarativo centralizado. La única "redirección" ocurre en `AuthCubit._validateToken()` (`auth_cubit.dart:94-107`): al abrir la app, si hay un token válido y no expirado en `flutter_secure_storage`, se decodifica el rol con `jwt_decoder` y se redirige con `pushAndRemoveUntil` a `HomePage` (rol `ADMIN`) o `HomeCobrador` (rol `COBRADOR`), evitando así que el usuario vea el formulario de login. No hay protección de rutas individuales más allá de esto (p. ej. no hay chequeo de rol al entrar a cada pantalla; se asume que solo se navega desde el shell correcto).

**Navegación intra-feature**: como se describió en la sección 2, dentro de cada feature (Caja, Clientes, Rutas, Cobradores, Préstamos, Cobrador) el cambio de "vista" no usa el `Navigator` sino que reemplaza un widget `state.child` dentro del mismo `Scaffold`, mediante métodos como `onEventChild`, `setChild`, `onGetChild`, `eventChild`, `onEventListClient`, todos con la misma firma `void algunNombre(Widget child) => emit(state.copyWith(child: child))`.

**Parámetros de navegación**: se pasan como constructores normales de `Widget` (p. ej. `CajaPage({required this.rutaId})`, `RutaPage({this.showDetail = false, this.ruta})`), no vía argumentos de ruta.

### Mapa de navegación (texto)

```
AuthPage (inicial)
 ├─ [login exitoso, rol ADMIN]  ─▶ HomePage  (pushAndRemoveUntil)
 └─ [login exitoso, rol COBRADOR] ─▶ HomeCobrador (pushAndRemoveUntil)

HomePage (Drawer + BottomNav)
 ├─ BottomNav 0: ResumeHomeView (inline, sin push)
 ├─ BottomNav 1: CobradorPage (inline, sin push)
 ├─ BottomNav 2: Clientepage (inline, sin push)
 ├─ BottomNav 3: PrestamosPage (inline, sin push)
 ├─ Drawer → RutaPage           (Navigator.push)
 ├─ Drawer → ContabilidadPage   (Navigator.push)
 ├─ Drawer → ConfigPage         (Navigator.push)
 └─ Drawer → Cerrar sesión → AuthPage (pushAndRemoveUntil)

 CobradorPage / Clientepage / RutaPage / PrestamosPage
   └─ (dentro de cada una) cambian de "sub-pantalla" vía state.child,
      p. ej. Clientepage: ClientHome ⇄ CreateClientView ⇄ ClienteDetalleView

 RutaPage → (tap en ruta) → CajaPage(rutaId)  [ver uso en ruta_detalle_view / ruta_home, no confirmado línea exacta]

HomeCobrador
 └─ state.child: CHome ⇄ Clientes (listado de cobro)
```

No identificado con certeza: el archivo exacto desde el que se navega hacia `CajaPage` (se confirma que `CajaPage` requiere `rutaId` y se usa desde el contexto de Rutas, pero no se leyó línea por línea el `onTap` del listado de rutas que dispara el push).

## 6. Manejo de estado

Patrón usado: **Cubit de `flutter_bloc`** (no BLoC con eventos). Convenciones observadas en *todos* los cubits del proyecto:

- Cada feature tiene `cubit/<feature>_cubit.dart` con `class XCubit extends Cubit<XState>` y `part 'x_state.dart'`.
- El archivo de estado (`x_state.dart`) empieza con `part of 'x_cubit.dart'` y define `class XState extends Equatable` inmutable con `copyWith`.
- El estado casi siempre incluye un campo `BuildContext context` (guardado al construir el cubit) para poder mostrar diálogos (`AppDialogUtil`) o navegar sin necesidad de pasar el `context` en cada método.
- Los repositorios se obtienen vía service locator: `final _xRepo = sl<XRepo>();` (import de `personal/get_it.dart`).
- Flags de carga separados por granularidad: `loading` (carga de página completa), `loadingBtn`/`btnLoading` (carga de un botón específico, para no bloquear toda la UI), y a veces un flag booleano de "habilitado" (`btnEnabled`, `enabledBtn`) para formularios.
- Patrón estándar de petición:
  ```
  emit(state.copyWith(loading/btnLoading: true));
  final r = await _repo.metodo(...);
  r.fold(
    (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
    (r) => { actualizar estado / mostrar AppDialogUtil.success / refrescar listado },
  );
  emit(state.copyWith(loading/btnLoading: false));
  ```
- Errores: el mensaje mostrado al usuario es `failure.props[0].toString()` (el primer valor de `props` de la clase `Failure`, que en la práctica es el campo `message`). Este patrón se repite en absolutamente todos los cubits.

Cubits identificados y su responsabilidad (detalle también en sección 4):

| Cubit | Ubicación | Responsabilidad |
|---|---|---|
| `AuthCubit` | `ui/auth/cubit/` | Login, validación/decodificación de token, redirección por rol |
| `HomeCubit` | `ui/admin/pages/home/cubit/` | Shell ADMIN: tab activo, overlay de pago, bandera de asignar préstamo |
| `ClienteCubit` | `ui/admin/pages/clientes/cubit/` | CRUD clientes, búsqueda, integración con `Shared` y `HomeCubit` |
| `CobradorCubit` | `ui/admin/pages/cobradores/cubit/` | CRUD cobradores (vista ADMIN) |
| `RutaCubit` | `ui/admin/pages/rutas/cubit/` | CRUD rutas, movimientos, histórico de caja |
| `PrestamoCubit` | `ui/admin/pages/prestamos/cubit/` | Cálculo y creación de préstamos, cuotas, reversión de pagos |
| `CajaCubit` | `ui/admin/pages/caja/cubit/` | Apertura/cierre/arqueo de caja, gastos de caja |
| `ConfigCubit` | `ui/admin/pages/config/cubit/` | Configuración global de negocio (interés, días, periodos) |
| `CobradorRCubit` | `ui/cobrador/cubit/` | Flujo operativo del rol COBRADOR (ruta, cobro, gasto en campo) |

**Caché en memoria (no es un state manager, pero se usa junto a los cubits)**: `Shared` (`lib/src/common/shared/shared.dart`) es una clase con **campos y setters/getters `static`** que guarda en memoria (no persistente) la última configuración, lista de cobradores, rutas y clientes cargados, además del `idCliente` seleccionado para flujos cruzados (crear cliente → crear préstamo). Varios cubits consultan `Shared.getX` antes de volver a pedir datos al backend, actuando como caché simple de sesión (ver `cliente_cubit.dart:98-104`, `prestamo_cubit.dart:82-107`).

También existe `lib/src/common/error/erros.dart`, un archivo con variables globales sueltas (`_message`, `_code`, `StreamController<bool> codeSent`) que **no parece estar consumido activamente** en los cubits revisados — posible remanente de un flujo anterior (ej. verificación por código). **No identificado** su uso actual real.

## 7. Services y Repositories

Patrón uniforme en todo el proyecto (un trío Service/Repository interface/Repository impl por dominio):

- **Service** (`data/services/*_service.dart`): define una interfaz abstracta `abstract class XService` y su implementación `class XServiceImpl implements XService`. Recibe `ApiClient apiClient` por constructor. Cada método llama a `apiClient.dio.get/post/patch(...)`, envuelve la llamada en `try/catch`: captura `DioException` y relanza como `ServerExceptions(message: e.response!.data["message"])`, y cualquier otro error como `Exception("Error inesperado")`. Devuelve directamente un `Model` (`Model.fromJson(response.data)`).
- **Repository interface** (`domain/repository/*_repo.dart`): interfaz abstracta que declara los métodos de negocio devolviendo `Future<Either<Failure, T>>`.
- **Repository impl** (`data/repository/*_repo_impl.dart`): implementa la interfaz, llama al Service correspondiente, y traduce excepciones a `Failure` con `try { ... return Right(x); } on ServerExceptions catch(e) { return Left(ServerFailure(message: e.message)); } catch(e) { return Left(ServerFailure(message: "Error inesperado: $e")); }`.

Todos los repos/servicios se registran como **lazy singletons** en `lib/get_it.dart` (`sl.registerLazySingleton<Interfaz>(() => Implementacion(dependencia: sl()))`), inyectando primero `SecureStorageUtil` y `ApiClient`.

**Cliente HTTP** (`lib/src/common/network/api_client.dart`): instancia única de `Dio` con `baseUrl`, timeouts de 15s (connect/receive/send) desde `ApiConfig`. Interceptores:
1. `InterceptorsWrapper.onRequest`: lee el token guardado en `flutter_secure_storage` (`preferences.read('token')`) y, si existe, agrega el header `Authorization: Bearer <token>` a cada petición. Este es el único mecanismo de autenticación de requests — no hay refresh token ni interceptor de reintentos/401 (**no identificado** manejo de expiración de sesión más allá de la validación local del JWT al abrir la app).
2. `LogInterceptor` con `requestBody`/`responseBody` en `true` — logging de requests/responses activo (no condicionado a modo debug), relevante para producción.

Listado de pares Service/Repository y sus endpoints REST detectados:

| Dominio | Repository (interfaz) | Service | Endpoints (método y ruta) |
|---|---|---|---|
| Autenticación | `AuthRepository` | `AuthService` | `POST /credencial/login` |
| Usuarios/Cobradores | `UsuarioRepository` | `UsuarioService` | `GET /usuario/cobradores`, `GET /usuario/cobrador/:id`, `POST` crear, `PATCH` editar |
| Clientes | `ClienteRepository` | `ClienteService` | `GET /cliente`, `POST /cliente`, `GET /cliente/:id`, `GET /cliente/buscar?q=`, `PATCH` editar |
| Rutas | `RutaRepo` | `RutaService` | `POST /ruta`, `GET /ruta`, `PATCH /ruta/:id`, `GET /ruta/cobrador`, `GET /ruta/resumen/:idsRuta`, `GET /ruta/movimiento/:idRuta` |
| Préstamos | `PresamoRepo` | `PrestamoService` | `POST /prestamo`, `POST /pago/historico`, `GET /prestamo`, `GET /prestamo/:id` |
| Pagos | `PagoRepo` | `PagoService` | `POST /pago`, `PATCH /pago/:idPago/reversar` |
| Caja | `CajaRepo` | `CajaService` | `GET /caja/:rutaId?q=fecha`, `POST /caja`, `POST /caja/cerrar/:cajaId`, `GET /caja/detalle/:rutaId` |
| Gastos | `GastosRepo` | `GastosService` | `POST /gastos`, `GET /gastos/:cajaId` |
| Configuración | `ConfiguracionRepository` | `ConfiguracionService` | `GET /confi-prestamo/prestamos`, `POST` guardar (endpoint exacto de guardado no confirmado con certeza en el código leído) |

Nota: el repositorio de nombre `presamo_repo.dart` (`PresamoRepo`) tiene una falta de ortografía en el nombre del archivo/interfaz (debería ser "prestamo"), es una convención real del código, no un error de esta documentación.

## 8. Models y DTOs

Patrón: **`Model extends Entity`** — el modelo de datos (`data/model/*_model.dart`) hereda de la entidad de dominio (`domain/entities/*_entity.dart`) y añade únicamente un constructor factory `fromJson(Map<String, dynamic> json)`. La entidad de dominio no sabe nada de JSON; solo el modelo. Ejemplo representativo: `AuthModel extends AuthEntity` (`data/model/auth_model.dart:7-14`), `CajaModel extends CajaEntity` / `DatumCajaModel extends DatumCajaEntity` (`data/model/caja_model.dart`).

Las entidades "envoltorio de respuesta" siguen casi todas la misma forma `{ exito: bool, msg: String, data: List<Datum...Entity>, pagination?: PaginationEntity }`, reflejando el formato de respuesta estándar de la API (`CajaEntity`, `ClienteEntity`, `PrestamoEntity`, `RutasEntity` — nombres de clase confirmados por lectura directa de `caja_entity.dart`, `cliente_entity.dart`, `prestamo_entity.dart`).

**DTOs** (`domain/dto/*_dto.dart`): objetos planos con constructor (a veces con parámetros opcionales/nullable para soportar "edición parcial") y método `toJson()` que arma el body del request. Patrón de edición parcial notable: `UpdateUtil.valorModificado(original, nuevo)` (`common/utils/update_util.dart`) devuelve `null` si el valor no cambió, de forma que los DTO de edición (`CrearClienteDto`, `CrearCobradorDto`) solo envían al backend los campos realmente modificados (los `toJson()` de estos DTO usan `if (campo != null) "campo": campo` — visto explícitamente en `CajaDto.toJson()`, `domain/dto/caja_dto.dart:22-31`, y se infiere el mismo patrón para `CrearClienteDto`/`CrearCobradorDto` por su uso en `cliente_cubit.dart:116-138` y `cobrador_cubit.dart:147-160`).

Entidades de dominio identificadas (`lib/src/domain/entities/`): `auth_entity.dart` (`AuthEntity`, `UsuarioEntity`), `caja_entity.dart` (`CajaEntity`, `DatumCajaEntity`), `cliente_entity.dart` (`ClienteEntity`, `DatumClEntity`), `cobrador_entity.dart`, `config_entity.dart` (`ConfigEntity`, `DataConEntity`, `ConfiguracionEntity`, `SCobroEntity` — usada tanto para días de cobro como para periodos de cobro), `detalle_ruta_entity.dart`, `gasto_entity.dart`, `movimiento_ruta_entity.dart`, `pagination_entity.dart` (`PaginationEntity`: `page`, `limit`, `total`, `totalPages`, `hasNextPage`, `hasPreviousPage`), `pago_entity.dart`, `prestamo_entity.dart` (`PrestamoEntity`, `DatumPEntity`, `FechasPagoPEntity`), `ruta_entity.dart`.

DTOs identificados (`lib/src/domain/dto/`): `auth_dto.dart`, `caja_dto.dart`, `config_dto.dart`, `crear_cliente_dto.dart`, `crear_cobrador_dto.dart`, `crear_prestamo_dto.dart`, `cuota_esperada_dto.dart`, `gasto_dto.dart`, `pago_dto.dart`, `prestamo_fecha_dto.dart`, `revertir_pago_dto.dart`, `ruta_dto.dart`.

Parseo de fechas: los modelos usan `DateTime.parse(json["campo"] ?? DateTime.now().toIso8601String())` — si el backend no envía la fecha, se usa "ahora" como valor por defecto en lugar de null (comportamiento a tener en cuenta, puede ocultar datos faltantes). Formateo de fecha de salida (para requests) se centraliza en `DateUtil.formatDate` (`common/utils/date_util.dart`), formato `yyyy-MM-dd`.

## 9. UI y componentes reutilizables

**Theme** (`lib/src/common/theme/theme.dart`): extremadamente minimalista — `AppTheme.primaryColor` (`Colors.blue`) es el único valor centralizado. No hay `ThemeData` custom con `ColorScheme`, tipografías, ni `ThemeExtension`; el `ThemeData` de `MaterialApp` (`main.dart:39-43`) solo define `textTheme.bodyMedium` con `fontSize: 16`. El resto de estilos (colores de texto, radios, sombras) están **hardcodeados por pantalla** con valores hex directos (p. ej. `Color(0xFFF5F7FC)`, `Color(0xFF202838)`, repetidos en decenas de archivos) en vez de reutilizar tokens de un theme central. Esto es una inconsistencia real del proyecto, no una limitación de esta documentación.

**Widgets globales reutilizables** (`lib/src/ui/widgets/`, exportados desde `widgets.dart`):
- `BtnWidget.btn(...)` (`btn_widget.dart`): botón `ElevatedButton` parametrizable con texto, ícono, estado `loading` (muestra `CircularProgressIndicator`) y `enabled`. Es el botón estándar usado en casi todos los formularios.
- `InputWidget.input(...)` (`input_widget.dart`): `TextFormField` estandarizado con label, hint, prefijo/sufijo de ícono, validación, tipo de teclado, `obscureText`, etc. Es el input estándar de todos los formularios.
- `HeaderWidget` (`header_widget.dart`): contenedor con gradiente (`AppTheme.primaryColor`) y bordes inferiores redondeados, usado como cabecera decorativa reutilizable (aunque varias pantallas también reimplementan manualmente su propio `_header()` con el mismo gradiente en vez de usar este widget, p. ej. `config_page.dart:157-201` y `form_client_view.dart:330-377`).
- `AppDialogUtil` (`common/utils/app_dialog_util.dart`): utilitario estático para mostrar `AlertDialog` de error/éxito/info de forma consistente (`AppDialogUtil.error/success/info`). Es el mecanismo estándar de feedback de errores/éxitos de toda la app (usado en el `.fold()` de prácticamente todos los cubits).
- `BottomNavWidget` (`ui/admin/pages/home/views/button_navigationa_view.dart`): barra de navegación inferior custom (no usa `BottomNavigationBar` de Material, sino un `Row` de ítems animados).

**Otros widgets compartidos entre features** (fuera de `ui/widgets/`, en `ui/admin/views/`): `FormClientView` (formulario completo de cliente, reutilizado por crear/editar) y `DetalleClienteView`.

**Utils comunes** (`lib/src/common/utils/`): `SecureStorageUtil` (wrapper singleton de `flutter_secure_storage`), `DateUtil` (formateo `yyyy-MM-dd`), `ContactUtil` (abre `tel:`/`whatsapp:` vía `url_launcher`), `UpdateUtil` (diffing de campos para ediciones parciales), `AppDialogUtil` (diálogos).

No existe un sistema de diseño formal (no hay `design_system/`, ni componentes tipo `AppCard`, `AppText`, etc.) — cada feature construye sus propias tarjetas y secciones con `Container` + `BoxDecoration` repetidos manualmente.

## 10. Convenciones

Convenciones reales observadas de forma consistente en el código (no se documentan reglas no evidenciadas):

- **Nombres de archivo**: `snake_case.dart`. Carpeta de feature en `ui/admin/pages/<feature>/`, con subcarpetas `cubit/` y `views/`.
- **Cubit + State como `part`**: el estado siempre vive en un archivo separado `*_state.dart` con `part of '*_cubit.dart'`, nunca en el mismo archivo que el cubit ni como archivo totalmente independiente.
- **Estado con `context`**: casi todos los `State` guardan `BuildContext context` para poder disparar `AppDialogUtil` y, en algunos casos, `context.read<OtroCubit>()` (comunicación cross-feature, ver `ClienteCubit`↔`HomeCubit`, `PrestamoCubit`↔`HomeCubit`).
- **DI vía `sl<T>()`**: cualquier repositorio se obtiene como `final _xRepo = sl<XRepo>();` dentro del cubit, importando `package:personal/get_it.dart`. Nunca se instancian repositorios/servicios directamente con `XRepoImpl(...)` fuera de `get_it.dart`.
- **Registro en `get_it.dart`**: todo nuevo repositorio/servicio se agrega como `registerLazySingleton` en bloques comentados por dominio (`// CLIENTE`, `// CAJA`, etc.), primero el repo (que depende del service) y luego el service (que depende de `ApiClient`).
- **Manejo de errores uniforme**: `Either<Failure, T>` de `dartz`; en la UI/cubit siempre se resuelve con `.fold((l) => AppDialogUtil.error(...), (r) => {...})`. El mensaje de error mostrado es `l.props[0].toString()`.
- **Consumo de API**: siempre a través de `ApiClient.dio` inyectado, nunca se crea una instancia de `Dio` fuera de `ApiClient`. Los `Service` son los únicos que conocen las rutas del backend.
- **Loading states separados**: `loading` para carga de pantalla completa vs. `loadingBtn`/`btnLoading` para acciones puntuales (evita bloquear toda la UI en cada submit).
- **Sub-navegación por `state.child`**: para cambiar de "sub-pantalla" dentro de un mismo feature se emite un nuevo `Widget` en el estado, no se usa `Navigator` (ver sección 2 y 5).
- **Formularios**: se validan manualmente concatenando `TextEditingController`s y comprobando `.text.isNotEmpty` en métodos tipo `enabledBtn()`/`btnEnabled()`/`enbaledBtn()`/`validarForm()`/`formValid()`, casi nunca con `Form` + `GlobalKey<FormState>` + `validator` real de Flutter (los `validator` de `InputWidget` existen como parámetro pero rara vez se usan).
- **Caché de catálogos**: listas que cambian poco (rutas, cobradores, config, clientes) se cachean en `Shared` (`common/shared/shared.dart`) y se consultan con `if (Shared.getX == null) { ...pedir al backend... }` antes de volver a llamar a la API.
- **Idioma**: toda la UI, mensajes y nombres de variables/métodos están en español; el código (nombres de clases/métodos) también mezcla español e inglés libremente (p. ej. `onGetChild`, `crearCliente`).

## 11. Estado actual

| Área | Estado | Evidencia |
|---|---|---|
| Autenticación (login, persistencia de token, auto-login por rol) | **Implementado** | `auth_cubit.dart`, `secure_storage_util.dart` |
| Gestión de Clientes (listar/crear/editar/buscar/detalle) | **Implementado** | `cliente_cubit.dart` |
| Gestión de Cobradores (listar/crear/editar/detalle) | **Implementado** | `cobrador_cubit.dart` (admin) |
| Gestión de Rutas (CRUD, movimientos, histórico) | **Implementado** | `ruta_cubit.dart` |
| Préstamos (creación con cálculo de interés/cuotas/fechas, listado, detalle, reversión de pago) | **Implementado** | `prestamo_cubit.dart` |
| Caja (apertura, consulta diaria, gastos asociados, arqueo, cierre) | **Implementado** | `caja_cubit.dart` |
| Gastos de caja | **Implementado** | `gastos_repo_impl.dart`, uso desde `CajaCubit` y `CobradorRCubit` |
| Configuración de negocio (interés/seguro por defecto, días y periodos de cobro) | **Implementado** | `config_cubit.dart` |
| Flujo operativo de Cobrador en campo (ver ruta, cobrar, registrar gasto) | **Implementado** | `cobrador_cubit.dart` (`ui/cobrador/`) |
| Contabilidad / reportes | **No implementado** (solo maqueta visual con datos hardcodeados, sin Cubit ni consumo de API) | `contabilidad_page.dart:53-224` |
| Perfil de usuario ("Mi perfil" en el Drawer) | **No implementado** (código de navegación comentado) | `drawer_home.dart:36-42` |
| Cierre de sesión (logout) | **Implementado** parcialmente vía UI (borra storage y navega a `AuthPage`), pero **no invoca** ningún método de `AuthCubit.logout()` (está comentado) ni al backend | `drawer_home.dart:319-325` |
| Refresh token / expiración de sesión durante uso activo | **No identificado** (solo se valida el JWT al abrir la app; no hay interceptor de 401 ni renovación automática) | `api_client.dart`, `auth_cubit.dart:94-107` |
| Configuración de ambientes (dev/staging/prod) | **No implementado** (URL fija en `api_config.dart`) | `api_config.dart:2` |
| Validación de formularios con `Form`/`validator` nativo de Flutter | **Parcial** (existe el soporte en `InputWidget` pero la mayoría de pantallas validan manualmente con banderas booleanas) | `input_widget.dart`, múltiples cubits |
| Theming centralizado (colores/tipografía consistentes) | **Parcial** (solo `primaryColor` centralizado; el resto de estilos están repetidos por pantalla) | `theme.dart` vs. uso de `Color(0xFF...)` en decenas de archivos |
| Manejo de errores de red específico (timeout, sin conexión, 401, 500) | **Parcial** (solo se distingue `DioException` genérico vs. otros errores; no hay diferenciación por código de estado en la UI) | patrón repetido en todos los `*_service.dart` |
| Tests automatizados | **No implementado** (solo existe el `test/widget_test.dart` por defecto del template de Flutter, sin adaptar al proyecto) | `test/widget_test.dart` |

## 12. Guía para nuevos features

Esta guía reproduce exactamente el patrón usado por los features existentes, tomando como referencia el feature **Caja** (`lib/src/ui/admin/pages/caja/`), uno de los más completos y recientes (ver commits "cierre de caaja", "arqueo").

### Paso a paso (ejemplo: feature "Reportes" ficticio)

1. **Entidad de dominio** — crear `lib/src/domain/entities/reporte_entity.dart` con `ReporteEntity` (envoltorio `{exito, msg, data, pagination?}`) y `DatumReporteEntity` (campos reales), siguiendo el estilo de `caja_entity.dart`. Sin lógica, solo campos `final` y constructor `required`.

2. **DTO** (si el feature envía datos) — crear `lib/src/domain/dto/reporte_dto.dart` con los campos a enviar (usar `?` nullable si se reutilizará para edición parcial) y un método `toJson()` que solo incluya `if (campo != null) "campo": campo` para soportar updates parciales (igual que `caja_dto.dart`).

3. **Interfaz de repositorio** — crear `lib/src/domain/repository/reporte_repo.dart`:
   ```dart
   abstract class ReporteRepo {
     Future<Either<Failure, ReporteEntity>> listar();
   }
   ```

4. **Modelo de datos** — crear `lib/src/data/model/reporte_model.dart` con `ReporteModel extends ReporteEntity` y `DatumReporteModel extends DatumReporteEntity`, cada uno con `factory X.fromJson(Map<String, dynamic> json)` (usar `json["campo"] ?? valorPorDefecto` para tolerar nulls, y `DateTime.parse(json["fecha"] ?? DateTime.now().toIso8601String())` para fechas, igual que `caja_model.dart`).

5. **Service** — crear `lib/src/data/services/reporte_service.dart`:
   - Interfaz `abstract class ReporteService` + impl `ReporteServiceImpl implements ReporteService` que recibe `ApiClient apiClient`.
   - Cada método hace `apiClient.dio.get/post(...)`, con `try { ... return XModel.fromJson(r.data); } on DioException catch(e) { throw ServerExceptions(message: e.response!.data["message"]); } catch(e) { throw Exception("Error inesperado"); }`.

6. **Repository impl** — crear `lib/src/data/repository/reporte_repo_impl.dart` implementando `ReporteRepo`, delegando al `ReporteService` y convirtiendo excepciones en `Left(ServerFailure(...))` / éxito en `Right(...)`, exactamente igual a `caja_repo_impl.dart`.

7. **Registrar en DI** — en `lib/get_it.dart`, agregar un bloque nuevo (siguiendo el orden repo→service):
   ```dart
   //Reportes
   sl.registerLazySingleton<ReporteRepo>(() => ReporteRepoImpl(reporteService: sl()));
   sl.registerLazySingleton<ReporteService>(() => ReporteServiceImpl(apiClient: sl()));
   ```

8. **Cubit + State** — crear carpeta `lib/src/ui/admin/pages/reportes/cubit/` con:
   - `reporte_cubit.dart`: `class ReporteCubit extends Cubit<ReporteState>`, `part 'reporte_state.dart'`, repositorio vía `final _reporteRepo = sl<ReporteRepo>();`, constructor que recibe `BuildContext context` y llama al método de carga inicial.
   - `reporte_state.dart`: `part of 'reporte_cubit.dart'`, `class ReporteState extends Equatable` con `context`, `loading`, `loadingBtn`, `child` (widget para sub-navegación interna) y los datos propios del feature, más `copyWith`.
   - Métodos de red siguiendo el patrón estándar: `emit(loading:true)` → `await _repo.metodo()` → `.fold(error, éxito)` → `emit(loading:false)`.

9. **Vistas** — crear `lib/src/ui/admin/pages/reportes/views/` con las sub-pantallas del feature (p. ej. `reporte_home.dart`, `reporte_detalle_view.dart`), reutilizando `BtnWidget.btn`, `InputWidget.input`, `AppDialogUtil` y `AppTheme.primaryColor` para mantener consistencia visual. Cambiar entre estas vistas con `cubit.onEventChild(NuevaVista())` (o el nombre de método equivalente), no con `Navigator.push`.

10. **Página raíz** — crear `lib/src/ui/admin/pages/reportes/reporte_page.dart`:
    ```dart
    class ReportePage extends StatefulWidget { ... }
    class _ReportePageState extends State<ReportePage> {
      late ReporteCubit _cubit;
      @override
      void initState() {
        super.initState();
        _cubit = ReporteCubit(context: context);
        _cubit.cargarDatos();
      }
      @override
      Widget build(BuildContext context) => BlocProvider(
        create: (_) => _cubit,
        child: BlocBuilder<ReporteCubit, ReporteState>(
          builder: (context, state) => Scaffold(
            body: state.loading ? Center(child: CircularProgressIndicator.adaptive()) : state.child,
          ),
        ),
      );
    }
    ```

11. **Registrar el acceso** — agregar la entrada de navegación en `DrawerHome` (`lib/src/ui/admin/pages/home/views/drawer_home.dart`) con `Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportePage()))`, o como nueva pestaña del `BottomNavWidget`/`HomePage.getChild` si el feature debe vivir en la barra inferior.

12. **Manejo de loading/success/error** — usar siempre `AppDialogUtil.error/success` en el `.fold()`, y separar `loading` (pantalla completa) de `loadingBtn` (solo el botón de acción) para no bloquear toda la UI durante un submit.

13. **Convenciones a respetar**: nombres de archivo en `snake_case`, español para textos de UI y nombres de dominio, `Either<Failure, T>` para todo lo que golpea la red, `sl<T>()` para obtener dependencias, nunca instanciar `Dio` fuera de `ApiClient`, cachear catálogos poco cambiantes en `Shared` si aplica.

### Ejemplo real de estructura de carpetas (feature Caja, como plantilla)

```
lib/src/ui/admin/pages/caja/
├── caja_page.dart                  # shell: crea CajaCubit, BlocProvider + BlocBuilder
├── cubit/
│   ├── caja_cubit.dart             # lógica + llamadas a CajaRepo / GastosRepo
│   └── caja_state.dart             # part of caja_cubit.dart
└── views/
    ├── abrir_caja_view.dart        # sub-vista mostrada vía state.child
    ├── detalle_caja.dart           # sub-vista mostrada vía state.child
    ├── dialogo_arqueo.dart         # diálogo modal
    └── dialogo_cerrar_caja.dart    # diálogo modal
```

## 13. Archivos importantes

Antes de implementar un nuevo feature, un desarrollador debería revisar:

- `lib/main.dart` — punto de entrada, configuración de `MaterialApp`, locale, pantalla inicial (`AuthPage`).
- `lib/get_it.dart` — dónde y cómo se registran todos los repositorios/servicios; obligatorio agregar aquí las nuevas dependencias.
- `lib/src/common/network/api_client.dart` — configuración de `Dio`, interceptor de token Bearer y logging; entender esto antes de crear un nuevo `Service`.
- `lib/src/common/network/api_config.dart` — URL base y timeouts; recordar que está hardcodeada (no hay flavors/ambientes).
- `lib/src/common/error/exceptions.dart` y `lib/src/common/error/failures.dart` — tipos de excepción/falla que deben lanzarse/devolverse en Service/Repository respectivamente.
- `lib/src/common/utils/app_dialog_util.dart` — forma estándar de mostrar error/éxito/info; debe usarse en todo `.fold()`.
- `lib/src/common/utils/secure_storage_util.dart` — acceso al almacenamiento seguro (token).
- `lib/src/common/utils/update_util.dart` — patrón de "solo enviar campos modificados" al editar.
- `lib/src/common/utils/date_util.dart` — formateo estándar de fechas para requests.
- `lib/src/common/shared/shared.dart` — caché en memoria de catálogos (config, rutas, cobradores, clientes); revisar si el nuevo feature necesita cachear algo aquí.
- `lib/src/common/theme/theme.dart` — único punto centralizado de color de marca (`AppTheme.primaryColor`).
- `lib/src/ui/widgets/widgets.dart` (`btn_widget.dart`, `input_widget.dart`, `header_widget.dart`) — componentes de UI reutilizables que deben preferirse sobre crear nuevos desde cero.
- **Un feature completo de referencia**: `lib/src/ui/admin/pages/caja/` (page + cubit/state + views) — es el ejemplo más reciente y completo del patrón a replicar (ver sección 12).
- `lib/src/ui/admin/pages/home/home_page.dart` y `lib/src/ui/admin/pages/home/cubit/home_cubit.dart` — shell principal ADMIN; revisar si el nuevo feature necesita agregarse como pestaña o comunicarse con este cubit (patrón `context.read<HomeCubit>()`).
- `lib/src/ui/admin/pages/home/views/drawer_home.dart` — punto donde se registran los accesos de navegación secundarios (drawer).
- `lib/src/ui/auth/cubit/auth_cubit.dart` — lógica de sesión/rol; relevante si el nuevo feature depende del rol del usuario.
- `pubspec.yaml` — confirmar versiones de `bloc`, `flutter_bloc`, `get_it`, `dartz`, `equatable`, `dio` antes de agregar código que dependa de sus APIs.
