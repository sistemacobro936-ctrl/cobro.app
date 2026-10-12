import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_home.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/create_client_view.dart';
import 'package:personal/src/ui/admin/views/detalle_cliente_view.dart';

// ignore: must_be_immutable
class ClienteDetalleView extends StatelessWidget {
  ClienteDetalleView({super.key});
  late DatumClEntity cliente;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClienteCubit, ClienteState>(
      builder: (context, state) {
        cliente = state.cliente!;
        final c = context.read<ClienteCubit>();
        return DetalleClienteView(
          cliente: cliente,
          showEdit: true,
          onBack: () {
            c.setChild(ClientHome());
          },
          onEdit: () {
            c.setChild(CreateClientView(isEdit: true));
          },
        );
      },
    );
  }
}
