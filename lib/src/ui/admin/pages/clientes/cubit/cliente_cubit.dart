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
    listarRuta();
  }

  ///Variables
  ///
  ///

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
  void listClientes() async {
    emit(state.copyWith(loading: true));
    final r = await _clienteRepo.listar();

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(clientes: r.data));
        Shared.setClientes = r.data;
      },
    );
    emit(state.copyWith(loading: false));
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

  void listarRuta() async {
    if (Shared.getRutas != null) return;
    final r = await _rutaRepo.listar();
    r.fold((l) {}, (r) {
      Shared.setRutas = r.data;
    });
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

  void buscar(String q) async {
    emit(state.copyWith(search: true));
    final r = await _clienteRepo.buscar(q: q);
    r.fold((l) {}, (r) {
      emit(state.copyWith(clientes: r.data));
    });
    emit(state.copyWith(search: false));
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
}
