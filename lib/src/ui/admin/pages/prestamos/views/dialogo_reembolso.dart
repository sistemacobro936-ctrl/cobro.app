import 'package:flutter/material.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/fechas_pago_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/dto/reembolso_dto.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Reembolso = renovación de crédito: del nuevo monto se descuentan la deuda
/// actual y el seguro; al cliente solo se le entrega la diferencia. Si la
/// caja de la ruta no alcanza, el backend rechaza la operación con un
/// mensaje propio, que se muestra tal cual.
///
/// Es el mismo formulario para admin (detalle de préstamo) y cobrador
/// (mientras cobra): quien llama resuelve el envío (PrestamoCubit o
/// CobradorRCubit, cada uno con su propio manejo de éxito/error), este
/// widget no depende de ningún cubit en particular.
void mostrarDialogoReembolso(
  BuildContext context, {
  required DatumPEntity prestamo,
  required void Function(String prestamoId, ReembolsoDto dto) onConfirmar,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (_) =>
        _FormularioReembolso(prestamo: prestamo, onConfirmar: onConfirmar),
  );
}

class _FormularioReembolso extends StatefulWidget {
  final DatumPEntity prestamo;
  final void Function(String prestamoId, ReembolsoDto dto) onConfirmar;

  const _FormularioReembolso({
    required this.prestamo,
    required this.onConfirmar,
  });

  @override
  State<_FormularioReembolso> createState() => _FormularioReembolsoState();
}

class _FormularioReembolsoState extends State<_FormularioReembolso> {
  final _montoController = TextEditingController();
  final _interesController = TextEditingController();
  final _cuotasController = TextEditingController();

  SCobroEntity? _periodo;
  DateTime _fechaInicial = DateTime.now();

  @override
  void initState() {
    super.initState();
    final config = Shared.getConfig;
    _interesController.text = (config?.configuracion.interesDefault ?? 0)
        .toString();
    _montoController.text = widget.prestamo.monto.toString();
    _periodo = Shared.getConfig!.periodosCobro.firstWhere(
      (e) => e.codigo == widget.prestamo.frecuencia,
    );
    _cuotasController.text = _periodo!.cuotas.toString();
    
  }

  @override
  void dispose() {
    _montoController.dispose();
    _interesController.dispose();
    _cuotasController.dispose();
    super.dispose();
  }

  // ── Cálculos ────────────────────────────────────────────────
  int get _monto => int.tryParse(_montoController.text) ?? 0;
  int get _interesPct => int.tryParse(_interesController.text) ?? 0;
  int get _montoInteres => (_monto * _interesPct / 100).toInt();
  int get _totalPrestamo => _monto + _montoInteres;

  int get _cuotas {
    final n = int.tryParse(_cuotasController.text.trim()) ?? 0;
    return n > 0 && n <= PrestamoCubit.maxCuotas ? n : 0;
  }

  int get _valorCuota => _cuotas > 0 ? (_totalPrestamo / _cuotas).toInt() : 0;

  /// Solo para mostrar una vista previa: el backend calcula el seguro real
  /// con la configuración vigente al momento de aplicar el reembolso.
  int get _seguroEstimado {
    final pct = Shared.getConfig?.configuracion.seguroDefault ?? 0;
    return (_monto * pct / 100).round();
  }

  int get _deudaActual => widget.prestamo.deudaActual;
  int get _descuento => _deudaActual + _seguroEstimado;
  int get _aEntregar => _monto - _descuento;

  DateTime? get _fechaFinal {
    if (_periodo == null || _cuotas <= 0) return null;
    final fechas = FechasPagoUtil.generar(
      fechaInicial: _fechaInicial,
      periodo: _periodo!,
      cuotas: _cuotas,
    );
    return fechas.isEmpty ? null : fechas.last;
  }

  bool get _puedeConfirmar =>
      _monto > 0 &&
      _cuotas > 0 &&
      _valorCuota > 0 &&
      _periodo != null &&
      _fechaFinal != null &&
      _aEntregar >= 0;

  void _onPeriodo(SCobroEntity p) {
    setState(() {
      _periodo = p;
      _cuotasController.text = p.cuotas?.toString() ?? '';
    });
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaInicial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (elegida != null) setState(() => _fechaInicial = elegida);
  }

  void _confirmar() {
    if (!_puedeConfirmar) return;

    final dto = ReembolsoDto(
      monto: _monto,
      interes: _interesPct,
      montoInteres: _montoInteres,
      numeroCuotas: _cuotas,
      valorCuota: _valorCuota,
      frecuencia: _periodo!.codigo!,
      fechaInicio: DateUtil.formatDate(_fechaInicial),
      fechaFin: DateUtil.formatDate(_fechaFinal!),
    );

    Navigator.pop(context);
    widget.onConfirmar(widget.prestamo.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    final periodos = Shared.getConfig?.periodosCobro ?? [];
    final montoIngresado = _montoController.text.trim().isNotEmpty;
    final entregaInvalida = montoIngresado && _aEntregar < 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                      color: AppTheme.primaryColor.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.autorenew_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ),
                        const Text(
                          'Reembolso (renovar crédito)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Deuda actual: ${MoneyUtil.format(_deudaActual)}',
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              InputWidget.input(
                label: 'Monto del nuevo préstamo',
                hintText: 'Ej: 1000',
                prefixIcon: Icons.attach_money_rounded,
                controller: _montoController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              InputWidget.input(
                label: 'Interés (%)',
                prefixIcon: Icons.percent_rounded,
                controller: _interesController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              const Text(
                'Frecuencia de cobro',
                style: TextStyle(color: Color(0xFF687386)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: periodos.map((p) {
                  final selected = _periodo?.id == p.id;
                  return ChoiceChip(
                    label: Text(p.nombre),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: .05),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF394354),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => _onPeriodo(p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              InputWidget.input(
                label: 'Número de cuotas',
                prefixIcon: Icons.repeat_rounded,
                controller: _cuotasController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              InkWell(
                onTap: _elegirFecha,
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
                    border: Border.all(
                      color: Colors.black.withValues(alpha: .05),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF7B8494),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Fecha inicial',
                          style: TextStyle(color: Color(0xFF7B8494)),
                        ),
                      ),
                      Text(
                        DateUtil.formatLectura(_fechaInicial),
                        style: const TextStyle(
                          color: Color(0xFF202838),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              _fila('Interés generado', MoneyUtil.format(_montoInteres)),
              _fila('Total a pagar', MoneyUtil.format(_totalPrestamo)),
              _fila('Valor cuota', MoneyUtil.format(_valorCuota)),
              _fila(
                'Fecha final',
                _fechaFinal == null
                    ? '-'
                    : DateUtil.formatLectura(_fechaFinal!),
              ),

              const SizedBox(height: 10),
              _fila(
                'Seguro estimado',
                MoneyUtil.format(_seguroEstimado),
                color: Colors.orange,
              ),
              _fila(
                'Se descuenta (deuda + seguro)',
                MoneyUtil.format(_descuento),
                color: Colors.redAccent,
              ),
              const SizedBox(height: 6),
              _fila(
                'Se entrega al cliente',
                MoneyUtil.format(_aEntregar < 0 ? 0 : _aEntregar),
                destacado: true,
                color: entregaInvalida
                    ? Colors.redAccent
                    : AppTheme.primaryColor,
              ),

              if (entregaInvalida) ...[
                const SizedBox(height: 8),
                const Text(
                  'El monto no alcanza a cubrir la deuda actual más el seguro.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],

            
              const SizedBox(height: 22),

              BtnWidget.btn(
                text: 'Confirmar reembolso',
                icon: Icons.check_rounded,
                enabled: _puedeConfirmar,
                onPressed: _puedeConfirmar ? _confirmar : null,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fila(
    String label,
    String value, {
    bool destacado = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? const Color(0xFF202838),
              
            ),
          ),
        ],
      ),
    );
  }
}
