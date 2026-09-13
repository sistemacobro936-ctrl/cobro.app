import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/auth/cubit/auth_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class FormAuthView extends StatelessWidget {
  const FormAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        return Column(
          children: [
            InputWidget.input(
              label: 'Usuario',
              hintText: 'Ingrese su usuario',
              controller: cubit.user,
              enabled: !state.loading,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                cubit.btnEnabled();
              },
            ),

            const SizedBox(height: 18),

            InputWidget.input(
              label: 'Contraseña',
              hintText: 'Ingrese su contraseña',
              controller: cubit.password,
              enabled: !state.loading,

              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !state.showPassword,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                cubit.btnEnabled();
              },
              suffixIcon: state.showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixPressed: () {
                cubit.onShowPassword();
              },
            ),
          ],
        );
      },
    );
  }
}
