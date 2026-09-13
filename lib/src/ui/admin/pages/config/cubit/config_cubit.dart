import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/dto/config_dto.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/domain/repository/config_repo.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  ///Repositorios
  ///
  ///
  final _configRepo = sl<ConfiguracionRepository>();

  ///Constructor
  ///
  ///
  ConfigCubit({required BuildContext context})
    : super(ConfigState(context: context)) {
    config();
  }

  ///Variables
  ///
  ///
  final interesCtrl = TextEditingController();
  final seguroCtrol = TextEditingController();

  ///Eventos
  ///
  ///

  ///Peticiones
  ///
  ///
  void config() async {
    emit(state.copyWith(loading: true));
    final r = await _configRepo.obtenerConfiguracion();
    emit(state.copyWith(loading: false));

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(config: r.data));
        Shared.setConfig = r.data;

        interesCtrl.value = interesCtrl.value.copyWith(
          text: r.data.configuracion.interesDefault.toString(),
        );
        seguroCtrol.value = seguroCtrol.value.copyWith(
          text: r.data.configuracion.seguroDefault.toString(),
        );
      },
    );
  }

  void actualizarConfiguracion() async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _configRepo.guardarConfiguracion(
      dto: ConfigDto(
        configuracion: ConfiguracionDto(
          interesDefault: (state.config!.configuracion.interesDefault),
          seguroDefault: (state.config!.configuracion.seguroDefault),
        ),
        diasCobro: state.config!.diasCobro
            .map(
              (e) => DiasCobroDto(
                diaSemana: e.diaSemana!,
                nombre: e.nombre,
                habilitado: e.habilitado,
              ),
            )
            .toList(),
        periodosCobro: state.config!.periodosCobro
            .map(
              (e) => PeriodosCobroDto(
                codigo: e.codigo!,
                nombre: e.nombre,
                cantidadDias: e.cantidadDias!,
                habilitado: e.habilitado,
              ),
            )
            .toList(),
      ),
    );
    emit(state.copyWith(loadingBtn: false));
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Configuración actualizada con éxito",
        );
       Shared.setConfig = state.config!; 
      },
    );
  }

  ///Navegacion
  ///

  ///Otros
  ///
  ///
  void enabledDisabledDay(SCobroEntity day) {
    final config = state.config;

    if (config == null) return;

    final updatedDays = config.diasCobro.map((e) {
      if (e.id == day.id) {
        return e.copyWith(habilitado: !e.habilitado);
      }

      return e;
    }).toList();

    emit(state.copyWith(config: config.copyWith(diasCobro: updatedDays)));
  }

  void enabledDisabledPeriod(SCobroEntity period) {
    final config = state.config;

    if (config == null) return;

    final updatedPeriods = config.periodosCobro.map((e) {
      if (e.id == period.id) {
        return e.copyWith(habilitado: !e.habilitado);
      }

      return e;
    }).toList();

    emit(
      state.copyWith(config: config.copyWith(periodosCobro: updatedPeriods)),
    );
  }

  void updateDaysPeriod(SCobroEntity p, int d) {
    final config = state.config;

    if (config == null) return;

    final updatedPeriods = config.periodosCobro.map((e) {
      if (e.id == p.id) {
        return e.copyWith(cantidadDias: d);
      }

      return e;
    }).toList();

    emit(
      state.copyWith(config: config.copyWith(periodosCobro: updatedPeriods)),
    );
  }
}
