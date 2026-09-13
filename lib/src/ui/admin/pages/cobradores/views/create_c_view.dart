import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/cobrador_home.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class CreateCView extends StatelessWidget {
  final bool isEdit;
  CreateCView({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<CobradorCubit, CobradorState>(
        builder: (context, state) {
          final c = context.read<CobradorCubit>();
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FC),
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  c.eventChild(CobradorHome());
                },
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              title: Text(
                isEdit ? "Editar cobrador" : 'Nuevo cobrador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),

                  const SizedBox(height: 24),

                  _sectionTitle(
                    icon: Icons.person_outline_rounded,
                    title: 'Información personal',
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    label: 'Nombre',
                    hintText: 'Ingrese el nombre',
                    prefixIcon: Icons.person_outline_rounded,
                    controller: c.nameTxt,
                    enabled: !state.loadingbtn,

                    onChanged: (e) {
                      c.enbaledBtn(isEdit: isEdit);
                    },
                  ),

                  const SizedBox(height: 16),

                  InputWidget.input(
                    label: 'Apellidos',
                    hintText: 'Ingrese los apellidos',
                    prefixIcon: Icons.person_outline_rounded,
                    controller: c.lastNameTxt,
                    enabled: !state.loadingbtn,

                    onChanged: (e) {
                      c.enbaledBtn(isEdit: isEdit);
                    },
                  ),

                  const SizedBox(height: 16),

                  InputWidget.input(
                    label: 'Cédula',

                    hintText: 'Ingrese el número de cédula',
                    prefixIcon: Icons.badge_outlined,
                    controller: c.ideTxt,
                    enabled: !state.loadingbtn && !isEdit,

                    keyboardType: TextInputType.number,
                    onChanged: (e) {
                      c.enbaledBtn(isEdit: isEdit);
                    },
                  ),

                  const SizedBox(height: 16),

                  InputWidget.input(
                    label: 'Número de contacto',
                    hintText: 'Ingrese el número de celular',
                    prefixIcon: Icons.phone_outlined,
                    controller: c.contacTxt,
                    enabled: !state.loadingbtn,

                    keyboardType: TextInputType.phone,
                    onChanged: (e) {
                      c.enbaledBtn(isEdit: isEdit);
                    },
                  ),

                  const SizedBox(height: 28),

                  Visibility(
                    visible: !isEdit,
                    child: _sectionTitle(
                      icon: Icons.lock_outline_rounded,
                      title: 'Acceso a la aplicación',
                    ),
                  ),

                  const SizedBox(height: 14),

                  Visibility(
                    visible: !isEdit,
                    child: InputWidget.input(
                      label: 'Usuario',
                      hintText: 'Asigne un usuario',
                      enabled: !state.loadingbtn,

                      prefixIcon: Icons.account_circle_outlined,
                      controller: c.userTxt,
                      onChanged: (e) {
                        c.enbaledBtn();
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Visibility(
                    visible: !isEdit,
                    child: InputWidget.input(
                      label: 'Contraseña',
                      hintText: 'Asigne una contraseña',
                      enabled: !state.loadingbtn,

                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: !state.showPass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixPressed: () {
                        c.onShowPassword();
                      },
                      controller: c.passTxt,
                      obscureText: state.showPass,

                      onChanged: (e) {
                        c.enbaledBtn();
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: BtnWidget.btn(
                      text: isEdit ? "Editar cobrador" : 'Crear cobrador',

                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () {
                        if (isEdit) {
                          c.editarCobrador();
                        } else {
                          c.crearCobrador();
                        }
                      },
                      loading: state.loadingbtn,
                      enabled: state.btnEnabled,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => c.eventChild(CobradorHome()),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: .25),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF687386),
                          fontWeight: FontWeight.w600,
                        ),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Visibility(
      visible: !isEdit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: .80),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.badge_outlined, color: Colors.white, size: 32),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrar cobrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Complete la información para crear el perfil.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202838),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
