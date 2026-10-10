import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/ui/admin/pages/nomina/cubit/historial_nomina_cubit.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';

/// Nómina › Historial de pagos de un empleado
class HistorialNominaPage extends StatelessWidget {
  const HistorialNominaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistorialNominaCubit(context: context),
      child: const _HistorialNominaView(),
    );
  }
}

class _HistorialNominaView extends StatelessWidget {
  const _HistorialNominaView();

  @override
  Widget build(BuildContext context) {
    final c = context.read<HistorialNominaCubit>();

    return Scaffold(
      backgroundColor: nominaFondo,
      appBar: nominaAppBar(context, titulo: 'Historial de nómina'),
      body: BlocBuilder<HistorialNominaCubit, HistorialNominaState>(
        builder: (context, state) {
          if (state.loadingEmpleados) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: NominaSeccion(
                  titulo: 'Filtros',
                  child: Column(
                    children: [
                      EmpleadoSelector(
                        empleados: state.empleados,
                        value: state.empleadoId,
                        onChanged: state.loading ? null : c.seleccionarEmpleado,
                      ),
                      const SizedBox(height: 8),
                      PeriodoSelector(
                        periodo: state.periodo,
                        onChanged: c.cambiarPeriodo,
                        enabled: !state.loading,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.resumen != null && !state.error && !state.loading)
                _resumen(state.resumen!),
              Expanded(child: _lista(state, c)),
            ],
          );
        },
      ),
    );
  }

  Widget _resumen(ResumenNominaEntity r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: .80),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total pagado (activos)',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 3),
                Text(
                  MoneyUtil.format(r.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${r.cantidad} ${r.cantidad == 1 ? 'pago' : 'pagos'}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(HistorialNominaState state, HistorialNominaCubit c) {
    if (state.empleadoId == null) {
      return _mensaje(
        icon: Icons.badge_outlined,
        titulo: 'Elige un empleado',
        detalle: 'Verás los pagos de nómina y prima del período.',
      );
    }
    if (state.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.error) {
      return _mensaje(
        icon: Icons.cloud_off_rounded,
        titulo: 'No se pudo cargar el historial',
        accion: TextButton(onPressed: c.cargar, child: const Text('Reintentar')),
      );
    }
    if (state.pagos.isEmpty) {
      return _mensaje(
        icon: Icons.payments_outlined,
        titulo: 'Sin pagos en este período',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          c.cargarMas();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: c.cargar,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.pagos.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if (i >= state.pagos.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return _PagoCard(pago: state.pagos[i], cubit: c);
          },
        ),
      ),
    );
  }

  Widget _mensaje({
    required IconData icon,
    required String titulo,
    String? detalle,
    Widget? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: nominaTexto,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detalle != null) ...[
              const SizedBox(height: 6),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: nominaGris),
              ),
            ],
            ?accion,
          ],
        ),
      ),
    );
  }
}

class _PagoCard extends StatefulWidget {
  final PagoNominaEntity pago;
  final HistorialNominaCubit cubit;

  const _PagoCard({required this.pago, required this.cubit});

  @override
  State<_PagoCard> createState() => _PagoCardState();
}

class _PagoCardState extends State<_PagoCard> {
  bool _anulando = false;

  Future<void> _anular() async {
    final motivo = await pedirMotivoAnulacion(context);
    if (motivo == null) return;

    setState(() => _anulando = true);
    await widget.cubit.anular(id: widget.pago.id, motivo: motivo);
    if (mounted) setState(() => _anulando = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pago;
    final anulado = p.anulado;
    final color = anulado ? const Color(0xFFB0B6C0) : AppTheme.primaryColor;

    final meta = [
      if (p.fechaGasto != null) DateUtil.formatLectura(p.fechaGasto!),
      if (p.rutaNombre.isNotEmpty) p.rutaNombre,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_outlined, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.concepto,
                  style: TextStyle(
                    color: anulado ? nominaGris : nominaTexto,
                    fontWeight: FontWeight.w800,
                    decoration: anulado ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(meta, style: const TextStyle(color: nominaGris)),
                ],
                if (anulado) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: nominaPeligro.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Anulado',
                      style: TextStyle(
                        color: nominaPeligro,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyUtil.format(p.valor),
                style: TextStyle(
                  color: anulado ? nominaGris : nominaTexto,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  decoration: anulado ? TextDecoration.lineThrough : null,
                ),
              ),
              if (!anulado) ...[
                const SizedBox(height: 6),
                _anulando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: nominaPeligro,
                          ),
                        ),
                      )
                    : Tooltip(
                        message: 'Anular pago',
                        child: InkWell(
                          onTap: _anular,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              color: nominaPeligro,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
