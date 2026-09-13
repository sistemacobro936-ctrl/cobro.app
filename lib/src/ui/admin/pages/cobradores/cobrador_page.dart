import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';

class CobradorPage extends StatefulWidget {
  const CobradorPage({super.key});

  @override
  State<CobradorPage> createState() => _CobradorPageState();
}

class _CobradorPageState extends State<CobradorPage> {

late CobradorCubit _cobradorCubit;



@override
  void initState() {
    super.initState();
    _cobradorCubit = CobradorCubit(context: context);
    _cobradorCubit.listarCobrador();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: BlocProvider(
        create: (context) => _cobradorCubit,
        child: BlocBuilder<CobradorCubit, CobradorState>(
          builder: (context, state) {
            return SafeArea(
              child: state.loading
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : state.child,
            );
          },
        ),
      ),
    );
  }
}
