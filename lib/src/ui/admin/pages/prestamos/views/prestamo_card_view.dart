import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/cobrar.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/prestamo_detalle_view.dart';

class PrestamoCardView extends StatelessWidget {
  const PrestamoCardView({
    super.key,
    required this.client,
    required this.document,
    required this.route,
    required this.amount,
    required this.installment,
    required this.paid,
    required this.status,
    required this.id,
    required this.statusColor,
    required this.statusBackground,
  });

  final String client;
  final String document;
  final String route;
  final String amount;
  final String installment;
  final String paid;
  final String status;
  final String id;
  final Color statusColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: .04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.request_quote_outlined,
                  color: Color(0xFF4164E8),
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            client,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF202838),

                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      document,
                      style: const TextStyle(color: Color(0xFF7D8797)),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      route,
                      style: const TextStyle(
                        color: Color(0xFF7D8797),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9AA2AF),
                ),
                onPressed: () {
                  context.read<PrestamoCubit>().detallePrestamo(id);
                  context.read<PrestamoCubit>().onGetChild(
                    PrestamoDetalleView(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(height: 1, color: Colors.black.withValues(alpha: .05)),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _loanInfo(
                  label: 'Monto',
                  value: amount,
                  icon: Icons.payments_outlined,
                ),
              ),

              Expanded(
                child: _loanInfo(
                  label: 'Cuota',
                  value: installment,
                  icon: Icons.calendar_today_outlined,
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showCobroBottomSheet(
                      context,
                      clienteNombre: client,
                      cuota: int.parse(installment.replaceAll("\$", "")),
                      deudaActual: int.parse(amount.replaceAll("\$", "")),
                      onConfirmar: (String value) async {
                        context
                            .read<HomeCubit>()
                            .pagar(
                              id: id,
                              monto: int.parse(value.replaceAll("\$", "")),
                            )
                            .then((e) {
                              if (e) {
                                // ignore: use_build_context_synchronously
                                context.read<PrestamoCubit>().listarPrestamo();
                              }
                            });
                      },
                      onNoPago: (data) {
                        context
                            .read<HomeCubit>()
                            .noPago(
                              id: id,
                              motivo: data.motivo,
                              observacion: data.observacion,
                              fechaPromesa: data.fechaPromesa,
                            )
                            .then((e) {
                              if (e) {
                                // ignore: use_build_context_synchronously
                                context.read<PrestamoCubit>().listarPrestamo();
                              }
                            });
                      },
                    );
                  },
                  child: _loanInfo(
                    label: 'Cobrar',
                    value: "Cobrar",
                    icon: Icons.attach_money_outlined,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanInfo({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF7B8494)),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF9AA2AF))),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF202838),

                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
