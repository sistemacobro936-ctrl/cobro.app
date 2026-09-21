import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/gasto_ruta_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/gastos_ruta_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

const _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String _formatoFecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Gastos de una ruta que no dependen de una caja del día
class GastosRutaPage extends StatelessWidget {
  final DatumREntity ruta;

  const GastosRutaPage({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GastosRutaCubit(context: context, rutaId: ruta.id),
      child: _GastosRutaView(ruta: ruta),
    );
  }
}

class _GastosRutaView extends StatelessWidget {
  final DatumREntity ruta;

  const _GastosRutaView({required this.ruta});

  @override
  Widget build(BuildContext context) {
    final c = context.read<GastosRutaCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos de la ruta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ruta.nombre,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context, c),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar gasto'),
      ),
      body: BlocBuilder<GastosRutaCubit, GastosRutaState>(
        builder: (context, state) {
          return Column(
            children: [
              _selectorMes(state, c),
              // Mientras carga no se muestra el total del mes anterior
              if (state.resumen != null && !state.error && !state.loading)
                _resumen(state),
              Expanded(child: _lista(context, state, c)),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // MES
  // ============================================================

  Widget _selectorMes(GastosRutaState state, GastosRutaCubit c) {
    final ahora = DateTime.now();
    final esMesActual =
        state.mes.year == ahora.year && state.mes.month == ahora.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: state.loading ? null : () => c.cambiarMes(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              '${_meses[state.mes.month - 1]} ${state.mes.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF202838),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // No hay gastos en meses futuros
          IconButton(
            onPressed: state.loading || esMesActual
                ? null
                : () => c.cambiarMes(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _resumen(GastosRutaState state) {
    final r = state.resumen!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total gastado en el mes',
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
            '${r.cantidad} ${r.cantidad == 1 ? 'gasto' : 'gastos'}',
            style: const TextStyle(
              color: Colors.white,
          
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _lista(
    BuildContext context,
    GastosRutaState state,
    GastosRutaCubit c,
  ) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.error) {
      return _mensaje(
        icon: Icons.cloud_off_rounded,
        titulo: 'No se pudieron cargar los gastos',
        accion: TextButton(onPressed: c.cargar, child: const Text('Reintentar')),
      );
    }

    if (state.gastos.isEmpty) {
      return _mensaje(
        icon: Icons.receipt_long_outlined,
        titulo: 'Sin gastos en este mes',
        detalle: 'Usa "Agregar gasto" para registrar uno de esta ruta.',
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
          // Espacio extra para que el botón flotante no tape el último gasto
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: state.gastos.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if (i >= state.gastos.length) {
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
            return _GastoCard(gasto: state.gastos[i], cubit: c);
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF202838),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detalle != null) ...[
              const SizedBox(height: 6),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF929BAB)),
              ),
            ],
            ?accion,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA DE GASTO
// ============================================================

class _GastoCard extends StatefulWidget {
  final GastoRutaEntity gasto;
  final GastosRutaCubit cubit;

  const _GastoCard({required this.gasto, required this.cubit});

  @override
  State<_GastoCard> createState() => _GastoCardState();
}

class _GastoCardState extends State<_GastoCard> {
  bool _anulando = false;

  Future<void> _anular() async {
    final motivo = await _pedirMotivo(context);
    if (motivo == null) return;

    setState(() => _anulando = true);
    await widget.cubit.anular(id: widget.gasto.id, motivo: motivo);
    if (mounted) setState(() => _anulando = false);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.gasto;
    final anulado = g.anulado;
    final color = anulado ? const Color(0xFFB0B6C0) : Colors.redAccent;

    final meta = [
      if (g.fechaGasto != null) DateUtil.formatLectura(g.fechaGasto!),
      if (g.registradoPorNombre.isNotEmpty) g.registradoPorNombre,
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
            child: Icon(Icons.receipt_long_outlined, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.concepto,
                  style: TextStyle(
                    color: anulado
                        ? const Color(0xFF929BAB)
                        : const Color(0xFF202838),
                    fontWeight: FontWeight.w800,
                    decoration: anulado ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (g.observacion.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    g.observacion,
                    style: const TextStyle(
                      color: Color(0xFF687386),
                      
                    ),
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: Color(0xFF929BAB),
                    
                    ),
                  ),
                ],
                if (anulado) ...[
                  const SizedBox(height: 6),
                  Text(
                    g.motivoAnulacion.isEmpty
                        ? 'Anulado'
                        : 'Anulado: ${g.motivoAnulacion}',
                    style: const TextStyle(
                      color: Color(0xFFE05252),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                '-${MoneyUtil.format(g.valor)}',
                style: TextStyle(
                  color: color,
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
                            color: Color(0xFFE05252),
                          ),
                        ),
                      )
                    : Tooltip(
                        message: 'Anular gasto',
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
                              color: Color(0xFFE05252),
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

/// Pide el motivo de anulación; null si se cancela
Future<String?> _pedirMotivo(BuildContext context) {
  final controller = TextEditingController();
  String? error;

  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Color(0xFFE05252), size: 20),
            SizedBox(width: 8),
            Text(
              'Anular gasto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202838),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El gasto dejará de contar en los totales. Esta acción no se puede deshacer.',
              style: TextStyle(color: Color(0xFF687386), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (error != null) setState(() => error = null);
              },
              decoration: InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ej: Registrado por error',
                errorText: error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF929BAB)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final motivo = controller.text.trim();
              if (motivo.isEmpty) {
                setState(() => error = 'Ingresa el motivo');
                return;
              }
              Navigator.pop(ctx, motivo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE05252),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Anular',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// FORMULARIO
// ============================================================

void _mostrarFormulario(BuildContext context, GastosRutaCubit c) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FormularioGasto(cubit: c),
  );
}

class _FormularioGasto extends StatefulWidget {
  final GastosRutaCubit cubit;

  const _FormularioGasto({required this.cubit});

  @override
  State<_FormularioGasto> createState() => _FormularioGastoState();
}

class _FormularioGastoState extends State<_FormularioGasto> {
  final _concepto = TextEditingController();
  final _valor = TextEditingController();
  final _observacion = TextEditingController();
  DateTime _fecha = DateUtils.dateOnly(DateTime.now());
  bool _guardando = false;
  String? _errorConcepto;
  String? _errorValor;

  @override
  void dispose() {
    _concepto.dispose();
    _valor.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: hoy.subtract(const Duration(days: 365)),
      // El backend no acepta gastos con fecha futura
      lastDate: hoy,
    );
    if (date != null) setState(() => _fecha = date);
  }

  Future<void> _guardar() async {
    final concepto = _concepto.text.trim();
    final valor = int.tryParse(
      _valor.text.replaceAll('.', '').replaceAll(',', '').trim(),
    );

    setState(() {
      _errorConcepto = concepto.isEmpty ? 'Ingresa el concepto' : null;
      _errorValor = valor == null || valor <= 0
          ? 'Ingresa un valor mayor a 0'
          : null;
    });
    if (_errorConcepto != null || _errorValor != null) return;

    setState(() => _guardando = true);
    final ok = await widget.cubit.crear(
      concepto: concepto,
      valor: valor!,
      fecha: _fecha,
      observacion: _observacion.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agregar gasto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'No depende de la caja del día.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF929BAB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              InputWidget.input(
                label: 'Concepto',
                hintText: 'Ej: Alquiler oficina',
                prefixIcon: Icons.receipt_long_outlined,
                controller: _concepto,
                textInputAction: TextInputAction.next,
                errorText: _errorConcepto,
                enabled: !_guardando,
                onChanged: (_) {
                  if (_errorConcepto != null) {
                    setState(() => _errorConcepto = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              InputWidget.input(
                label: 'Valor',
                hintText: 'Ej: 350000',
                prefixIcon: Icons.attach_money_rounded,
                controller: _valor,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                errorText: _errorValor,
                enabled: !_guardando,
                onChanged: (_) {
                  if (_errorValor != null) setState(() => _errorValor = null);
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _guardando ? null : _elegirFecha,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: .05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: Color(0xFF7B8494),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Fecha del gasto',
                          style: TextStyle(color: Color(0xFF7B8494)),
                        ),
                      ),
                      Text(
                        _fechaTexto(_fecha),
                        style: const TextStyle(
                          color: Color(0xFF202838),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              InputWidget.input(
                label: 'Observación (opcional)',
                prefixIcon: Icons.notes_rounded,
                controller: _observacion,
                maxLines: 2,
                enabled: !_guardando,
              ),
              const SizedBox(height: 22),
              BtnWidget.btn(
                text: 'Guardar gasto',
                icon: Icons.check_rounded,
                loading: _guardando,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: _guardar,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _fechaTexto(DateTime d) {
    final base = _formatoFecha(d);
    return DateUtils.isSameDay(d, DateTime.now()) ? 'Hoy · $base' : base;
  }
}
