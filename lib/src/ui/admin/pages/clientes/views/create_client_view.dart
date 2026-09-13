import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_home.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/cliente_detalle_view.dart';
import 'package:personal/src/ui/admin/views/form_client_view.dart';

class CreateClientView extends StatelessWidget {
  final bool isEdit;
  const CreateClientView({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClienteCubit, ClienteState>(
      builder: (context, state) {
        final c = context.read<ClienteCubit>();
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () =>
                  c.setChild(isEdit ? ClienteDetalleView() : ClientHome()),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            title: Text(
              isEdit ? "Editar cliente" : 'Nuevo cliente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: FormClientView(
            isEdit: isEdit,
            cliente: state.cliente,

            loadingBtn: state.loadingBtn,
            action: (dto) {
              if (isEdit) {
                c.editarCliente(dto);
              } else {
                c.crearCliente(dto);
              }
            },
            onBack: () {
              c.setChild(ClientHome());
            },
          ),
        );
      },
    );
  }
}
