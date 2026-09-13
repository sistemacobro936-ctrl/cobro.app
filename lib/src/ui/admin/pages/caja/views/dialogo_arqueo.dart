import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

import '../../../../../common/theme/theme.dart';

void mostrarModalArqueo(BuildContext context, CajaCubit c, int esperado) {
  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: c,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.calculate_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              const Text(
                'Realizar arqueo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: TextField(
            controller: c.dineroRecibido,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Valor recibido en efectivo',
              hintText: 'Ingrese el valor',
              prefixText: '\$ ',
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = int.tryParse(
                  c.dineroRecibido.text.replaceAll('.', '').replaceAll(',', ''),
                );

                if (valor == null || valor < 0) {
                  return;
                }
                c.arqueo(esperado);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    },
  );
}
