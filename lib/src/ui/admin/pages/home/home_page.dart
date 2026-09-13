import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/ui/admin/pages/clientes/cliente_page.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cobrador_page.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';
import 'package:personal/src/ui/admin/pages/home/views/button_navigationa_view.dart';
import 'package:personal/src/ui/admin/pages/home/views/drawer_home.dart';
import 'package:personal/src/ui/admin/pages/home/views/resume_home_view.dart';
import 'package:personal/src/ui/admin/pages/prestamos/prestamos_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(context: context),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              key: context.read<HomeCubit>().scaffoldKey,
              drawer: const DrawerHome(),
              body: Stack(
                children: [
                  getChild(state.currentIndex),
                  Visibility(
                    visible: state.loadPay,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withValues(alpha: .3),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavWidget(
                currentIndex: state.currentIndex,
                onTap: state.loadPay
                    ? (index) {}
                    : (index) {
                        context.read<HomeCubit>().onCurrenteIndex(index);
                        context.read<HomeCubit>().onAsignarPrestamo(false);
                        Shared.setIdCliente = "";
                      },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getChild(int index) => switch (index) {
    0 => const ResumeHomeView(),
    1 => CobradorPage(),
    2 => Clientepage(),
    3 => PrestamosPage(),
    _ => const ResumeHomeView(),
  };
}
