import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';
import 'package:personal/src/domain/entities/pagination_entity.dart';
import 'package:personal/src/domain/repository/dashboard_repo.dart';

part 'actividad_state.dart';

class ActividadCubit extends Cubit<ActividadState> {
  ///Repositorios
  ///
  ///
  final _dashboardRepo = sl<DashboardRepo>();

  ///Constructor
  ///
  ///
  ActividadCubit() : super(const ActividadState()) {
    cargar();
  }

  ///Variables
  ///
  ///
  static const _limit = 20;
  final _fecha = DateUtil.formatDate(DateTime.now());

  ///Eventos
  ///
  ///
  /// null = todos los tipos
  void onTipo(TipoActividad? tipo) {
    if (tipo == state.tipo) return;
    emit(state.copyWith(tipo: tipo, clearTipo: tipo == null));
    cargar();
  }

  ///Peticiones
  ///
  ///
  Future<void> cargar() async {
    emit(state.copyWith(loading: true, error: false, items: []));

    final r = await _dashboardRepo.actividad(
      fecha: _fecha,
      tipo: state.tipo?.codigo,
      page: 1,
      limit: _limit,
    );
    if (isClosed) return;

    r.fold(
      (l) => emit(state.copyWith(error: true)),
      (p) => emit(state.copyWith(items: p.data, pagination: p.pagination)),
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

    final r = await _dashboardRepo.actividad(
      fecha: _fecha,
      tipo: state.tipo?.codigo,
      page: pagination.page + 1,
      limit: _limit,
    );
    if (isClosed) return;

    r.fold(
      (l) {},
      (p) => emit(
        state.copyWith(
          items: [...state.items, ...p.data],
          pagination: p.pagination,
        ),
      ),
    );
    emit(state.copyWith(loadingMore: false));
  }
}
