import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/filter_button.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/header_p_view.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/prestamo_card_view.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/sear_p_view.dart';

class PrestamosHome extends StatelessWidget {
  const PrestamosHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrestamoCubit, PrestamoState>(
      builder: (context, state) {
        final prestamos = state.prestamos ?? [];
        return Column(
          children: [
            HeaderPView(),

            Visibility(
              visible: !state.loading,
              child: Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  children: [
                    SearPView(),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.prestamos == null
                                ? ""
                                : '${state.prestamos!.length} préstamos registrados',
                            style: TextStyle(
                              color: Color(0xFF929BAB),
                           
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FilterButton(),
                      ],
                    ),

                    ...prestamos.map(
                      (e) => Container(
                        margin: EdgeInsets.only(top: 14),
                        child: PrestamoCardView(
                          client: e.cliente.nombres,
                          document: 'CC ${e.cliente.cedula}',
                          route: "",
                          amount: '\$${e.deudaActual}',
                          installment: '\$${e.valorCuota}',
                          paid: 'Cobrar',
                          id: e.id,
                          status: 'Activo',
                          statusColor: const Color(0xFF4164E8),
                          statusBackground: const Color(0xFFEEF4FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
