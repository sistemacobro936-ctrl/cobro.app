import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/dto/ruta_dto.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';
import 'package:personal/src/domain/entities/movimiento_ruta_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/caja_repo.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/historico_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_home.dart';

part 'ruta_state.dart';

class RutaCubit extends Cubit<RutaState> {
  ///Repositorios
  ///

  final _cobradorRepo = sl<UsuarioRepository>();
  final _rutaRepo = sl<RutaRepo>();
  final _clienteRepo = sl<ClienteRepository>();
  final _cajaRepo = sl<CajaRepo>();

  ///Constructor
  ///
  ///
  RutaCubit({required BuildContext context})
    : super(RutaState(context: context)) {
    onEventChild(RutaHome());
    getCobrador();
  }

  ///Variables
  ///

  final nombreRuta = TextEditingController();
  final descripcionRuta = TextEditingController();
  final capital = TextEditingController();

  ///Eventos
  ///

  void onEventChild(Widget child) {
    emit(state.copyWith(child: child));
  }

  void onGetCobrador(DatumCEntity c) {
    emit(state.copyWith(cobrador: c));
  }

  void enabledBtn() {
    bool e = false;
    if (nombreRuta.text.isNotEmpty &&
        descripcionRuta.text.isNotEmpty &&
        capital.text.isNotEmpty) {
      e = true;
    }
    emit(state.copyWith(enabled: e));
  }

  ///Peticiones
  ///
  ///
  /**
   * 
   */
  void listarRutas() async {
    emit(state.copyWith(loading: true));
    final r = await _rutaRepo.listar();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(rutas: r.data));
        Shared.setRutas = r.data;
      },
    );
    emit(state.copyWith(loading: false));
  }

  void getCobrador() async {
    if (Shared.getCobradores == null) {
      final r = await _cobradorRepo.listarCobradores();
      r.fold((l) {}, (r) {
        Shared.setCobradores = r.data;
      });
    }
  }

  void crearRuta() async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _rutaRepo.crear(
      dto: RutaDto(
        nombre: nombreRuta.text,
        descripcion: descripcionRuta.text,
        cobradorId: state.cobrador?.id,
        capital: int.parse(capital.text),
        habilitada: true,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(state.context, message: "Operación exitosa.");
        onEventChild(RutaHome());
        listarRutas();
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  void movimientoRuta({required String idRuta}) async {
    emit(
      state.copyWith(loading: true, limpiarPaginacion: true, pageClientes: 1),
    );
    final r = await _rutaRepo.movimiento(idRuta: idRuta);
    r.fold((r) {}, (r) {
      emit(state.copyWith(movimiento: r.data));
    });
    emit(state.copyWith(loading: false));
  }

  void clienteRuta({required String idRuta, int page = 1}) async {
    emit(state.copyWith(loading: true));
    final r = await _clienteRepo.clientesPorRuta(idRuta: idRuta, page: page);
    r.fold((r) {}, (r) {
      emit(
        state.copyWith(
          paginationClientes: r.pagination,
          pageClientes: page,
          clientes: [...state.clientes ?? [], ...r.data],
        ),
      );
    });
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
          message: "Cliente creado con éxito.",
        );
        onEventChild(RutaHome());
        listarRutas();
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  void editarRuta(String id) async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _rutaRepo.editar(
      id: id,
      dto: RutaDto(
        cobradorId: state.cobrador?.id,
        descripcion: descripcionRuta.text,
        nombre: nombreRuta.text,
        capital: int.parse(capital.text),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Actualización realizada con éxito",
        );
        listarRutas();
        onEventChild(RutaHome());
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  void historico({required String rutaId}) async {
    emit(state.copyWith(loading: true));
    final r = await _cajaRepo.historico(rutaID: rutaId);
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(historico: r.data, child: HistoricoView()));
      },
    );
    emit(state.copyWith(loading: false));
  }

  ///Otros
  void llenarForm(DatumREntity ruta,) {
    nombreRuta.value = nombreRuta.value.copyWith(text: ruta.nombre);
    descripcionRuta.value = descripcionRuta.value.copyWith(
      text: ruta.descripcion,
    );

    capital.value = capital.value.copyWith(text: ruta.capital.toString());

    emit(state.copyWith(cobrador: ruta.cobrador));
  }

  void clear() {
    nombreRuta.clear();
    descripcionRuta.clear();
    capital.clear();
    emit(state.copyWith(limpiarCobrador: true));
  }

  void eliminarCobrador() {
    emit(state.copyWith(limpiarCobrador: true));
  }
}
