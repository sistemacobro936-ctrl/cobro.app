import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/create_c_view.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

// ignore: must_be_immutable
class HeaderCCiew extends StatelessWidget {
  HeaderCCiew({super.key});

  late Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        final c = context.read<CobradorCubit>();
        final cobradores = state.cobradores ??[];
        return HeaderWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cobradores',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 44,
                    width: _size.width * 0.4,
                    child: BtnWidget.btn(
                      text: "Nuevo",
                      borderRadius: 14,
                      foregroundColor: Colors.white,
                      icon: Icons.add_rounded,
                      onPressed: () {
                        c.clear();
                        c.eventChild(CreateCView());
                      },
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ----------------------------------------------------
              // RESUMEN
              // ----------------------------------------------------
              Row(
                children: [
                  _headerMetric(
                    value: '${cobradores.length}',
                    label: 'Total',
                  ),

                  const SizedBox(width: 28),

                  _headerMetric(
                    value:
                        '${cobradores.where((e) => e.estado == "ACTIVO").length}',
                    label: 'Activos',
                  ),

                  const SizedBox(width: 28),

                  _headerMetric(value: '\$15.5M', label: 'Recaudado'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerMetric({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
