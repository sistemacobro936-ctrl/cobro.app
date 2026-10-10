import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/ui/admin/pages/nomina/nomina_util.dart';

const nominaFondo = Color(0xFFF7F8FC);
const nominaTexto = Color(0xFF202838);
const nominaGris = Color(0xFF929BAB);
const nominaPeligro = Color(0xFFE05252);
const nominaAviso = Color(0xFFB7791F);

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

String fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

PreferredSizeWidget nominaAppBar(
  BuildContext context, {
  required String titulo,
  String? subtitulo,
}) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitulo != null)
          Text(
            subtitulo,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
      ],
    ),
  );
}

/// Tarjeta blanca con título para agrupar campos del formulario
class NominaSeccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  final Widget? accion;

  const NominaSeccion({
    super.key,
    required this.titulo,
    required this.child,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: nominaTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?accion,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

InputDecoration nominaDecoration({
  required String label,
  IconData? icon,
  String? errorText,
  String? prefixText,
  String? helperText,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    errorMaxLines: 2,
    helperText: helperText,
    helperMaxLines: 2,
    prefixText: prefixText,
    prefixIcon: icon != null ? Icon(icon) : null,
    filled: true,
    helperStyle: TextStyle(fontSize: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

/// Selector de empleado
class EmpleadoSelector extends StatelessWidget {
  final List<EmpleadoNomina> empleados;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String label;

  const EmpleadoSelector({
    super.key,
    required this.empleados,
    required this.value,
    required this.onChanged,
    this.label = 'Empleado',
  });

  @override
  Widget build(BuildContext context) {
    final existe = empleados.any((e) => e.id == value);
    return DropdownButtonFormField<String>(
      // La key fuerza a refrescar el valor cuando el cubit lo cambia
      key: ValueKey('empleado-$value-${empleados.length}'),
      initialValue: existe ? value : null,
      isExpanded: true,
      decoration: nominaDecoration(label: label, icon: Icons.badge_outlined),
      items: empleados
          .map(
            (e) => DropdownMenuItem(
              value: e.id,
              child: Text(
                '${e.nombre} · ${e.rol}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// Mes + atajos (Quincena 1, Quincena 2, Mes) + rango personalizado
class PeriodoSelector extends StatelessWidget {
  final PeriodoNomina periodo;
  final ValueChanged<PeriodoNomina> onChanged;
  final bool enabled;

  const PeriodoSelector({
    super.key,
    required this.periodo,
    required this.onChanged,
    this.enabled = true,
  });

  Future<void> _personalizado(BuildContext context) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: hoy(),
      initialDateRange: periodo.fin.isAfter(hoy())
          ? null
          : DateTimeRange(start: periodo.inicio, end: periodo.fin),
    );
    if (r == null) return;
    onChanged(
      PeriodoNomina(
        inicio: r.start,
        fin: r.end,
        atajo: AtajoPeriodo.personalizado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = periodo;
    final personalizado = p.atajo == AtajoPeriodo.personalizado;

    Widget chip(String texto, AtajoPeriodo atajo) => ChoiceChip(
      label: Text(texto),
      selected: p.atajo == atajo,
      onSelected: !enabled
          ? null
          : (_) => atajo == AtajoPeriodo.personalizado
                ? _personalizado(context)
                : onChanged(PeriodoNomina.deMes(p.mes, atajo)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!personalizado)
          Row(
            children: [
              IconButton(
                onPressed: enabled ? () => onChanged(p.moverMes(-1)) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_meses[p.mes.month - 1]} ${p.mes.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: nominaTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: enabled && !p.esMesActual
                    ? () => onChanged(p.moverMes(1))
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            chip('Quincena 1', AtajoPeriodo.quincena1),
            chip('Quincena 2', AtajoPeriodo.quincena2),
            chip('Mes', AtajoPeriodo.mes),
            chip('Personalizado', AtajoPeriodo.personalizado),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${fechaCorta(p.inicio)} – ${fechaCorta(p.fin)}',
          style: const TextStyle(color: nominaGris),
        ),
      ],
    );
  }
}

/// Nómina / Prima / Otro (texto libre)
class ConceptoSelector extends StatelessWidget {
  final ConceptoNomina value;
  final TextEditingController otroController;
  final ValueChanged<ConceptoNomina> onChanged;
  final String? errorOtro;
  final String etiquetaNomina;
  final bool enabled;

  const ConceptoSelector({
    super.key,
    required this.value,
    required this.otroController,
    required this.onChanged,
    this.errorOtro,
    this.etiquetaNomina = conceptoNomina,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String texto, ConceptoNomina c) => ChoiceChip(
      label: Text(texto),
      selected: value == c,
      onSelected: enabled ? (_) => onChanged(c) : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            chip(etiquetaNomina, ConceptoNomina.nomina),
            chip(conceptoPrima, ConceptoNomina.prima),
            chip('Otro', ConceptoNomina.otro),
          ],
        ),
        if (value == ConceptoNomina.otro) ...[
          const SizedBox(height: 10),
          TextField(
            controller: otroController,
            enabled: enabled,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: nominaDecoration(
              label: 'Concepto',
              icon: Icons.edit_note_rounded,
              errorText: errorOtro,
            ),
          ),
        ],
      ],
    );
  }
}

/// Campo de fecha del pago; no permite fechas futuras
class FechaPagoTile extends StatelessWidget {
  final DateTime fecha;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  const FechaPagoTile({
    super.key,
    required this.fecha,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final esHoy = DateUtils.isSameDay(fecha, DateTime.now());

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: !enabled
          ? null
          : () async {
              final d = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: hoy().subtract(const Duration(days: 365)),
                // El backend no acepta pagos con fecha futura
                lastDate: hoy(),
              );
              if (d != null) onChanged(d);
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_outlined, color: Color(0xFF7B8494)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Fecha del pago',
                style: TextStyle(color: Color(0xFF7B8494)),
              ),
            ),
            Text(
              esHoy ? 'Hoy · ${fechaCorta(fecha)}' : fechaCorta(fecha),
              style: const TextStyle(
                color: nominaTexto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input de dinero: solo dígitos, enteros COP
class ValorInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool dense;

  const ValorInput({
    super.key,
    required this.controller,
    this.label = 'Valor a pagar',
    this.errorText,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: nominaDecoration(
        label: label,
        icon: dense ? null : Icons.attach_money_rounded,
        prefixText: dense ? '\$ ' : null,
        errorText: errorText,
        helperText: helperText,
      ),
    );
  }
}

/// Aviso amarillo (no bloquea)
class NominaAviso extends StatelessWidget {
  final String texto;
  final IconData icon;
  final Color color;
  final Widget? accion;

  const NominaAviso({
    super.key,
    required this.texto,
    this.icon = Icons.warning_amber_rounded,
    this.color = nominaAviso,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: TextStyle(color: color)),
          ),
          ?accion,
        ],
      ),
    );
  }
}

/// Confirmación antes de pagar; true si el admin confirma
Future<bool> confirmarPagoNomina(
  BuildContext context, {
  required String empleado,
  required String concepto,
  required List<(String ruta, int valor)> repartos,
  List<String> advertencias = const [],
}) async {
  final total = repartos.fold<int>(0, (s, r) => s + r.$2);
  final unaRuta = repartos.length == 1;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Confirmar pago',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: nominaTexto,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$concepto\n$empleado',
              style: const TextStyle(
                color: nominaTexto,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (unaRuta)
              Text(
                'Se descontarán ${MoneyUtil.format(total)} del capital de la ruta ${repartos.first.$1}.',
                style: const TextStyle(color: Color(0xFF687386)),
              )
            else ...[
              const Text(
                'Se descontará del capital de cada ruta:',
                style: TextStyle(color: Color(0xFF687386)),
              ),
              const SizedBox(height: 8),
              ...repartos.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(r.$1)),
                      Text(
                        MoneyUtil.format(r.$2),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    MoneyUtil.format(total),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
            for (final a in advertencias) ...[
              const SizedBox(height: 10),
              NominaAviso(texto: a),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar', style: TextStyle(color: nominaGris)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Pagar'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Pide el motivo de anulación; null si se cancela
Future<String?> pedirMotivoAnulacion(BuildContext context) {
  final controller = TextEditingController();
  String? error;

  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: nominaPeligro, size: 20),
            SizedBox(width: 8),
            Text(
              'Anular pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: nominaTexto,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El valor se devolverá al capital de la ruta. Esta acción no se puede deshacer.',
              style: TextStyle(color: Color(0xFF687386)),
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
                hintText: 'Ej: Valor equivocado',
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
            child: const Text('Cancelar', style: TextStyle(color: nominaGris)),
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
              backgroundColor: nominaPeligro,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Anular'),
          ),
        ],
      ),
    ),
  );
}
