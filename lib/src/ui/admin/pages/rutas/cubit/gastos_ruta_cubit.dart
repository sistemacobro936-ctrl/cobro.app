import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/gasto_ruta_dto.dart';
import 'package:personal/src/domain/entities/gasto_ruta_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';

part 'gastos_ruta_state.dart';

class GastosRutaCubit extends Cubit<GastosRutaState> {
  ///Repositorios
  ///
  ///
  final _gastosRepo = sl<GastosRepo>();

  ///Constructor
  ///
  ///
  GastosRutaCubit({required BuildContext context, required this.rutaId})
    : super(
        GastosRutaState(
          context: context,
          mes: DateTime(DateTime.now().year, DateTime.now().month),
        ),
      ) {
    cargar();
  }

  ///Variables
  ///
  ///
  final String rutaId;
  static const _limit = 20;

  ///Eventos
  ///
  ///
  /// Cambia de mes: [meses] = -1 anterior, +1 siguiente
  void cambiarMes(int meses) {
    final m = state.mes;
    emit(state.copyWith(mes: DateTime(m.year, m.month + meses)));
    cargar();
  }

  ///Peticiones
  ///
  ///
  Future<void> cargar() async {
    emit(state.copyWith(loading: true, error: false, gastos: []));

    final r = await _consultar(page: 1);
    if (isClosed) return;

    r.fold(
      (l) => emit(state.copyWith(error: true)),
      (g) => emit(
        state.copyWith(
          gastos: g.gastos,
          resumen: g.resumen,
          pagination: g.pagination,
        ),
      ),
    );
    emit(state.copyWith(loading: false));
  }

  Future<void> cargarMas() async {
    final pagination = state.pagination;
    if (state.loading ||
        state.loadingMore ||
        pagination == null ||
        !pagination.hasNextPage) {
      return;
    }

    emit(state.copyWith(loadingMore: true));
    final r = await _consultar(page: pagination.page + 1);
    if (isClosed) return;

    r.fold(
      (l) {},
      (g) => emit(
        state.copyWith(
          gastos: [...state.gastos, ...g.gastos],
          resumen: g.resumen,
          pagination: g.pagination,
        ),
      ),
    );
    emit(state.copyWith(loadingMore: false));
  }

  /// Devuelve true si se registró; si falla muestra el error
  Future<bool> crear({
    required String concepto,
    required int valor,
    required DateTime fecha,
    String? observacion,
  }) async {
    final r = await _gastosRepo.crearGastoRuta(
      dto: CrearGastoRutaDto(
        rutaId: rutaId,
        concepto: concepto,
        valor: valor,
        observacion: observacion,
        fechaGasto: fecha,
      ),
    );
    if (isClosed) return false;

    return r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        return false;
      },
      (_) {
        cargar();
        return true;
      },
    );
  }

  /// Devuelve true si se anuló; si falla muestra el error
  Future<bool> anular({required String id, required String motivo}) async {
    final r = await _gastosRepo.anularGastoRuta(id: id, motivo: motivo);
    if (isClosed) return false;

    return r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        return false;
      },
      (_) {
        cargar();
        return true;
      },
    );
  }

  ///Otros
  ///
  ///
  /// Gastos del mes seleccionado, de la página [page]
  Future<Either<Failure, GastosRutaEntity>> _consultar({required int page}) {
    final inicio = DateTime(state.mes.year, state.mes.month);
    final fin = DateTime(state.mes.year, state.mes.month + 1, 0);

    return _gastosRepo.listarGastosRuta(
      rutaId: rutaId,
      fechaInicio: DateUtil.formatDate(inicio),
      fechaFin: DateUtil.formatDate(fin),
      page: page,
      limit: _limit,
    );
  }
}
