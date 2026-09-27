import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

void mostrarDialogoRetiroCapital(BuildContext context, CajaCubit c) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: c,
        child: _DialogoRetiroCapital(cubit: c),
      );
    },
  );
}

class _DialogoRetiroCapital extends StatefulWidget {
  final CajaCubit cubit;

  const _DialogoRetiroCapital({required this.cubit});

  @override
  State<_DialogoRetiroCapital> createState() => _DialogoRetiroCapitalState();
}

class _DialogoRetiroCapitalState extends State<_DialogoRetiroCapital> {
  final _valor = TextEditingController();
  final _observacion = TextEditingController();
  String? _errorValor;

  @override
  void dispose() {
    _valor.dispose();
    _observacion.dispose();
    super.dispose();
  }

  void _confirmar() {
    final valor = int.tryParse(
      _valor.text.replaceAll('.', '').replaceAll(',', '').trim(),
    );

    if (valor == null || valor <= 0) {
      setState(() => _errorValor = 'Ingresa un valor mayor a 0');
      return;
    }

    widget.cubit.retirarCapital(
      valor: valor,
      observacion: _observacion.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          const Text(
            'Retirar dinero',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _valor,
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_errorValor != null) setState(() => _errorValor = null);
            },
            decoration: InputDecoration(
              labelText: 'Valor a retirar',
              hintText: 'Ingrese el valor',
              prefixText: '\$ ',
              errorText: _errorValor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _observacion,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ej: Pago de arriendo',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Retirar'),
        ),
      ],
    );
  }
}
