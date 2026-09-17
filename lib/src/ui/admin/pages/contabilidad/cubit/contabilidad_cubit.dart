import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/reporte_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/contabilidad_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';

part 'contabilidad_state.dart';

class ContabilidadCubit extends Cubit<ContabilidadState> {
  ///Repositorios
  ///
  final _contabilidadRepo = sl<ContabilidadRepo>();
  final _rutaRepo = sl<RutaRepo>();

  ///Constructor
  ContabilidadCubit({required BuildContext context})
    : super(ContabilidadState(context: context, fecha: DateTime.now())) {
    listarRutas();
    cargarReporte();
  }

  ///Peticiones
  ///
  void listarRutas() async {
    emit(state.copyWith(loading: true));
    if (Shared.getRutas != null) {
      emit(state.copyWith(rutas: Shared.getRutas!));
      emit(state.copyWith(loading: false));
      return;
    }
    final r = await _rutaRepo.listar();
    emit(state.copyWith(loading: false));

    r.fold((l) {}, (r) {
      Shared.setRutas = r.data;
      emit(state.copyWith(rutas: r.data));
    });
  }

  void cargarReporte() async {
    emit(state.copyWith(loading: true));
    final fecha = DateUtil.formatDate(state.fecha);
    final r = await _contabilidadRepo.obtenerNegocio(
      fechaInicio: fecha,
      fechaFin: fecha,
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        emit(
          ContabilidadState(
            context: state.context,
            fecha: state.fecha,
            rutas: state.rutas,
            rutaSeleccionada: state.rutaSeleccionada,
            totales: null,
            cajas: const [],
            cajaRuta: null,
          ),
        );
      },
      (r) {
        final cajas = r.data?.cajas ?? [];
        final rutaSel = state.rutaSeleccionada;
        emit(
          ContabilidadState(
            context: state.context,
            fecha: state.fecha,
            rutas: state.rutas,
            rutaSeleccionada: rutaSel,
            totales: r.data?.totales,
            cajas: cajas,
            cajaRuta: rutaSel == null ? null : _buscarCaja(cajas, rutaSel.id),
          ),
        );
      },
    );
    emit(state.copyWith(loading: false));
  }

  ///Eventos
  ///
  void seleccionarFecha(DateTime fecha) {
    emit(state.copyWith(fecha: fecha));
    cargarReporte();
  }

  void seleccionarRuta(DatumREntity? ruta) {
    emit(
      ContabilidadState(
        context: state.context,
        fecha: state.fecha,
        loading: state.loading,
        rutas: state.rutas,
        totales: state.totales,
        cajas: state.cajas,
        rutaSeleccionada: ruta,
        cajaRuta: ruta == null ? null : _buscarCaja(state.cajas, ruta.id),
      ),
    );
  }

  ///Otros
  ///
  DatumReporteCajaEntity? _buscarCaja(
    List<DatumReporteCajaEntity> cajas,
    String rutaId,
  ) {
    for (final c in cajas) {
      if (c.rutaId == rutaId) return c;
    }
    return null;
  }
}
