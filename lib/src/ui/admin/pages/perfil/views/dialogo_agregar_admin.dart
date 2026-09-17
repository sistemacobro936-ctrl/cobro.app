import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/perfil/cubit/perfil_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

void mostrarDialogoAgregarAdmin(BuildContext context, PerfilCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SingleChildScrollView(
              child: BlocBuilder<PerfilCubit, PerfilState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8DCE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Agregar administrador',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202838),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Crea un nuevo usuario administrador para el negocio.',
                        style: TextStyle(color: Color(0xFF929BAB)),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: InputWidget.input(
                              label: 'Nombre',
                              controller: cubit.nombreTxt,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => cubit.enabledBtn(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InputWidget.input(
                              label: 'Apellido',
                              controller: cubit.apellidoTxt,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => cubit.enabledBtn(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      InputWidget.input(
                        label: 'Documento',
                        controller: cubit.documentoTxt,
                        prefixIcon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => cubit.enabledBtn(),
                      ),

                      const SizedBox(height: 12),

                      InputWidget.input(
                        label: 'Teléfono',
                        controller: cubit.telefonoTxt,
                        prefixIcon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => cubit.enabledBtn(),
                      ),

                      const SizedBox(height: 12),

                      InputWidget.input(
                        label: 'Correo electrónico',
                        controller: cubit.emailTxt,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => cubit.enabledBtn(),
                      ),

                      const SizedBox(height: 12),

                      InputWidget.input(
                        label: 'Usuario',
                        controller: cubit.userTxt,
                        prefixIcon: Icons.alternate_email_rounded,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => cubit.enabledBtn(),
                      ),

                      const SizedBox(height: 12),

                      InputWidget.input(
                        label: 'Contraseña',
                        controller: cubit.passTxt,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !state.showPassword,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => cubit.enabledBtn(),
                        suffixIcon: state.showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixPressed: cubit.onShowPassword,
                      ),

                      const SizedBox(height: 20),

                      BtnWidget.btn(
                        text: 'Crear administrador',
                        icon: Icons.check_rounded,
                        enabled: state.btnEnabled,
                        loading: state.loadingBtn,
                        onPressed: () {
                          cubit.crearAdministrador();
                          Navigator.pop(context);
                        },
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
