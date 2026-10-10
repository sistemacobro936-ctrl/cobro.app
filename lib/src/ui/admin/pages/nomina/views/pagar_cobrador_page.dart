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
import 'package:personal/src/ui/widgets/widgets.dart';

/// Nómina › Pagar a cobrador: un pago por cada ruta que trabajó en el período
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
        subtitulo: 'Nómina o prima por cada ruta trabajada',
      ),
      body: BlocBuilder<PagarCobradorCubit, PagarCobradorState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final bloqueado = state.loadingBtn;
          final calculo = state.calculo;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              NominaSeccion(
                titulo: '1. Cobrador y período',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmpleadoSelector(
                      label: 'Cobrador',
                      empleados: state.empleados,
                      value: state.empleadoId,
                      onChanged: bloqueado ? null : c.seleccionarEmpleado,
                    ),
                   
                    const SizedBox(height: 8),
                    PeriodoSelector(
                      periodo: state.periodo,
                      onChanged: c.cambiarPeriodo,
                      enabled: !bloqueado && !state.loadingCalculo,
                    ),
                    const SizedBox(height: 12),
                    BtnWidget.btn(
                      text: calculo == null ? 'Calcular' : 'Recalcular',
                      icon: Icons.calculate_outlined,
                      height: 46,
                      loading: state.loadingCalculo,
                      enabled: !bloqueado,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: .10,
                      ),
                      foregroundColor: AppTheme.primaryColor,
                      onPressed: c.calcular,
                    ),
                  ],
                ),
              ),
              if (calculo != null) ...[
                const SizedBox(height: 12),
                if (!calculo.comisionConfigurada) ...[
                  NominaAviso(
                    texto:
                        'Este cobrador no tiene comisión configurada: no hay monto sugerido. Configúrala o escribe los valores a mano.',
                    accion: TextButton(
                      onPressed: bloqueado
                          ? null
                          : () => _abrirComision(context, state, c),
                      child: const Text('Configurar'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (calculo.resumen.cajasAbiertas > 0) ...[
                  NominaAviso(
                    icon: Icons.lock_open_rounded,
                    texto:
                        'Hay ${calculo.resumen.cajasAbiertas} ${calculo.resumen.cajasAbiertas == 1 ? 'caja abierta' : 'cajas abiertas'} en el período: los valores aún pueden cambiar.',
                  ),
                  const SizedBox(height: 8),
                ],
                _ResumenCalculo(calculo: calculo),
                const SizedBox(height: 12),
                _DetalleCalculo(calculo: calculo),
                const SizedBox(height: 12),
                NominaSeccion(
                  titulo: '2. Valor por ruta',
                  child: calculo.rutas.isEmpty
                      ? const Text(
                          'El cobrador no tiene cajas en este período, así que no hay rutas para pagar.',
                          style: TextStyle(color: nominaGris),
                        )
                      : _ValoresPorRuta(state: state, cubit: c),
                ),
                const SizedBox(height: 12),
                NominaSeccion(
                  titulo: '3. Datos del pago',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConceptoSelector(
                        value: state.concepto,
                        otroController: c.conceptoOtroTxt,
                        onChanged: c.cambiarConcepto,
                        errorOtro: state.errorConcepto,
                        enabled: !bloqueado,
                      ),
                      const SizedBox(height: 14),
                      FechaPagoTile(
                        fecha: state.fecha,
                        onChanged: c.cambiarFecha,
                        enabled: !bloqueado,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: c.observacionTxt,
                        enabled: !bloqueado,
                        maxLines: 2,
                        maxLength: 250,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: nominaDecoration(
                          label: 'Observación (opcional)',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BtnWidget.btn(
                  text: 'Pagar',
                  icon: Icons.payments_outlined,
                  loading: state.loadingBtn,
                  enabled: c.pagosPendientes.isNotEmpty,
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () => _pagar(context, c),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _pagar(BuildContext context, PagarCobradorCubit c) async {
    if (!c.validar()) return;
    final state = c.state;
    final pagos = c.pagosPendientes;

    final sinCapital = [
      for (final (r, v) in pagos)
        if ((state.capitalRuta(r.rutaId) ?? v) < v) r.rutaNombre,
    ];

    final ok = await confirmarPagoNomina(
      context,
      empleado: state.calculo?.cobradorNombre ?? state.empleado?.nombre ?? '',
      concepto: textoConcepto(state.concepto, c.conceptoOtroTxt.text)!,
      repartos: [for (final (r, v) in pagos) (r.rutaNombre, v)],
      advertencias: [
        if (sinCapital.isNotEmpty)
          'El capital quedará negativo en: ${sinCapital.join(', ')}. El pago se registrará igual.',
        if ((state.calculo?.resumen.cajasAbiertas ?? 0) > 0)
          'Hay cajas abiertas: los valores del período aún pueden cambiar.',
      ],
    );
    if (ok) await c.pagar();
  }
}

Future<void> _abrirComision(
  BuildContext context,
  PagarCobradorState state,
  PagarCobradorCubit c,
) {
  return mostrarDialogoComision(
    context,
    nombre: state.empleado?.nombre ?? '',
    actual: state.comision,
    onGuardar: c.guardarComision,
  );
}


/// Totales del cobrador en el período y monto sugerido total
class _ResumenCalculo extends StatelessWidget {
  final CalculoNominaEntity calculo;

  const _ResumenCalculo({required this.calculo});

  @override
  Widget build(BuildContext context) {
    final r = calculo.resumen;

    Widget dato(String label, String valor) => SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
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
          Text(
            calculo.comisionConfigurada
                ? '${calculo.comisionPorcentaje} % de lo ${calculo.comisionBase?.titulo.toLowerCase() ?? ''}'
                : 'Comisión sin configurar',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              dato('Cajas', '${r.cajas} (${r.cajasAbiertas} abiertas)'),
              dato('Días trabajados', '${r.diasTrabajados}'),
              dato('Cobrado', MoneyUtil.format(r.cobrado)),
              dato('Prestado', MoneyUtil.format(r.prestado)),
              dato('Seguro', MoneyUtil.format(r.seguro)),
              dato('Interés generado', MoneyUtil.format(r.interesGenerado)),
              dato('Gastos', MoneyUtil.format(r.gastos)),
              dato('Base', r.base == null ? '—' : MoneyUtil.format(r.base!)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monto sugerido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                r.montoSugerido == null
                    ? '—'
                    : MoneyUtil.format(r.montoSugerido!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
                ListTile(dense: true, title: Text(a.rutaNombre)),
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
                    '${fecha(caja.fechaOperacion)} · ${caja.rutaNombre}',
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Cobrado ${MoneyUtil.format(caja.cobrado)}\nPrestado ${MoneyUtil.format(caja.prestado)}\nSeguro ${MoneyUtil.format(caja.seguro)}\nGastos ${MoneyUtil.format(caja.gastos)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    caja.estado,
                    style: TextStyle(
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

/// Un input por ruta, prellenado con el monto sugerido de esa ruta
class _ValoresPorRuta extends StatelessWidget {
  final PagarCobradorState state;
  final PagarCobradorCubit cubit;

  const _ValoresPorRuta({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final rutas = state.calculo!.rutas;
    final total = cubit.pagosPendientes.fold<int>(0, (s, p) => s + p.$2);
    final bloqueado = state.loadingBtn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in rutas) ...[
          _filaRuta(r, bloqueado),
          const SizedBox(height: 12),
        ],
        const Text(
          'Las rutas que dejes en blanco no se pagan.',
          style: TextStyle(color: nominaGris),
        ),
        if (state.errorValores != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              state.errorValores!,
              style: const TextStyle(color: nominaPeligro, fontSize: 13),
            ),
          ),
        const Divider(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total a pagar',
                style: TextStyle(
                  color: nominaTexto,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              MoneyUtil.format(total),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filaRuta(RutaCalculoNominaEntity r, bool bloqueado) {
    final pagada = state.pagadas.contains(r.rutaId);
    final controller = cubit.valoresTxt[r.rutaId];
    final valor = parseValor(controller?.text ?? '');
    final capital = state.capitalRuta(r.rutaId);
    final t = r.totales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                r.rutaNombre,
                style: const TextStyle(
                  color: nominaTexto,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (pagada)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Pagada',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${t.cajas} cajas\n${t.diasTrabajados} días\nBase ${t.base == null ? '—' : MoneyUtil.format(t.base!)}\nSugerido ${t.montoSugerido == null ? '—' : MoneyUtil.format(t.montoSugerido!)}',
          style: const TextStyle(color: nominaGris),
        ),
        const SizedBox(height: 8),
        if (controller != null)
          ValorInput(
            controller: controller,
            enabled: !bloqueado && !pagada,
            helperText: capital == null
                ? null
                : 'Capital de la ruta: ${MoneyUtil.format(capital)}',
            onChanged: (_) => cubit.onValorChanged(),
          ),
        if (!pagada && valor != null && capital != null && valor > capital) ...[
          const SizedBox(height: 6),
          const NominaAviso(
            texto: 'Supera el capital de la ruta: quedará negativo.',
          ),
        ],
      ],
    );
  }
}
