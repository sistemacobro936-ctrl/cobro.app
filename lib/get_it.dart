import 'package:get_it/get_it.dart';
import 'package:personal/src/common/network/api_client.dart';
import 'package:personal/src/common/utils/secure_storage_util.dart';
import 'package:personal/src/data/repository/auth_repo_impl.dart';
import 'package:personal/src/data/repository/caja_repo_impl.dart';
import 'package:personal/src/data/repository/contabilidad_repo_impl.dart';
import 'package:personal/src/data/repository/crear_cliente_repo.dart';
import 'package:personal/src/data/repository/config_repo_impl.dart';
import 'package:personal/src/data/repository/gastos_repo_impl.dart';
import 'package:personal/src/data/repository/negocio_repo_impl.dart';
import 'package:personal/src/data/repository/pago_repo_impl.dart';
import 'package:personal/src/data/repository/prestamo_repo_impl.dart';
import 'package:personal/src/data/repository/ruta_repo_impl.dart';
import 'package:personal/src/data/repository/usuario_repo_impl.dart';
import 'package:personal/src/data/services/auth_service.dart';
import 'package:personal/src/data/services/caja_service.dart';
import 'package:personal/src/data/services/contabilidad_service.dart';
import 'package:personal/src/data/services/cliente_service.dart';
import 'package:personal/src/data/services/config_service.dart';
import 'package:personal/src/data/services/gasto_service.dart';
import 'package:personal/src/data/services/negocio_service.dart';
import 'package:personal/src/data/services/pago_service.dart';
import 'package:personal/src/data/services/prestamo_service.dart';
import 'package:personal/src/data/services/ruta_service.dart';
import 'package:personal/src/data/services/usuario_service.dart';
import 'package:personal/src/domain/repository/auth_repo.dart';
import 'package:personal/src/domain/repository/caja_repo.dart';
import 'package:personal/src/domain/repository/contabilidad_repo.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';
import 'package:personal/src/domain/repository/config_repo.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';
import 'package:personal/src/domain/repository/presamo_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';

final sl = GetIt.instance;

void initDep() {
  // Preferencias
  sl.registerLazySingleton<SecureStorageUtil>(() => SecureStorageUtil());
  // Dio
  sl.registerLazySingleton<ApiClient>(() => ApiClient(preferences: sl()));

  // AUTH

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepoImpl(authService: sl()),
  );

  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(apiClient: sl()));

  // USUARIO

  sl.registerLazySingleton<UsuarioRepository>(
    () => UsuarioRepoImpl(usuarioService: sl()),
  );

  sl.registerLazySingleton<UsuarioService>(
    () => UsuarioServiceImpl(apiClient: sl()),
  );

  // CLIENTE

  sl.registerLazySingleton<ClienteRepository>(
    () => ClienteRepoImpl(clienteService: sl()),
  );

  sl.registerLazySingleton<ClienteService>(
    () => ClienteServiceImpl(apiClient: sl()),
  );

  // CONFIGURACION

  sl.registerLazySingleton<ConfiguracionRepository>(
    () => ConfiguracionRepoImpl(configuracionService: sl()),
  );

  sl.registerLazySingleton<ConfiguracionService>(
    () => ConfiguracionServiceImpl(apiClient: sl()),
  );

  // Pretamis

  sl.registerLazySingleton<PresamoRepo>(
    () => PrestamoRepoImpl(prestamoService: sl()),
  );

  sl.registerLazySingleton<PrestamoService>(
    () => PrestamoServiceImpl(apiClient: sl()),
  );

  //Rutas
  sl.registerLazySingleton<RutaRepo>(() => RutaRepoImpl(rutaService: sl()));

  sl.registerLazySingleton<RutaService>(() => RutaServiceImpl(apiClient: sl()));

  //Pagos
  sl.registerLazySingleton<PagoRepo>(() => PagoRepoImpl(pagoService: sl()));

  sl.registerLazySingleton<PagoService>(() => PagoServiceImpl(apiClient: sl()));

  //Caja
  sl.registerLazySingleton<CajaRepo>(() => CajaRepoImpl(cajaService: sl()));

  sl.registerLazySingleton<CajaService>(() => CajaServiceImpl(apiClient: sl()));

  //Gastos
  sl.registerLazySingleton<GastosRepo>(
    () => GastosRepoImpl(gastosService: sl()),
  );

  sl.registerLazySingleton<GastosService>(
    () => GastosServiceImpl(apiClient: sl()),
  );

  //Contabilidad
  sl.registerLazySingleton<ContabilidadRepo>(
    () => ContabilidadRepoImpl(contabilidadService: sl()),
  );

  sl.registerLazySingleton<ContabilidadService>(
    () => ContabilidadServiceImpl(apiClient: sl()),
  );

  //Negocio
  sl.registerLazySingleton<NegocioRepo>(
    () => NegocioRepoImpl(negocioService: sl()),
  );

  sl.registerLazySingleton<NegocioService>(
    () => NegocioServiceImpl(apiClient: sl()),
  );
}
