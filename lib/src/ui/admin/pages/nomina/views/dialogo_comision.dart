import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Texto corto de una comisión: "5 % de lo cobrado" / "Sin configurar"
String textoComision(ComisionEntity? c) {
  if (c == null) return 'Sin consultar';
  if (!c.configurada) return 'Sin configurar';
  return '${_porcentaje(c.comisionPorcentaje!)} % · ${c.comisionBase!.titulo}';
}

String _porcentaje(num p) =>
    p == p.roundToDouble() ? p.toInt().toString() : p.toString();

/// Configura la base y el % de comisión de un usuario.
/// [onGuardar] devuelve true si se guardó (el error lo muestra quien llama)
Future<void> mostrarDialogoComision(
  BuildContext context, {
  required String nombre,
  required ComisionEntity? actual,
  required Future<bool> Function(ComisionDto dto) onGuardar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _DialogoComision(nombre: nombre, actual: actual, onGuardar: onGuardar),
  );
}

class _DialogoComision extends StatefulWidget {
  final String nombre;
  final ComisionEntity? actual;
  final Future<bool> Function(ComisionDto dto) onGuardar;

  const _DialogoComision({
    required this.nombre,
    required this.actual,
    required this.onGuardar,
  });

  @override
  State<_DialogoComision> createState() => _DialogoComisionState();
}

class _DialogoComisionState extends State<_DialogoComision> {
  late ComisionBase? _base = widget.actual?.comisionBase;
  late final _porcentajeTxt = TextEditingController(
    text: widget.actual?.comisionPorcentaje == null
        ? ''
        : _porcentaje(widget.actual!.comisionPorcentaje!),
  );
  String? _errorBase;
  String? _errorPorcentaje;
  bool _guardando = false;

  @override
  void dispose() {
    _porcentajeTxt.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final p = num.tryParse(_porcentajeTxt.text.replaceAll(',', '.').trim());
    final decimales = _porcentajeTxt.text.contains(RegExp(r'[.,]\d{3,}'));

    setState(() {
      _errorBase = _base == null ? 'Elige una base' : null;
      _errorPorcentaje = p == null || p < 0 || p > 100 || decimales
          ? 'Ingresa un % entre 0 y 100 (máx. 2 decimales)'
          : null;
    });
    if (_errorBase != null || _errorPorcentaje != null) return;

    setState(() => _guardando = true);
    final ok = await widget.onGuardar(
      ComisionDto(comisionBase: _base, comisionPorcentaje: p),
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
    final sinConfigurar =
        widget.actual != null && !widget.actual!.configurada;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comisión',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.nombre,
                          style: const TextStyle(
                            fontSize: 13,
                            color: nominaGris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sinConfigurar)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: nominaAviso.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Sin configurar',
                        style: TextStyle(
                          color: nominaAviso,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Base',
                style: TextStyle(
                  color: nominaTexto,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              RadioGroup<ComisionBase>(
                groupValue: _base,
                onChanged: (v) => _guardando
                    ? null
                    : setState(() {
                        _base = v;
                        _errorBase = null;
                      }),
                child: Column(
                  children: ComisionBase.values
                      .map(
                        (b) => RadioListTile<ComisionBase>(
                          value: b,
                          contentPadding: EdgeInsets.zero,
                          title: Text(b.titulo),
                          subtitle: Text(
                            b.descripcion,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (_errorBase != null)
                Text(
                  _errorBase!,
                  style: const TextStyle(color: nominaPeligro, fontSize: 12),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _porcentajeTxt,
                enabled: !_guardando,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) {
                  if (_errorPorcentaje != null) {
                    setState(() => _errorPorcentaje = null);
                  }
                },
                decoration: nominaDecoration(
                  label: 'Porcentaje (%)',
                  icon: Icons.percent_rounded,
                  errorText: _errorPorcentaje,
                ),
              ),
              const SizedBox(height: 22),
              BtnWidget.btn(
                text: 'Guardar comisión',
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
}
