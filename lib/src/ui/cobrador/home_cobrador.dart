import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/secure_storage_util.dart';
import 'package:personal/src/ui/auth/auth_page.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';

class HomeCobrador extends StatefulWidget {
  const HomeCobrador({super.key});

  @override
  State<HomeCobrador> createState() => _HomeCobradorState();
}

class _HomeCobradorState extends State<HomeCobrador> {
  late CobradorRCubit _cobradorCubit;

  @override
  void initState() {
    super.initState();
    _cobradorCubit = CobradorRCubit(context: context);
    _cobradorCubit.infoRuta();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => _cobradorCubit,
        child: BlocBuilder<CobradorRCubit, CobradorRState>(
          builder: (context, state) {
            return Scaffold(
           
              body: state.loading
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : state.child,
              floatingActionButton: IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    AppTheme.primaryColor,
                  ),
                ),
                onPressed: () {
                  _cobradorCubit.infoRuta();
                },
                icon: const Icon(Icons.update, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
