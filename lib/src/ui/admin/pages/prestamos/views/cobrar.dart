import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/no_pago.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

Future<void> showCobroBottomSheet(
  BuildContext context, {
  required String clienteNombre,
  required int deudaActual,
  required int cuota,
  bool showNPago = true,
  required Function(String value) onConfirmar,
  void Function(NoPagoData data)? onNoPago,
}) {
  final valorController = TextEditingController(text: cuota.toString());

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool loading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final valor =
              num.tryParse(valorController.text.replaceAll(',', '.')) ?? 0;

          final puedePagar = valor > 0 && valor <= deudaActual && !loading;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador
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

                  // Título
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar cobro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              clienteNombre,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // No pagó: pequeño y arriba, lejos del botón principal
                      // para no tocarlo por accidente
                      if (onNoPago != null)
                        Visibility(
                          visible: showNPago,
                          child: TextButton(
                            onPressed: loading
                                ? null
                                : () async {
                                    final data = await showNoPagoBottomSheet(
                                      context,
                                      clienteNombre: clienteNombre,
                                    );
                                    if (data == null) return;
                          
                                    onNoPago(data);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('No pagó'),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Deuda actual
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: .05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deuda actual',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${deudaActual.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Campo valor
                  Text(
                    'Valor del cobro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Ingrese el valor',
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: .05),
                        ),
                      ),
                    ),
                  ),

                  // Error
                  if (valor > deudaActual && valor > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'El cobro no puede superar la deuda actual',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BtnWidget.btn(
                      loading: loading,
                      enabled: puedePagar,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      text: "Registrar cobro",
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        onConfirmar(valorController.text);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    //  ElevatedButton(
                    //   onPressed: puedePagar
                    //       ? () async {
                    //           setState(() {
                    //             loading = true;
                    //           });

                    // onConfirmar();

                    // if (context.mounted) {
                    //   Navigator.pop(context);
                    // }
                    //         }
                    //       : null,
                    //   style: ElevatedButton.styleFrom(
                    //     elevation: 0,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(15),
                    //     ),
                    //   ),
                    //   child: loading
                    //       ? const SizedBox(
                    //           width: 22,
                    //           height: 22,
                    //           child: CircularProgressIndicator(strokeWidth: 2),
                    //         )
                    //       : const Text(
                    //           'Registrar cobro',
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    // ),
                  ),

                  SizedBox(height: MediaQuery.sizeOf(context).height * .08),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
