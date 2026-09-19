import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

void mostrarDialogoGastoCaja(BuildContext context, CajaCubit c) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: c,
        child: _DialogoGastoCaja(cubit: c),
      );
    },
  );
}

class _DialogoGastoCaja extends StatefulWidget {
  final CajaCubit cubit;

  const _DialogoGastoCaja({required this.cubit});

  @override
  State<_DialogoGastoCaja> createState() => _DialogoGastoCajaState();
}

class _DialogoGastoCajaState extends State<_DialogoGastoCaja> {
  final _concepto = TextEditingController();
  final _valor = TextEditingController();
  final _observacion = TextEditingController();
  String? _errorConcepto;
  String? _errorValor;

  @override
  void dispose() {
    _concepto.dispose();
    _valor.dispose();
    _observacion.dispose();
    super.dispose();
  }

  void _confirmar() {
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

    widget.cubit.crearGasto(
      concepto: concepto,
      valor: valor!,
      observacion: _observacion.text.trim(),
    );
    Navigator.pop(context);
  }

  InputDecoration _decoration({
    String? label,
    String? hint,
    String? prefixText,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      errorText: errorText,
      alignLabelWithHint: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.redAccent),
          const SizedBox(width: 10),
          const Text(
            'Agregar gasto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _concepto,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_errorConcepto != null) {
                  setState(() => _errorConcepto = null);
                }
              },
              decoration: _decoration(
                label: 'Concepto',
                hint: 'Ej. Gasolina',
                errorText: _errorConcepto,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _valor,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_errorValor != null) setState(() => _errorValor = null);
              },
              decoration: _decoration(
                label: 'Valor',
                hint: 'Ingrese el valor',
                prefixText: '\$ ',
                errorText: _errorValor,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _observacion,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoration(hint: 'Observación (opcional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
