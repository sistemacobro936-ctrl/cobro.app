import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

void mostrarDialogoInyeccionCapital(BuildContext context, CajaCubit c) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: c,
        child: _DialogoInyeccionCapital(cubit: c),
      );
    },
  );
}

class _DialogoInyeccionCapital extends StatefulWidget {
  final CajaCubit cubit;

  const _DialogoInyeccionCapital({required this.cubit});

  @override
  State<_DialogoInyeccionCapital> createState() =>
      _DialogoInyeccionCapitalState();
}

class _DialogoInyeccionCapitalState extends State<_DialogoInyeccionCapital> {
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

    widget.cubit.inyectarCapital(
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
          Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          const Text(
            'Agregar dinero',
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
              labelText: 'Valor a agregar',
              hintText: 'Ingrese el valor',
              prefixText: '\$ ',
              errorText: _errorValor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
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
              hintText: 'Observación (opcional)',
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
