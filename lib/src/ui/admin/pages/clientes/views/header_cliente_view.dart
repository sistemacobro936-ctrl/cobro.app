// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/create_client_view.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class HeaderClienteView extends StatelessWidget {
  HeaderClienteView({super.key});

  late Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return BlocBuilder<ClienteCubit, ClienteState>(
      builder: (context, state) {
        final c = context.read<ClienteCubit>();
        final clientes = state.clientes ?? [];
        return HeaderWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),

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
                          'Clientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 44,
                    width: _size.width * 0.35,
                    child: BtnWidget.btn(
                      text: "Nuevo",
                      borderRadius: 14,
                      foregroundColor: Colors.white,
                      icon: Icons.add_rounded,
                      onPressed: () {
                        c.clear();
                        c.setChild(CreateClientView());
                      },
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _metric(value: '${clientes.length}', label: 'Total'),

                  const SizedBox(width: 28),

                  _metric(
                    value:
                        '${clientes.where((e) => e.estado == "ACTIVO").length}',
                    label: 'Activos',
                  ),

                  const SizedBox(width: 28),

                  _metric(value: '\$18.2M', label: 'Cartera'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metric({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
