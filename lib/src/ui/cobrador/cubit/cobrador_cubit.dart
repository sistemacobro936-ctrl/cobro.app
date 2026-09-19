import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/gasto_dto.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/dto/pago_dto.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/domain/entities/pago_ruta_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/domain/repository/gastos_repo.dart';
import 'package:personal/src/domain/repository/pago_repo.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/ui/cobrador/c_home.dart';
import 'package:personal/src/ui/cobrador/clientes.dart';

part 'cobrador_state.dart';

class CobradorRCubit extends Cubit<CobradorRState> {
  final _rutaRepo = sl<RutaRepo>();
  final _pagoRepo = sl<PagoRepo>();
  final _gastoRepo = sl<GastosRepo>();

  CobradorRCubit({required BuildContext context})
    : super(CobradorRState(context: context)) {
    onEventChild(CHome());
  }

  ///variables
  ///
  ///
  final concepto = TextEditingController();
  final valor = TextEditingController();
  final observacion = TextEditingController();

  ///Eventos
  ///
  ///
  void onEventChild(Widget c) {
    emit(state.copyWith(child: c));
  }

  ///Validaciones
  ///
  ///
  void validarForm() {
    bool e = false;

    if (concepto.text.isNotEmpty && valor.text.isNotEmpty) {
      e = true;
    }
    emit(state.copyWith(formGasto: e));
  }

  ///Peticiones
  ///
  ///
  ///
  void infoRuta() async {
    emit(state.copyWith(loading: true));
    final r = await _rutaRepo.rutaCobrador();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(ruta: r.data));
      },
    );
    // Sin rutas asignadas no hay resumen ni gastos que consultar
    if (tieneRutas) {
      await resumenRuta();
      await listarGastos();
    }

    emit(state.copyWith(loading: false));
  }

  void clientesRuta() async {
    if (!tieneRutas) return;
    emit(state.copyWith(loading: true));

    final rutas = state.ruta!;
    final idRutas = rutas.map((e) => e.id).join(',');
    final fecha = DateUtil.formatDate(DateTime.now());

    // Los no pagos de hoy se piden en paralelo, una petición por ruta
    final noPagosFuture = Future.wait(
      rutas.map((ruta) => _pagoRepo.noPagosRuta(rutaId: ruta.id, fecha: fecha)),
    );

    final r = await _rutaRepo.detalleRuta(idRuta: idRutas, esCobro: true);

    final noPagosInfo = <String, NoPagoRutaEntity>{};
    for (final resultado in await noPagosFuture) {
      resultado.fold(
        // Si falla no se bloquea el cobro: solo no se separan los no pagados
        (l) => log("no-pagos: $l"),
        (lista) {
          for (final n in lista) {
            noPagosInfo[n.prestamoId] = n;
          }
        },
      );
    }

    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (clientes) {
        final List<DetalleRutaEntity> pendientes = [];
        final List<DetalleRutaEntity> pagados = [];
        final List<DetalleRutaEntity> noPagados = [];

        for (final item in clientes) {
          final prestamos = item.cliente.prestamos;

          if (prestamos == null || prestamos.isEmpty) {
            pendientes.add(item);
            continue;
          }

          bool tienePagado = false;
          bool tieneNoPagado = false;
          bool tienePendiente = false;

          for (final prestamo in prestamos) {
            if (prestamo.yaPago == true) {
              tienePagado = true;
            } else if (noPagosInfo.containsKey(prestamo.id)) {
              // Registrado como no pago hoy: ya no es "pendiente"
              tieneNoPagado = true;
            } else {
              tienePendiente = true;
            }
          }

          if (tienePagado) pagados.add(item);
          if (tieneNoPagado) noPagados.add(item);
          if (tienePendiente) pendientes.add(item);
        }

        emit(
          state.copyWith(
            clientes: pendientes,
            pagados: pagados,
            noPagados: noPagados,
            noPagosInfo: noPagosInfo,
          ),
        );

        onEventChild(Clientes());
      },
    );

    emit(state.copyWith(loading: false));
  }

  Future<void> resumenRuta() async {
    if (!tieneRutas) return;
    emit(state.copyWith(loading: true));
    final idRutas = state.ruta!.map((e) => e.id).join(',');

    final r = await _rutaRepo.resumen(idsRuta: idRutas);
    r.fold(
      (l) {
        log("aaaa $l");
      },
      (r) {
        // Construye rutaId → cajaId de forma plana para acceso O(1)
        final cajaPorRuta = <String, String>{
          for (final datum in r.data)
            for (final caja in datum.gestionRuta ?? [])
              caja.rutaId: caja.id,
        };
        emit(state.copyWith(resumenRuta: r.data, cajaPorRuta: cajaPorRuta));
      },
    );
    emit(state.copyWith(loading: false));
  }
  Future<void> listarGastos() async {
    emit(state.copyWith(loading: true));

    // Una petición por cada ruta que tenga caja
    final resultado = <String, List<GastoElementEntity>>{};

    await Future.wait(
      state.cajaPorRuta.entries.map((entry) async {
        final rutaId = entry.key;
        final cajaId = entry.value;
        final r = await _gastoRepo.listarGastos(cajaId: cajaId);
        r.fold(
          (l) => resultado[rutaId] = [],
          (gastos) => resultado[rutaId] = gastos.data.gastos,
        );
      }),
    );

    emit(state.copyWith(gastosPorRuta: resultado, loading: false));
  }

  void pagar({required String prestamoId, required int valorPago}) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.pagar(
      dto: PagoDto(
        prestamoId: prestamoId,
        valor: valorPago,
        fechaPago: DateTime.now(),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        clientesRuta();
      },
    );
    emit(state.copyWith(btnLoading: false));
  }

  void noPago({
    required String prestamoId,
    required MotivoNoPago motivo,
    String? observacion,
    DateTime? fechaPromesa,
  }) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.noPago(
      dto: NoPagoDto(
        prestamoId: prestamoId,
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
        clientesRuta();
      },
    );
    emit(state.copyWith(btnLoading: false));
  }

  /// Revierte un pago y refresca el resumen y la lista de clientes
  Future<bool> revertirPago({required String pagoId}) async {
    emit(state.copyWith(btnLoading: true));
    final r = await _pagoRepo.revertirPago(idPago: pagoId);
    emit(state.copyWith(btnLoading: false));

    final ok = r.fold((l) {
      AppDialogUtil.error(state.context, message: l.props[0].toString());
      return false;
    }, (_) => true);

    if (ok) {
      await resumenRuta();
      clientesRuta();
    }
    return ok;
  }

  void crearGasto({required String idCaja}) async {
    emit(state.copyWith(loading: true));
    final r = await _gastoRepo.crearGasto(
      dto: CrearGastoDto(
        cajaId: idCaja,
        concepto: concepto.text,
        valor: int.parse(valor.text),
        observacion: observacion.text,
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(state.context, message: "Operación exitosa.");
        clear();
      },
    );
    await resumenRuta();
    await listarGastos();
    emit(state.copyWith(loading: false));
  }
  ///
  ///

  ///Otros
  ///
  ///

  bool get tieneRutas => state.ruta != null && state.ruta!.isNotEmpty;

  int get totalClientes => (state.ruta ?? []).fold(
    0,
    (total, ruta) => total + ruta.cantidadClientes,
  );

  void clear() {
    valor.clear();
    observacion.clear();
    concepto.clear();
  }
}
