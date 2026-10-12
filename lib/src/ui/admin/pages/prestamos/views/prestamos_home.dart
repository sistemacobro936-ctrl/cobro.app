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
        final c = context.read<PrestamoCubit>();
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
                                : '${prestamos.length} ${prestamos.length == 1 ? 'préstamo' : 'préstamos'}'
                                  '${state.filtroEstado == 'TODOS' ? '' : ' ${FilterButton.opciones[state.filtroEstado]?.toLowerCase() ?? ''}'}',
                            style: TextStyle(
                              color: Color(0xFF929BAB),
                           
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FilterButton(
                          estado: state.filtroEstado,
                          onSelected: c.seleccionarEstado,
                        ),
                      ],
                    ),

                    ...prestamos.map(
                      (e) => Container(
                        margin: EdgeInsets.only(top: 14),
                        child: PrestamoCardView(
                          client: e.cliente.nombres,
                          document: 'CC: ${e.cliente.cedula}',
                          deuda: e.monto.toString(),
                          amount: '\$${e.deudaActual}',
                          installment: '\$${e.valorCuota}',
                          paid: 'Cobrar',
                          id: e.id,
                          status: _etiqueta(e.estado),
                          statusColor: _color(e.estado),
                          statusBackground: _color(e.estado).withValues(alpha: .10),
                          cobrable: e.estado == 'ACTIVO',
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

  String _etiqueta(String estado) => switch (estado) {
    'ACTIVO' => 'Activo',
    'PAGADO' => 'Pagado',
    'CANCELADO' => 'Cancelado',
    _ => estado,
  };

  Color _color(String estado) => switch (estado) {
    'ACTIVO' => const Color(0xFF4164E8),
    'PAGADO' => const Color(0xFF1E9E5A),
    _ => const Color(0xFF8A93A3),
  };
}
