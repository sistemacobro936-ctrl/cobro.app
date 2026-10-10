import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/dto/nomina_dto.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// % de la boleta del cobrador por defecto en el backend
const comisionPorDefecto = 30;

/// Texto corto del % de boleta: "30 % de la boleta"
String textoComision(ComisionEntity? c) {
  final p = c?.comisionPorcentaje;
  return p == null
      ? '$comisionPorDefecto % de la boleta (por defecto)'
      : '${p.round()} % de la boleta';
}

/// Configura el % de la boleta (seguro) que le corresponde al cobrador.
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
  late final _porcentajeTxt = TextEditingController(
    text: '${widget.actual?.comisionPorcentaje?.round() ?? comisionPorDefecto}',
  );
  String? _error;
  bool _guardando = false;

  @override
  void dispose() {
    _porcentajeTxt.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final p = int.tryParse(_porcentajeTxt.text.trim());
    setState(
      () => _error = p == null || p < 0 || p > 100
          ? 'Ingresa un % entero entre 0 y 100'
          : null,
    );
    if (_error != null) return;

    setState(() => _guardando = true);
    final ok = await widget.onGuardar(ComisionDto(comisionPorcentaje: p!));
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
              const Text(
                '% de la boleta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                widget.nombre,
                style: const TextStyle(fontSize: 13, color: nominaGris),
              ),
              const SizedBox(height: 12),
              const Text(
                'Parte del seguro (boleta) generado en sus cajas que le corresponde al cobrador. Solo aplica al pago de seguro, no a la nómina.',
                style: TextStyle(color: Color(0xFF687386), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _porcentajeTxt,
                enabled: !_guardando,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: nominaDecoration(
                  label: 'Porcentaje (%)',
                  icon: Icons.percent_rounded,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 22),
              BtnWidget.btn(
                text: 'Guardar',
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
