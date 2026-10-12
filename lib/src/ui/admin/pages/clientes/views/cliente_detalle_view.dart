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
          acciones: cliente.pendienteAprobacion
              ? _aprobacion(c, state.loadingBtn)
              : null,
        );
      },
    );
  }

  Widget _aprobacion(ClienteCubit c, bool cargando) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C26B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 20,
                color: Color(0xFFB7791F),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Un cobrador registró este cliente, que ya tiene contrato '
                  'con otro negocio. Apruébalo para poder prestarle.',
                  style: TextStyle(
                    color: Color(0xFF8A5A0B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: cargando ? null : () => c.rechazarCliente(cliente),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: cargando ? null : () => c.aprobarCliente(cliente.id),
                  child: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
