import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_card_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/filter_client_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/header_cliente_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/search_cliente_view.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClienteCubit, ClienteState>(
      builder: (context, state) {
        final clientes = state.clientes??[];
        return Column(
          children: [
            HeaderClienteView(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                children: [
                  SearchClienteView(
                    onSearch: (e) {
                      context.read<ClienteCubit>().buscar(e);
                    },
                  ),
                  Visibility(
                    visible: state.search,
                    child: Center(child: CircularProgressIndicator.adaptive())),
                  const SizedBox(height: 18),

                  Visibility(
                    visible: !state.loading,
                    child: Row(
                      children: [
                         Expanded(
                          child: Text(
                            '${clientes.length} clientes encontrados',
                            style: TextStyle(
                              color: Color(0xFF929BAB),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    
                        FilterClientView(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  ...clientes.map(
                    (c) => Container(
                      margin: EdgeInsets.only(top: 14),
                      child: ClientCardView(
                        id: c.id,
                        initials:
                            '${c.nombres.substring(0, 1).toUpperCase()}${c.apellidos.substring(0, 1).toUpperCase()}',
                        name: c.nombres,
                        document: 'CC ${c.cedula}',
                        route: c.rutaId.isEmpty
                            ? "Sin asignación"
                            : Shared.getRutas!
                                  .firstWhere((e) => e.id == c.rutaId)
                                  .nombre,
                        phone: c.telefono,
                        balance: '\$${c.totalPrestado}',
                        active: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
