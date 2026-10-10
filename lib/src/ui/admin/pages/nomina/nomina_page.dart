import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/historial_nomina_page.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/nomina_widgets.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/pagar_cobrador_page.dart';
import 'package:personal/src/ui/admin/pages/nomina/views/pagar_supervisor_page.dart';

/// Nómina y prima de los empleados (solo ADMIN).
/// Cada pago se guarda como gasto de ruta y se descuenta de su capital
class NominaPage extends StatelessWidget {
  const NominaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nominaFondo,
      appBar: nominaAppBar(
        context,
        titulo: 'Nómina',
        subtitulo: 'Pagos de nómina y prima',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _opcion(
            context,
            icon: Icons.delivery_dining_outlined,
            titulo: 'Pagar a cobrador',
            detalle: 'Sale completo del capital de su ruta.',
            page: const PagarCobradorPage(),
          ),
          const SizedBox(height: 12),
          _opcion(
            context,
            icon: Icons.supervisor_account_outlined,
            titulo: 'Pagar a supervisor / admin',
            detalle: 'Se reparte entre varias rutas.',
            page: const PagarSupervisorPage(),
          ),
          const SizedBox(height: 12),
          _opcion(
            context,
            icon: Icons.history_rounded,
            titulo: 'Historial',
            detalle: 'Pagos de un empleado; aquí se anulan.',
            page: const HistorialNominaPage(),
          ),
        ],
      ),
    );
  }

  Widget _opcion(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String detalle,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: nominaTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(detalle, style: const TextStyle(color: nominaGris)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: nominaGris),
          ],
        ),
      ),
    );
  }
}
