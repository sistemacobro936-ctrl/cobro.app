import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/error/failures.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';
import 'package:personal/src/domain/repository/nomina_repo.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';

part 'historial_nomina_state.dart';

class HistorialNominaCubit extends Cubit<HistorialNominaState> {
  ///Repositorios
  ///
  ///
  final _nominaRepo = sl<NominaRepo>();
  final _usuarioRepo = sl<UsuarioRepository>();
  final _negocioRepo = sl<NegocioRepo>();

  ///Constructor
  ///
  ///
  HistorialNominaCubit({required BuildContext context})
    : super(
        HistorialNominaState(
          context: context,
          periodo: PeriodoNomina.mesActual(),
        ),
      ) {
    cargarEmpleados();
  }

  ///Variables
  ///
  ///
  static const _limit = 20;

  ///Eventos
  ///
  ///
  void seleccionarEmpleado(String? id) {
    if (id == null) return;
    emit(state.copyWith(empleadoId: id));
    cargar();
  }

  void cambiarPeriodo(PeriodoNomina p) {
    emit(state.copyWith(periodo: p));
    if (state.empleadoId != null) cargar();
  }

  ///Peticiones
  ///
  ///
  /// Cobradores + administradores (no hay endpoint de supervisores)
  Future<void> cargarEmpleados() async {
    emit(state.copyWith(loadingEmpleados: true));

    final cobradores = await _usuarioRepo.listarCobradores();
    final admins = await _negocioRepo.listarAdministradores();
    if (isClosed) return;

    final empleados = <EmpleadoNomina>[];
    cobradores.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (r) {
        Shared.setCobradores = r.data;
        empleados.addAll(
          r.data.map(
            (c) => EmpleadoNomina(
              id: c.id,
              nombre: '${c.nombre} ${c.apellido}'.trim(),
              rol: 'Cobrador',
            ),
          ),
        );
      },
    );
    admins.fold((_) {}, (r) {
      empleados.addAll(
        r.data
            .where((a) => !empleados.any((e) => e.id == a.id))
            .map(
              (a) => EmpleadoNomina(
                id: a.id,
                nombre: '${a.nombre} ${a.apellido}'.trim(),
                rol: 'Administrador',
              ),
            ),
      );
    });

    emit(state.copyWith(empleados: empleados, loadingEmpleados: false));
  }

  Future<void> cargar() async {
    if (state.empleadoId == null) return;
    emit(state.copyWith(loading: true, error: false, pagos: []));

    final r = await _consultar(page: 1);
    if (isClosed) return;

    r.fold(
      (l) => emit(state.copyWith(error: true)),
      (h) => emit(
        state.copyWith(
          pagos: h.pagos,
          resumen: h.resumen,
          pagination: h.pagination,
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
      (h) => emit(
        state.copyWith(
          pagos: [...state.pagos, ...h.pagos],
          resumen: h.resumen,
          pagination: h.pagination,
        ),
      ),
    );
    emit(state.copyWith(loadingMore: false));
  }

  /// Pagos activos cargados que comparten [lote] (pago repartido de supervisor)
  List<PagoNominaEntity> activosDelLote(String? lote) =>
      lote == null || lote.isEmpty
      ? const []
      : state.pagos.where((p) => p.lote == lote && !p.anulado).toList();

  /// Devuelve true si se anuló; si falla muestra el error.
  /// El valor vuelve al capital de la ruta
  Future<bool> anular({required String id, required String motivo}) async {
    final r = await _nominaRepo.anular(id: id, motivo: motivo);
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

  /// Anula cada pago activo del lote, uno por uno. Si uno falla se detiene
  /// e informa cuántos alcanzaron a anularse
  Future<void> anularLote({
    required String lote,
    required String motivo,
  }) async {
    final pagos = activosDelLote(lote);
    var anulados = 0;
    num total = 0;
    String? error;

    for (final p in pagos) {
      final r = await _nominaRepo.anular(id: p.id, motivo: motivo);
      if (isClosed) return;
      error = r.fold((l) => l.props[0].toString(), (_) => null);
      if (error != null) break;
      anulados++;
      total += p.valor;
    }

    if (error != null) {
      AppDialogUtil.error(
        state.context,
        message: anulados == 0
            ? error
            : 'Se anularon $anulados de ${pagos.length} pagos (${MoneyUtil.format(total)}), pero el siguiente falló: $error',
      );
    } else {
      AppDialogUtil.success(
        state.context,
        message:
            'Se anularon los $anulados pagos del lote (${MoneyUtil.format(total)}). El valor volvió al capital de cada ruta.',
      );
    }
    cargar();
  }

  ///Otros
  ///
  ///
  Future<Either<Failure, HistorialNominaEntity>> _consultar({
    required int page,
  }) {
    return _nominaRepo.historial(
      empleadoId: state.empleadoId!,
      fechaInicio: DateUtil.formatDate(state.periodo.inicio),
      fechaFin: DateUtil.formatDate(state.periodo.fin),
      page: page,
      limit: _limit,
    );
  }
}
