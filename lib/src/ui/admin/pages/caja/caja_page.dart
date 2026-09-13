import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

class CajaPage extends StatefulWidget {
  final String rutaId;
  const CajaPage({super.key, required this.rutaId});

  @override
  State<CajaPage> createState() => _CajaPageState();
}

class _CajaPageState extends State<CajaPage> {
  bool loading = false;
  late CajaCubit _cubit;

  @override
  void initState() {
    super.initState();

    _cubit = CajaCubit(context: context);
    _cubit.listarCajar(rutaId: widget.rutaId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => _cubit,
        child: BlocBuilder<CajaCubit, CajaState>(
          builder: (context, state) {
            return state.loading
                ? Scaffold(body: Center(child: CircularProgressIndicator.adaptive()))
                : state.child;
          },
        ),
      ),
    );
  }
}
