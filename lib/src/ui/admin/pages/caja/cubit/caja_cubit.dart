import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/caja_dto.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/repository/caja_repo.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';
import 'package:personal/src/ui/admin/pages/caja/views/abrir_caja_view.dart';
import 'package:personal/src/ui/admin/pages/caja/views/detalle_caja.dart';

part 'caja_state.dart';

class CajaCubit extends Cubit<CajaState> {
  ///Repositorios
  ///
  ///
  final _cajaRepo = sl<CajaRepo>();
  final _gastoRepo = sl<GastosRepo>();

  ///Constructor
  CajaCubit({required BuildContext context})
    : super(CajaState(context: context)) {}

  ///Variables
  ///
  ///
  final montoInicial = TextEditingController();
  final dineroRecibido = TextEditingController();
  final observacion = TextEditingController();

  ///Eventos
  ///
  void onGetChild(Widget c) {
    emit(state.copyWith(child: c));
  }

  ///Validaciones
  ///
  void formValid() {
    bool e = false;
    if (montoInicial.text.isNotEmpty) {
      e = true;
    }
    emit(state.copyWith(btnEnabled: e));
  }

  ///Peticiones
  ///
  void listarCajar({required String rutaId}) async {
    emit(state.copyWith(loading: true, showArqueo: false));
    final r = await _cajaRepo.obtenerCajas(
      rutaId: rutaId,
      fecha: DateUtil.formatDate(DateTime.now()),
    );
    r.fold(
      (l) {
        emit(state.copyWith(child: AbrirCajaView(rutaId: rutaId)));
      },
      (r) {
        if (r.data!.isEmpty) {
          emit(state.copyWith(child: AbrirCajaView(rutaId: rutaId)));
        } else {
          emit(state.copyWith(cajas: r.data!.first));
          emit(state.copyWith(child: DetalleCaja()));
          _gastosCaja();
        }
      },
    );
    emit(state.copyWith(loading: false));
  }

  void crearCaja({required String rutaId}) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _cajaRepo.crearCaja(
      dto: CajaDto(
        rutaId: rutaId,
        montoInicial: int.parse(montoInicial.text),
        fechaApertura: DateUtil.formatDate(DateTime.now()),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(state.context, message: "Operación exitosa.");
        listarCajar(rutaId: rutaId);
      },
    );
    emit(state.copyWith(btnLoading: false));
  }

  Future<void> _gastosCaja() async {
    emit(state.copyWith(loading: true));
    final r = await _gastoRepo.listarGastos(cajaId: state.cajas!.id);
    r.fold(
      (l) {
        AppDialogUtil.error(
          state.context,
          message: "Se presento un error al listar los gastos.",
        );
      },
      (r) {
        emit(state.copyWith(gastos: r.data.gastos));
      },
    );
    emit(state.copyWith(loading: false));
  }

  void cerrar() async {
    emit(state.copyWith(loading: true));
    final r = await _cajaRepo.cerrar(
      cajaId: state.cajas!.id,
      dto: CajaDto(
        diferencia: state.diferencia,
        montoReal: int.parse(dineroRecibido.text),
        observacion: observacion.text,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Cierre de caja exitoso.",
        );
      },
    );
    emit(state.copyWith(loading: false));
  }

  //navegacion
  //
  void arqueo(int esperado) {
    int d = esperado - int.parse(dineroRecibido.text);
    emit(state.copyWith(diferencia: d, showArqueo: true));
  }

  ///Otros
}
