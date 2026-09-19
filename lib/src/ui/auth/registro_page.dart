import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/auth/cubit/registro_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistroCubit(context: context),
      child: BlocBuilder<RegistroCubit, RegistroState>(
        builder: (context, state) {
          final cubit = context.read<RegistroCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              title: const Text(
                'Crear cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registra tu negocio y crea el usuario administrador que lo gestionará.',
                    style: TextStyle(color: Color(0xFF7B8494), fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  _seccionTitulo('Datos del negocio', Icons.storefront_outlined),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Nombre del negocio',
                    controller: cubit.negNombreTxt,
                    prefixIcon: Icons.store_outlined,
                    enabled: !state.loading,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Documento (NIT)',
                    controller: cubit.negDocumentoTxt,
                    prefixIcon: Icons.badge_outlined,
                    enabled: !state.loading,
                    keyboardType: TextInputType.number,
                    
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Teléfono',
                    controller: cubit.negTelefonoTxt,
                    prefixIcon: Icons.call_outlined,
                    enabled: !state.loading,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Dirección',
                    controller: cubit.negDireccionTxt,
                    prefixIcon: Icons.location_on_outlined,
                    enabled: !state.loading,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 26),

                  _seccionTitulo(
                    'Datos del administrador',
                    Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: InputWidget.input(
                          label: 'Nombre',
                          controller: cubit.admNombreTxt,
                          enabled: !state.loading,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => cubit.enabledBtn(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputWidget.input(
                          label: 'Apellido',
                          controller: cubit.admApellidoTxt,
                          enabled: !state.loading,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => cubit.enabledBtn(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Documento',
                    controller: cubit.admDocumentoTxt,
                    prefixIcon: Icons.badge_outlined,
                    enabled: !state.loading,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Teléfono',
                    controller: cubit.admTelefonoTxt,
                    prefixIcon: Icons.call_outlined,
                    enabled: !state.loading,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Correo electrónico',
                    controller: cubit.admEmailTxt,
                    prefixIcon: Icons.email_outlined,
                    enabled: !state.loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Usuario',
                    controller: cubit.admUserTxt,
                    prefixIcon: Icons.alternate_email_rounded,
                    enabled: !state.loading,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => cubit.enabledBtn(),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Contraseña',
                    controller: cubit.admPassTxt,
                    prefixIcon: Icons.lock_outline_rounded,
                    enabled: !state.loading,
                    obscureText: !state.showPassword,
                    errorText: cubit.passwordError,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => cubit.enabledBtn(),
                    suffixIcon: state.showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixPressed: cubit.onShowPassword,
                  ),

                  const SizedBox(height: 28),

                  BtnWidget.btn(
                    text: 'Registrar negocio',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: cubit.registrar,
                    enabled: state.btnEnabled,
                    loading: state.loading,
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _seccionTitulo(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202838),
          ),
        ),
      ],
    );
  }
}
