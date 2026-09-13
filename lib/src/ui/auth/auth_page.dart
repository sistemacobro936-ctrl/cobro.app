import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/auth/cubit/auth_cubit.dart';
import 'package:personal/src/ui/auth/views/banner_auth_view.dart';
import 'package:personal/src/ui/auth/views/form_auth_view..dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(context),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            body: SafeArea(
              child: Column(
                children: [
                  const BannerAuthView(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        28,
                        20,
                        30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¡Bienvenido de nuevo!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D2433),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Ingresa tus credenciales para continuar.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7B8494),
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const FormAuthView(),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: BtnWidget.btn(
                              text: 'Ingresar',
                              icon: Icons.login_rounded,
                              onPressed: () {
                                context.read<AuthCubit>().login();
                              },
                              enabled: state.ennaled,
                              loading: state.loading,
                              backgroundColor: const Color(0xFF1D2433),
                              foregroundColor: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 15,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Gestión segura de tus cobros',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}