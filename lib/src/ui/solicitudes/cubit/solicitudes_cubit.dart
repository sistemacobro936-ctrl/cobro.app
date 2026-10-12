import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/solicitud_cliente_entity.dart';
import 'package:personal/src/domain/repository/solicitud_cliente_repo.dart';

part 'solicitudes_state.dart';

/// Solicitudes de clientes de otro negocio (cliente + préstamo). El
/// administrador las aprueba o rechaza; el cobrador solo ve las suyas.
class SolicitudesCubit extends Cubit<SolicitudesState> {
  final _solicitudRepo = sl<SolicitudClienteRepo>();

  SolicitudesCubit(BuildContext context, {required bool esAdmin})
    : super(SolicitudesState(context: context, esAdmin: esAdmin)) {
    cargar();
  }

  Future<void> cargar() async {
    emit(state.copyWith(loading: true));
    final r = await _solicitudRepo.listar(
      estado: state.filtroEstado.isEmpty ? null : state.filtroEstado,
    );
    if (isClosed) return;

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (data) => emit(state.copyWith(solicitudes: data)),
    );
    emit(state.copyWith(loading: false));
  }

  /// '' = todas
  void seleccionarEstado(String estado) {
    if (estado == state.filtroEstado) return;
    emit(state.copyWith(filtroEstado: estado, solicitudes: []));
    cargar();
  }

  /// Crea el cliente y su préstamo; el dinero sale de la caja abierta hoy
  /// en la ruta. Devuelve true si se aprobó.
  Future<bool> aprobar(SolicitudClienteEntity s) async {
    final ok = await AppDialogUtil.confirmar(
      state.context,
      title: 'Aprobar solicitud',
      message:
          'Se creará el cliente ${s.cliente.nombres} ${s.cliente.apellidos} '
          'en la ruta "${s.rutaNombre}" y su préstamo por '
          '${MoneyUtil.format(s.prestamo.monto)}, que sale de la caja abierta '
          'hoy en esa ruta.',
      confirmText: 'Aprobar',
    );
    if (!ok || isClosed) return false;

    emit(state.copyWith(procesando: true));
    final r = await _solicitudRepo.aprobar(id: s.id);
    if (isClosed) return false;
    emit(state.copyWith(procesando: false));

    final error = r.fold((l) => l.props[0].toString(), (_) => null);
    if (error != null) {
      AppDialogUtil.error(state.context, message: error);
      return false;
    }

    // Se espera a que cierre el aviso antes de que la pantalla navegue
    await AppDialogUtil.success(
      state.context,
      message:
          'Solicitud aprobada. Se creó el cliente y su préstamo; avisa al '
          'cobrador para que lo entregue.',
    );
    return true;
  }

  Future<bool> rechazar(SolicitudClienteEntity s, String? motivo) async {
    emit(state.copyWith(procesando: true));
    final r = await _solicitudRepo.rechazar(id: s.id, motivo: motivo);
    if (isClosed) return false;
    emit(state.copyWith(procesando: false));

    return r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
        return false;
      },
      (_) {
        AppDialogUtil.success(state.context, message: 'Solicitud rechazada.');
        cargar();
        return true;
      },
    );
  }
}
