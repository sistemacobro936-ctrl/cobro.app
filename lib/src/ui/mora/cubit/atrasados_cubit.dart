import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/repository/mora_repo.dart';

part 'atrasados_state.dart';

/// Préstamos vencidos, filtrables por nivel de atraso o por clientes CLAVO
class AtrasadosCubit extends Cubit<AtrasadosState> {
  final _moraRepo = sl<MoraRepo>();
  static const _limit = 20;

  /// Cada consulta invalida a las anteriores (cambios rápidos de filtro)
  int _solicitud = 0;

  AtrasadosCubit(BuildContext context, {int? nivel, bool soloClavos = false})
    : super(
        AtrasadosState(
          context: context,
          nivel: nivel,
          soloClavos: soloClavos,
        ),
      ) {
    cargar();
  }

  Future<void> cargar() async {
    final id = ++_solicitud;
    emit(state.copyWith(loading: true, atrasados: [], limpiarPaginacion: true));

    final r = await _moraRepo.atrasados(
      nivel: state.nivel,
      estadoCliente: state.soloClavos ? 'CLAVO' : null,
      limit: _limit,
    );
    if (isClosed || id != _solicitud) return;

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (p) => emit(
        state.copyWith(
          atrasados: p.data,
          resumen: p.resumen,
          pagination: p.pagination,
        ),
      ),
    );
    emit(state.copyWith(loading: false));
  }

  Future<void> cargarMas() async {
    final p = state.pagination;
    if (state.loading || state.loadingMore || p == null || !p.hasNextPage) {
      return;
    }
    final id = _solicitud;
    emit(state.copyWith(loadingMore: true));

    final r = await _moraRepo.atrasados(
      nivel: state.nivel,
      estadoCliente: state.soloClavos ? 'CLAVO' : null,
      page: p.page + 1,
      limit: _limit,
    );
    if (isClosed || id != _solicitud) return;

    r.fold(
      (_) {},
      (p) => emit(
        state.copyWith(
          atrasados: [...state.atrasados, ...p.data],
          pagination: p.pagination,
        ),
      ),
    );
    emit(state.copyWith(loadingMore: false));
  }

  /// null = todos los niveles
  void seleccionarNivel(int? nivel) {
    emit(state.copyWith(nivel: nivel, limpiarNivel: nivel == null, soloClavos: false));
    cargar();
  }

  void verClavos() {
    emit(state.copyWith(limpiarNivel: true, soloClavos: true));
    cargar();
  }
}
