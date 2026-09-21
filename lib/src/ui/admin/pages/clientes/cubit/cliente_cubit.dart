import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/update_util.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_home.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/cliente_detalle_view.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';

part 'cliente_state.dart';

class ClienteCubit extends Cubit<ClienteState> {
  ///Repositorios
  ///
  ///

  final _clienteRepo = sl<ClienteRepository>();
  final _rutaRepo = sl<RutaRepo>();

  ///Constructor
  ///
  ///

  ClienteCubit(BuildContext context) : super(ClienteState(context: context)) {
    setChild(ClientHome());
    iniciar();
  }

  ///Variables
  ///
  ///
  static const _limit = 20;

  /// Texto del buscador; vive aquí para poder limpiarlo desde cualquier vista
  final busquedaController = TextEditingController();

  /// Cada consulta de la lista o búsqueda invalida a las anteriores, para que
  /// una respuesta lenta no pise a una más reciente
  int _solicitud = 0;

  ///Eventos
  ///
  ///
  void setChild(Widget child) {
    emit(state.copyWith(child: child));
  }

  void onEventRuta(DatumREntity r) {
    emit(state.copyWith(ruta: r));
  }

  ///Validaciones
  ///
  ///

  ///Peticiones
  ///
  ///
  /// Carga las rutas y muestra los clientes de la primera
  Future<void> iniciar() async {
    var rutas = Shared.getRutas;
    if (rutas == null) {
      final r = await _rutaRepo.listar();
      r.fold((l) {}, (r) {
        Shared.setRutas = r.data;
        rutas = r.data;
      });
    }
    if (isClosed) return;

    final lista = rutas ?? [];
    emit(
      state.copyWith(
        rutas: lista,
        // Sin rutas se listan todos los clientes ('')
        filtroRutaId: lista.isEmpty ? '' : lista.first.id,
      ),
    );
    await cargarClientes();
  }

  /// Recarga la selección actual y el caché global de clientes
  void listClientes() {
    cargarClientes();
    _actualizarCache();
  }

  /// Clientes de la ruta seleccionada (o todos si no hay ruta seleccionada)
  Future<void> cargarClientes() async {
    final id = ++_solicitud;
    final ruta = state.filtroRutaId ?? '';

    emit(
      state.copyWith(
        loadingLista: true,
        loadingMore: false,
        search: false,
        clientes: [],
        limpiarPaginacion: true,
      ),
    );

    final r = ruta.isEmpty
        ? await _clienteRepo.listar()
        : await _clienteRepo.clientesPorRuta(
            idRuta: ruta,
            page: 1,
            limit: _limit,
          );
    if (isClosed || id != _solicitud) return;

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(clientes: r.data, paginationClientes: r.pagination));
        if (ruta.isEmpty) Shared.setClientes = r.data;
      },
    );
    emit(state.copyWith(loadingLista: false,));
  }

  Future<void> cargarMas() async {
    final ruta = state.filtroRutaId ?? '';
    final pagination = state.paginationClientes;
    if (ruta.isEmpty ||
        state.busqueda.isNotEmpty ||
        state.loadingLista ||
        state.loadingMore ||
        pagination == null ||
        !pagination.hasNextPage) {
      return;
    }

    final id = _solicitud;
    emit(state.copyWith(loadingMore: true));

    final r = await _clienteRepo.clientesPorRuta(
      idRuta: ruta,
      page: pagination.page + 1,
      limit: _limit,
    );
    if (isClosed || id != _solicitud) return;

    r.fold(
      (l) {},
      (r) => emit(
        state.copyWith(
          clientes: [...state.clientes ?? [], ...r.data],
          paginationClientes: r.pagination,
        ),
      ),
    );
    emit(state.copyWith(loadingMore: false));
  }

  /// Cambia la ruta que se lista; descarta la búsqueda activa
  void seleccionarRuta(String rutaId) {
    if (rutaId == state.filtroRutaId && state.busqueda.isEmpty) return;
    busquedaController.clear();
    emit(state.copyWith(filtroRutaId: rutaId, busqueda: ''));
    cargarClientes();
  }

  Future<void> _actualizarCache() async {
    // Con "todos" seleccionado, cargarClientes ya actualiza el caché
    if ((state.filtroRutaId ?? '').isEmpty) return;
    final r = await _clienteRepo.listar();
    r.fold((l) {}, (r) => Shared.setClientes = r.data);
  }

  void crearCliente(CrearClienteDto dto) async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _clienteRepo.crear(dto: dto);
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Cliente creado con éxito.\n¿Desea asignar préstamo?",
          buttonText: "Asignar",
        );
        listClientes();
        state.context.read<HomeCubit>().onCurrenteIndex(3);
        state.context.read<HomeCubit>().onAsignarPrestamo(true);
        Shared.setIdCliente = r;
      },
    );

    emit(state.copyWith(loadingBtn: false));
  }

  void editarCliente(CrearClienteDto c) async {
    emit(state.copyWith(loadingBtn: true));

    final cliente = state.cliente;

    if (cliente == null) {
      emit(state.copyWith(loadingBtn: false));
      return;
    }

    final dto = CrearClienteDto(
      rutaId: UpdateUtil.valorModificado(cliente.rutaId, c.rutaId),

      nombres: UpdateUtil.valorModificado(cliente.nombres, c.nombres),

      apellidos: UpdateUtil.valorModificado(cliente.apellidos, c.apellidos),

      telefono: UpdateUtil.valorModificado(cliente.telefono, c.telefono),

      whatsapp: UpdateUtil.valorModificado(cliente.whatsapp, c.whatsapp),

      direccion: UpdateUtil.valorModificado(cliente.direccion, c.direccion),

      descripcionDireccion: UpdateUtil.valorModificado(
        cliente.descripcionDireccion,
        c.descripcionDireccion,
      ),
      barrio: UpdateUtil.valorModificado(cliente.barrio, c.barrio),
      observacion: UpdateUtil.valorModificado(
        cliente.observacion,
        c.observacion,
      ),
    );

    final r = await _clienteRepo.editar(dto: dto, id: state.cliente!.id);

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Cliente editado con éxito.",
        );

        listClientes();
        setChild(ClientHome());
      },
    );

    emit(state.copyWith(loadingBtn: false));
  }

  void detalleCliente(String id) async {
    emit(state.copyWith(loading: true));
    final r = await _clienteRepo.obtenerCliente(id: id);
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(cliente: r, child: ClienteDetalleView()));
      },
    );
    emit(state.copyWith(loading: false));
  }

  /// Búsqueda global. Si los resultados no son de la ruta seleccionada, la
  /// ruta pasa a ser la del primer resultado.
  void buscar(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      limpiarBusqueda();
      return;
    }
    // La búsqueda pudo limpiarse mientras esperaba el retardo del teclado
    if (busquedaController.text.trim() != query) return;

    final id = ++_solicitud;
    emit(
      state.copyWith(busqueda: query, search: true, loadingLista: false),
    );

    final r = await _clienteRepo.buscar(q: query);
    if (isClosed || id != _solicitud) return;

    r.fold((l) {}, (r) {
      emit(
        state.copyWith(
          clientes: r.data,
          limpiarPaginacion: true,
          filtroRutaId: _rutaParaResultados(r.data),
        ),
      );
    });
    emit(state.copyWith(search: false));
  }

  /// Quita la búsqueda y vuelve a listar los clientes de la ruta seleccionada
  void limpiarBusqueda() {
    busquedaController.clear();
    emit(state.copyWith(busqueda: ''));
    cargarClientes();
  }

  ///Navegacion
  ///
  ///

  ///Otros
  ///
  ///
  ///
  void clear() {
    emit(state.copyWith(btnEnabled: false, limpiarRuta: true));
  }

  /// Ruta que debe quedar seleccionada para mostrar [resultados]
  String _rutaParaResultados(List<DatumClEntity> resultados) {
    final actual = state.filtroRutaId ?? '';
    if (resultados.isEmpty || actual.isEmpty) return actual;
    if (resultados.any((c) => c.rutaId == actual)) return actual;
    // '' (sin ruta) equivale a "todos"
    return resultados.first.rutaId;
  }

  @override
  Future<void> close() {
    busquedaController.dispose();
    return super.close();
  }
}
