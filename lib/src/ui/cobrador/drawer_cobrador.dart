import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/secure_storage_util.dart';
import 'package:personal/src/ui/auth/auth_page.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';

class DrawerCobrador extends StatelessWidget {
  const DrawerCobrador({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F7FC),
      child: BlocBuilder<CobradorRCubit, CobradorRState>(
        builder: (context, state) {
          final cobrador = state.ruta?.firstOrNull?.cobrador;
          final gestion = state.resumenRuta?.firstOrNull?.gestionRuta ?? [];

          final nombreCompleto = cobrador == null
              ? 'Cobrador'
              : '${cobrador.nombre} ${cobrador.apellido}'.trim();
          final totalClientes = context.read<CobradorRCubit>().totalClientes;
          final cobrado = gestion.fold<int>(0, (s, c) => s + c.cobrado);
          final gastos = gestion.fold<int>(0, (s, c) => s + c.gastos);

          return Column(
            children: [
              _header(
                safeTop: MediaQuery.of(context).padding.top,
                nombre: nombreCompleto,
                email: cobrador?.email,
                rutas: state.ruta?.length ?? 0,
                clientes: totalClientes,
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _sectionTitle('SESIÓN'),

                    _logoutItem(
                      onTap: () {
                        // El contexto del Navigator sigue vivo al cerrar el drawer
                        final navigatorContext = Navigator.of(context).context;
                        Navigator.pop(context);
                        _showLogoutDialog(
                          navigatorContext,
                          cobrado: cobrado,
                          gastos: gastos,
                          hayResumen: gestion.isNotEmpty,
                        );
                      },
                    ),
                  ],
                ),
              ),

              _footer(),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  Widget _header({
    required double safeTop,
    required String nombre,
    required String? email,
    required int rutas,
    required int clientes,
  }) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, safeTop + 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: .80),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
            ),
            child: Text(
              inicial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Cobrador',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              _chip(
                Icons.route_outlined,
                '$rutas ${rutas == 1 ? 'ruta' : 'rutas'}',
              ),
              const SizedBox(width: 8),
              _chip(
                Icons.people_outline_rounded,
                '$clientes ${clientes == 1 ? 'cliente' : 'clientes'}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9AA2AF),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _logoutItem({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: .10)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
        ),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'Finalizar mi jornada',
          style: TextStyle(color: Color(0xFF929BAB), fontSize: 11),
        ),
      ),
    );
  }

  Widget _footer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'CobroAPP',
              style: TextStyle(
                color: Color(0xFF929BAB),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Text(
              'v1.0.0',
              style: TextStyle(color: Color(0xFFB0B6C0), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  void _showLogoutDialog(
    BuildContext context, {
    required int cobrado,
    required int gastos,
    required bool hayResumen,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '¿Terminaste tu jornada?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF202838),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Vas a cerrar tu sesión. Para volver a cobrar tendrás que iniciar sesión de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF687386), ),
              ),

              
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(dialogContext);
                      await SecureStorageUtil().deleteAll();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Cerrar sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Seguir cobrando'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resumenDato(String titulo, String valor, Color color) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(color: Color(0xFF929BAB), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
