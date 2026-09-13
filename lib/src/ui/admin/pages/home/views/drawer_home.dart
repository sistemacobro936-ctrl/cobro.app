
import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/secure_storage_util.dart';
import 'package:personal/src/ui/admin/pages/config/config_page.dart';
import 'package:personal/src/ui/admin/pages/rutas/ruta_page.dart';
import 'package:personal/src/ui/auth/auth_page.dart';

class DrawerHome extends StatelessWidget {
  const DrawerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F7FC),
      child: SafeArea(
        child: Column(
          children: [
            _drawerHeader(),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _drawerSectionTitle('CUENTA'),

                  _drawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Mi perfil',
                    onTap: () {
                      Navigator.pop(context);

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const PerfilView(),
                      //   ),
                      // );
                    },
                  ),
                  SizedBox(height: 18),
                  _drawerSectionTitle('GESTIÓN'),

                  _drawerItem(
                    icon: Icons.route_outlined,
                    title: 'Rutas',
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RutaPage()),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConfigPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  _drawerSectionTitle('SESIÓN'),

                  _drawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesión',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            _drawerFooter(),
          ],
        ),
      ),
    );
  }
}

Widget _drawerHeader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 25, 20, 22),
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
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Andrés Ruiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Administrador',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),

        const SizedBox(height: 3),

        const Text(
          'admin@cobroapp.com',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    ),
  );
}

Widget _drawerSectionTitle(String title) {
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

Widget _drawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  final itemColor = color ?? const Color(0xFF394354);

  return Container(
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      onTap: onTap,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color != null
              ? color.withValues(alpha: .08)
              : AppTheme.primaryColor.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: itemColor, size: 20),
      ),

      title: Text(
        title,
        style: TextStyle(
          color: itemColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: color == null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B6C0),
              size: 20,
            )
          : null,
    ),
  );
}

Widget _drawerFooter() {
  return Padding(
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
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        icon: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: .08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: Colors.red, size: 26),
        ),

        title: const Text(
          'Cerrar sesión',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),

        content: const Text(
          '¿Está seguro que desea cerrar la sesión?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF687386), fontSize: 13),
        ),

        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: () async{
                    // context.read<AuthCubit>().logout();
                    await SecureStorageUtil().deleteAll();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>AuthPage()), (_)=>false);

                    // Navigator.pushReplacement(...)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salir'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
