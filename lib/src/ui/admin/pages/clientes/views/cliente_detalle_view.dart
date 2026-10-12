import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_home.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/create_client_view.dart';
import 'package:personal/src/ui/admin/views/detalle_cliente_view.dart';
import 'package:personal/src/ui/mora/mora_widgets.dart';

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
          acciones: _estado(context, c),
        );
      },
    );
  }

  /// Estado actual y opción de cambiarlo (p. ej. marcar o quitar CLAVO)
  Widget _estado(BuildContext context, ClienteCubit c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text(
            'Estado',
            style: TextStyle(
              color: Color(0xFF7D8797),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          EstadoClienteChip(estado: cliente.estado),
          const Spacer(),
          PopupMenuButton<String>(
            tooltip: 'Cambiar estado',
            onSelected: (nuevo) async {
              final ok = await cambiarEstadoCliente(
                context,
                clienteId: cliente.id,
                nombre: '${cliente.nombres} ${cliente.apellidos}',
                estadoActual: cliente.estado,
                nuevoEstado: nuevo,
              );
              if (ok) {
                c.detalleCliente(cliente.id);
                c.listClientes();
              }
            },
            itemBuilder: (_) => [
              for (final e in estadosCliente.entries)
                if (e.key != cliente.estado)
                  PopupMenuItem(
                    value: e.key,
                    child: Text(
                      e.key == 'CLAVO' ? 'Marcar como CLAVO' : 'Pasar a ${e.value}',
                    ),
                  ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                'Cambiar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
