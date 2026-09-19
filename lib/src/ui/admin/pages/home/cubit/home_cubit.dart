import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';
import 'package:personal/src/domain/repository/dashboard_repo.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  ///Repositorios
  ///
  ///
  final _pagoRepo = sl<PagoRepo>();
  final _dashboardRepo = sl<DashboardRepo>();

  ///Constructor
  HomeCubit({required BuildContext context})
    : super(HomeState(context: context)) {
    cargarDashboard();
  }

  ///Variables
  ///
  ///
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ///Eventos
  ///
  ///
  void onCurrenteIndex(int index) {
    emit(state.copyWith(currentIndex: index));
    // Al volver al panel se refrescan los datos (cobros, préstamos nuevos, etc.)
    if (index == 0) cargarDashboard();
  }

  void onAsignarPrestamo(bool e) {
    emit(state.copyWith(asignarPrestamo: e));
  }



  void setLoadPay(bool e) {
    emit(state.copyWith(loadPay: e));
  }

  ///Validaciones
  ///
  ///

  ///Peticiones
  ///
  ///
  Future<void> cargarDashboard() async {
    emit(state.copyWith(loadingDashboard: true, errorDashboard: false));
    final r = await _dashboardRepo.resumen(
      fecha: DateUtil.formatDate(DateTime.now()),
      limit: 10,
    );
    if (isClosed) return;

    r.fold(
      (l) => emit(state.copyWith(errorDashboard: true)),
      (d) => emit(state.copyWith(dashboard: d)),
    );
    emit(state.copyWith(loadingDashboard: false));
  }

  Future<bool> pagar({required String id, required int monto}) async {
    emit(state.copyWith(loadPay: true));
    bool e = false;
    final r = await _pagoRepo.pagar(
      dto: PagoDto(prestamoId: id, valor: monto, fechaPago: DateTime.now()),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        false;
      },
      (r) {
        e = true;
        AppDialogUtil.success(
          state.context,
          message: "Pago registrado con éxito",
        );
      },
    );
    emit(state.copyWith(loadPay: false));
    return e;
  }

  Future<bool> noPago({
    required String id,
    required MotivoNoPago motivo,
    String? observacion,
    DateTime? fechaPromesa,
  }) async {
    emit(state.copyWith(loadPay: true));
    bool e = false;
    final r = await _pagoRepo.noPago(
      dto: NoPagoDto(
        prestamoId: id,
        motivo: motivo,
        observacion: observacion,
        fechaPromesa: fechaPromesa,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        e = true;
        AppDialogUtil.success(
          state.context,
          message: "No pago registrado con éxito",
        );
      },
    );
    emit(state.copyWith(loadPay: false));
    return e;
  }

  ///Navegacion
  ///
  ///

  ///Otros
  ///
  ///
}
