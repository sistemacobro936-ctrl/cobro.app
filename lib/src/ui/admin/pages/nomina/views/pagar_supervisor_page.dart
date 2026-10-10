import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/ui/admin/pages/nomina/cubit/pagar_supervisor_cubit.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Nómina › Pagar a supervisor/administrador, repartido entre rutas
class PagarSupervisorPage extends StatelessWidget {
  const PagarSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PagarSupervisorCubit(context: context),
      child: const _PagarSupervisorView(),
    );
  }
}

class _PagarSupervisorView extends StatelessWidget {
  const _PagarSupervisorView();

  @override
  Widget build(BuildContext context) {
    final c = context.read<PagarSupervisorCubit>();

    return Scaffold(
      backgroundColor: nominaFondo,
      appBar: nominaAppBar(
        context,
        titulo: 'Pagar a supervisor / admin',
        subtitulo: 'Repartido entre varias rutas',
      ),
      body: BlocBuilder<PagarSupervisorCubit, PagarSupervisorState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final bloqueado = state.loadingBtn;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              NominaSeccion(
                titulo: '1. Empleado y concepto',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmpleadoSelector(
                      empleados: state.empleados,
                      value: state.empleadoId,
                      onChanged: bloqueado ? null : c.seleccionarEmpleado,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Por ahora solo se listan administradores: falta un endpoint que liste supervisores.',
                      style: TextStyle(color: nominaGris, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    ConceptoSelector(
                      value: state.concepto,
                      otroController: c.conceptoOtroTxt,
                      onChanged: c.cambiarConcepto,
                      errorOtro: state.errorConcepto,
                      etiquetaNomina: conceptoSupervisor,
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
              const SizedBox(height: 12),
              NominaSeccion(
                titulo: '2. Reparto por ruta',
                accion: TextButton.icon(
                  onPressed: bloqueado
                      ? null
                      : () => _repartirIguales(context, c, state),
                  icon: const Icon(Icons.balance_rounded, size: 18),
                  label: const Text('Partes iguales'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final f in state.filas) ...[
                      _FilaRepartoView(
                        key: ValueKey(f.key),
                        fila: f,
                        state: state,
                        cubit: c,
                        enabled: !bloqueado,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (state.filas.length < state.rutas.length)
                      TextButton.icon(
                        onPressed: bloqueado ? null : c.agregarFila,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar ruta'),
                      ),
                    if (state.errorRepartos != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          state.errorRepartos!,
                          style: const TextStyle(
                            color: nominaPeligro,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: nominaTexto,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          MoneyUtil.format(state.total),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BtnWidget.btn(
                text: 'Pagar',
                icon: Icons.payments_outlined,
                loading: state.loadingBtn,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: () => _pagar(context, c),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pagar(BuildContext context, PagarSupervisorCubit c) async {
    if (!c.validar()) return;
    final sinCapital = c.rutasSinCapital;

    final ok = await confirmarPagoNomina(
      context,
      empleado: c.state.empleado?.nombre ?? '',
      concepto: textoConcepto(
        c.state.concepto,
        c.conceptoOtroTxt.text,
        porDefecto: conceptoSupervisor,
      )!,
      repartos: c.desglose,
      advertencias: [
        if (sinCapital.isNotEmpty)
          'El capital quedará negativo en: ${sinCapital.join(', ')}. El pago se registrará igual.',
      ],
    );
    if (ok) await c.pagar();
  }

  Future<void> _repartirIguales(
    BuildContext context,
    PagarSupervisorCubit c,
    PagarSupervisorState state,
  ) async {
    final controller = TextEditingController(
      text: state.total > 0 ? '${state.total}' : '',
    );
    final total = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Repartir en partes iguales',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Se divide entre las rutas elegidas. El residuo va a la última. Luego puedes editar cada valor.',
              style: TextStyle(color: Color(0xFF687386), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: nominaDecoration(
                label: 'Total a pagar',
                icon: Icons.attach_money_rounded,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: nominaGris)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = parseValor(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Repartir'),
          ),
        ],
      ),
    );
    if (total != null) c.repartirIguales(total);
  }
}

class _FilaRepartoView extends StatelessWidget {
  final FilaReparto fila;
  final PagarSupervisorState state;
  final PagarSupervisorCubit cubit;
  final bool enabled;

  const _FilaRepartoView({
    super.key,
    required this.fila,
    required this.state,
    required this.cubit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = state.rutasDisponibles(fila);
    final ruta = state.rutas.where((r) => r.id == fila.rutaId).firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: DropdownButtonFormField<String>(
            key: ValueKey('fila-${fila.key}-${fila.rutaId}'),
            initialValue: fila.rutaId,
            isExpanded: true,
            decoration: nominaDecoration(
              label: 'Ruta',
              helperText: ruta == null
                  ? null
                  : 'Capital ${MoneyUtil.format(ruta.capital)}',
            ),
            items: opciones
                .map(
                  (r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(r.nombre, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: enabled ? (v) => cubit.cambiarRutaFila(fila, v) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: ValorInput(
            controller: fila.valorTxt,
            label: 'Valor',
            dense: true,
            enabled: enabled,
            onChanged: (_) => cubit.onValorChanged(),
          ),
        ),
        IconButton(
          onPressed: enabled && state.filas.length > 1
              ? () => cubit.quitarFila(fila)
              : null,
          icon: const Icon(Icons.close_rounded),
          color: nominaPeligro,
        ),
      ],
    );
  }
}
