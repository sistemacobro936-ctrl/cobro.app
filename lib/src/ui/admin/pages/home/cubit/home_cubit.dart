import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  ///Repositorios
  ///
  ///
  final _pagoRepo = sl<PagoRepo>();

  ///Constructor
  HomeCubit({required BuildContext context})
    : super(HomeState(context: context));

  ///Variables
  ///
  ///
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ///Eventos
  ///
  ///
  void onCurrenteIndex(int index) {
    emit(state.copyWith(currentIndex: index));
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

  ///Navegacion
  ///
  ///

  ///Otros
  ///
  ///
}
