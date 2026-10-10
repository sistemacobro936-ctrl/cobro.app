import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/ui/admin/pages/nomina/cubit/pagar_cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/dialogo_comision.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';

/// Nómina › Cobrador: pago de nómina (capital de la ruta) o de seguro
/// (su % de la boleta); ambos salen del capital, un pago por cada ruta
class PagarCobradorPage extends StatelessWidget {
  const PagarCobradorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PagarCobradorCubit(context: context),
      child: const _PagarCobradorView(),
    );
  }
}

class _PagarCobradorView extends StatelessWidget {
  const _PagarCobradorView();

  @override
  Widget build(BuildContext context) {
    final c = context.read<PagarCobradorCubit>();

    return Scaffold(
      backgroundColor: nominaFondo,
      appBar: nominaAppBar(
        context,
        titulo: 'Pagar a cobrador',
        subtitulo: 'Nómina o seguro por cada ruta trabajada',
      ),
      body: BlocBuilder<PagarCobradorCubit, PagarCobradorState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final calculo = state.calculo;
          final ocupado = state.pagando != null || state.loadingCalculo;
          final seguro = state.tipo == ConceptoCalculo.seguro;

          return RefreshIndicator(
            onRefresh: c.calcular,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                NominaSeccion(
                  titulo: 'Cobrador y período',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmpleadoSelector(
                        label: 'Cobrador',
                        empleados: state.empleados,
                        value: state.empleadoId,
                        onChanged: ocupado ? null : c.seleccionarEmpleado,
                      ),
                      const SizedBox(height: 8),
                      PeriodoSelector(
                        periodo: state.periodo,
                        onChanged: c.cambiarPeriodo,
                        enabled: !ocupado,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ConceptoCalculo>(
                          segments: const [
                            ButtonSegment(
                              value: ConceptoCalculo.nomina,
                              icon: Icon(Icons.payments_outlined),
                              label: Text('Nómina'),
                            ),
                            ButtonSegment(
                              value: ConceptoCalculo.seguro,
                              icon: Icon(Icons.shield_outlined),
                              label: Text('Seguro'),
                            ),
                          ],
                          selected: {state.tipo},
                          onSelectionChanged: ocupado
                              ? null
                              : (s) => c.cambiarTipo(s.first),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        seguro
                            ? 'Su parte de la boleta. Sale del capital de la ruta.'
                            : 'Su sueldo: tú digitas el valor. Sale del capital de la ruta.',
                      ),
                      if (seguro && state.empleado != null) ...[
                        const SizedBox(height: 4),
                        _ComisionFila(state: state, cubit: c),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (state.empleadoId == null)
                  const _Vacio(
                    icon: Icons.badge_outlined,
                    texto: 'Elige un cobrador para ver su resumen del período.',
                  )
                else if (state.loadingCalculo)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (calculo != null) ...[
                  if (calculo.resumen.cajasAbiertas > 0) ...[
                    NominaAviso(
                      icon: Icons.lock_open_rounded,
                      texto:
                          'Hay ${calculo.resumen.cajasAbiertas} ${calculo.resumen.cajasAbiertas == 1 ? 'caja abierta' : 'cajas abiertas'} en el período: los valores todavía pueden cambiar.',
                    ),
                    const SizedBox(height: 8),
                  ],
                  _ResumenCalculo(calculo: calculo),
                  const SizedBox(height: 12),
                  _DetalleCalculo(calculo: calculo),
                  const SizedBox(height: 12),
                  NominaSeccion(
                    titulo: 'Datos del pago',
                    child: seguro
                        ? _DatosSeguro(
                            state: state,
                            cubit: c,
                            enabled: !ocupado,
                          )
                        : _DatosNomina(
                            state: state,
                            cubit: c,
                            enabled: !ocupado,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (calculo.rutas.isEmpty)
                    const _Vacio(
                      icon: Icons.route_outlined,
                      texto:
                          'El cobrador no tiene cajas en este período: no hay rutas para pagar.',
                    )
                  else
                    for (final r in calculo.rutas) ...[
                      _RutaCard(ruta: r, state: state, cubit: c),
                      const SizedBox(height: 10),
                    ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Vacio({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 38, color: nominaGris),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: nominaGris),
          ),
        ],
      ),
    );
  }
}

class _ComisionFila extends StatelessWidget {
  final PagarCobradorState state;
  final PagarCobradorCubit cubit;

  const _ComisionFila({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.percent_rounded, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(textoComision(state.comision))),
        TextButton(
          onPressed: state.pagando != null
              ? null
              : () => mostrarDialogoComision(
                  context,
                  nombre: state.empleado?.nombre ?? '',
                  actual: state.comision,
                  onGuardar: cubit.guardarComision,
                ),
          child: const Text('Cambiar %'),
        ),
      ],
    );
  }
}

/// Concepto (Nómina / Prima / Otro), fecha y observación del pago
class _DatosNomina extends StatelessWidget {
  final PagarCobradorState state;
  final PagarCobradorCubit cubit;
  final bool enabled;

  const _DatosNomina({
    required this.state,
    required this.cubit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConceptoSelector(
          value: state.concepto,
          otroController: cubit.conceptoOtroTxt,
          onChanged: cubit.cambiarConcepto,
          errorOtro: state.errorConcepto,
          enabled: enabled,
        ),
        const SizedBox(height: 14),
        FechaPagoTile(
          fecha: state.fecha,
          onChanged: cubit.cambiarFecha,
          enabled: enabled,
        ),
        const SizedBox(height: 14),
        _Observacion(cubit: cubit, enabled: enabled),
      ],
    );
  }
}

/// Fecha y observación del pago; el concepto siempre es "Seguro"
class _DatosSeguro extends StatelessWidget {
  final PagarCobradorState state;
  final PagarCobradorCubit cubit;
  final bool enabled;

  const _DatosSeguro({
    required this.state,
    required this.cubit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FechaPagoTile(
          fecha: state.fecha,
          onChanged: cubit.cambiarFecha,
          enabled: enabled,
        ),
        const SizedBox(height: 14),
        _Observacion(cubit: cubit, enabled: enabled),
      ],
    );
  }
}

class _Observacion extends StatelessWidget {
  final PagarCobradorCubit cubit;
  final bool enabled;

  const _Observacion({required this.cubit, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: cubit.observacionTxt,
      enabled: enabled,
      maxLines: 2,
      maxLength: 250,
      textCapitalization: TextCapitalization.sentences,
      decoration: nominaDecoration(
        label: 'Observación (opcional)',
        icon: Icons.notes_rounded,
      ),
    );
  }
}

/// Totales del cobrador en el período
class _ResumenCalculo extends StatelessWidget {
  final CalculoNominaEntity calculo;

  const _ResumenCalculo({required this.calculo});

  @override
  Widget build(BuildContext context) {
    final r = calculo.resumen;
    final seguro = calculo.concepto == ConceptoCalculo.seguro;

    Widget dato(String label, String valor) => SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: .80),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            calculo.cobradorNombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              dato(
                'Cajas',
                r.cajasAbiertas > 0
                    ? '${r.cajas} (${r.cajasAbiertas} abiertas)'
                    : '${r.cajas}',
              ),
              dato('Días trabajados', '${r.diasTrabajados}'),
              dato('Cobrado', MoneyUtil.format(r.cobrado)),
              dato('Prestado', MoneyUtil.format(r.prestado)),
              dato('Boleta generada', MoneyUtil.format(r.seguro)),
              dato('Interés', MoneyUtil.format(r.interesGenerado)),
              dato('Gastos', MoneyUtil.format(r.gastos)),
            ],
          ),
          if (seguro) ...[
            const Divider(color: Colors.white24, height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sugerido (${calculo.comisionPorcentaje?.round() ?? '—'} % de ${MoneyUtil.format(r.base ?? 0)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  MoneyUtil.format(r.montoSugerido ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Cajas y asignaciones que entraron en el cálculo (plegables)
class _DetalleCalculo extends StatelessWidget {
  final CalculoNominaEntity calculo;

  const _DetalleCalculo({required this.calculo});

  @override
  Widget build(BuildContext context) {
    String fecha(DateTime? d) => d == null ? '—' : DateUtil.formatLectura(d);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.assignment_ind_outlined),
            title: Text('Asignaciones (${calculo.asignaciones.length})'),
            subtitle: const Text(
              'Solo cuentan las cajas de los días con la ruta asignada',
            ),
            children: [
              for (final a in calculo.asignaciones)
                ListTile(
                  dense: true,
                  title: Text(a.rutaNombre, style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                    '${fecha(a.inicio)} → ${a.vigente ? 'vigente' : fecha(a.fin)}',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.point_of_sale_outlined),
            title: Text('Cajas (${calculo.cajas.length})'),
            children: [
              for (final caja in calculo.cajas)
                ListTile(
                  dense: true,
                  title: Text(
                    '${fecha(caja.fechaOperacion)}\n${caja.rutaNombre}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cobrado ${MoneyUtil.format(caja.cobrado)}\nPrestado ${MoneyUtil.format(caja.prestado)}\nBoleta ${MoneyUtil.format(caja.seguro)}\nGastos ${MoneyUtil.format(caja.gastos)}',
                    style: TextStyle(fontSize: 15),
                  ),
                  trailing: Text(
                    caja.estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: caja.estado.toUpperCase() == 'ABIERTA'
                          ? nominaAviso
                          : nominaGris,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Una ruta con su valor a pagar y su botón de pago
class _RutaCard extends StatelessWidget {
  final RutaCalculoNominaEntity ruta;
  final PagarCobradorState state;
  final PagarCobradorCubit cubit;

  const _RutaCard({
    required this.ruta,
    required this.state,
    required this.cubit,
  });

  bool get _seguro => state.tipo == ConceptoCalculo.seguro;

  @override
  Widget build(BuildContext context) {
    final t = ruta.totales;
    final controller = cubit.valoresTxt[ruta.rutaId];
    final valor = parseValor(controller?.text ?? '');
    final pagado = state.pagado(ruta.rutaId);
    final pagandoEsta = state.pagando == ruta.rutaId;
    final bloqueado = state.pagando != null || pagado != null;

    final detalle = _seguro
        ? 'Boleta ${MoneyUtil.format(t.base ?? t.seguro)} · ${state.calculo?.comisionPorcentaje?.round() ?? '—'} % · Sugerido ${MoneyUtil.format(t.montoSugerido ?? 0)}'
        : '${t.cajas} ${t.cajas == 1 ? 'caja' : 'cajas'} · ${t.diasTrabajados} ${t.diasTrabajados == 1 ? 'día' : 'días'} · Cobrado ${MoneyUtil.format(t.cobrado)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pagado != null
              ? Colors.green.withValues(alpha: .4)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ruta.rutaNombre,
                  style: const TextStyle(
                    color: nominaTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (pagado != null)
                Text(
                  'Pagado ${MoneyUtil.format(pagado)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(detalle),
          const SizedBox(height: 12),
          if (controller != null)
            ValorInput(
              controller: controller,
              enabled: !bloqueado,
              onChanged: (_) => cubit.onValorChanged(),
            ),
          const SizedBox(height: 8),
          ..._estadoFondos(valor),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: bloqueado ? null : () => _pagar(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: pagandoEsta
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _seguro ? Icons.shield_outlined : Icons.payments_outlined,
                    ),
              label: Text(_seguro ? 'Pagar seguro' : 'Pagar'),
            ),
          ),
        ],
      ),
    );
  }

  /// Disponible de la ruta: tanto nómina como seguro salen del capital
  List<Widget> _estadoFondos(int? valor) {
    final disponible = state.disponibles[ruta.rutaId];
    if (disponible == null) return [];
    return [
      Text('Disponible de la ruta: ${MoneyUtil.format(disponible)}'),
      if (valor != null && valor > disponible) ...[
        const SizedBox(height: 6),
        const NominaAviso(
          texto: 'Supera el disponible: el capital quedará negativo.',
        ),
      ],
    ];
  }

  Future<void> _pagar(BuildContext context) async {
    final valor = cubit.validarPago(ruta);
    if (valor == null) return;

    final nombre =
        state.calculo?.cobradorNombre ?? state.empleado?.nombre ?? '';
    final disponible = state.disponibles[ruta.rutaId];

    final ok = await confirmarPagoNomina(
      context,
      empleado: nombre,
      concepto: cubit.conceptoPago,
      repartos: [(ruta.rutaNombre, valor)],
      advertencias: [
        if (disponible != null && valor > disponible)
          'El capital de la ruta quedará negativo. El pago se registrará igual.',
        if ((state.calculo?.resumen.cajasAbiertas ?? 0) > 0)
          'Hay cajas abiertas en el período: los valores aún pueden cambiar.',
      ],
    );
    if (ok) await cubit.pagar(ruta, valor);
  }
}
