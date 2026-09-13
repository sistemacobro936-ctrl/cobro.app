import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';

class Clientepage extends StatefulWidget {
  const Clientepage({super.key});

  @override
  State<Clientepage> createState() => _ClientepageState();
}

class _ClientepageState extends State<Clientepage> {

late ClienteCubit _clienteCubit;

@override
  void initState() {
    super.initState();
    _clienteCubit = ClienteCubit(context);
    _clienteCubit.listClientes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>_clienteCubit,
      child: BlocBuilder<ClienteCubit, ClienteState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FC),
              body: state.loading
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : state.child,
            ),
          );
        },
      ),
    );
  }
}
