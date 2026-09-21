import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/caja/caja_page.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/crear_ruta_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/gastos_ruta_page.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_detalle_view.dart';

class RutaHome extends StatefulWidget {
  const RutaHome({super.key});

  @override
  State<RutaHome> createState() => _RutaHomeState();
}

class _RutaHomeState extends State<RutaHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text("Rutas", style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<RutaCubit, RutaState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(height: 18),
              _header(),

              const SizedBox(height: 18),

              Expanded(
                child: state.rutas == null || state.rutas!.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: state.rutas!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _rutaCard(state.rutas![index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        final rutas = state.rutas ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de rutas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${rutas.length} rutas configuradas',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${rutas.where((e) => e.habilitada).length} activas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CARD RUTA
  // ============================================================

  Widget _rutaCard(DatumREntity ruta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ruta.nombre,
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ruta.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF929BAB)),
                    ),
                  ],
                ),
              ),

              _status(ruta.habilitada),
            ],
          ),

          const SizedBox(height: 16),

          Divider(height: 1, color: Colors.black.withValues(alpha: .06)),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _info(
                  icon: Icons.person_outline_rounded,
                  title: 'Cobrador',
                  value: ruta.cobrador == null
                      ? "Sin asignación"
                      : ruta.cobrador!.nombre,
                ),
              ),

              Container(
                width: 1,
                height: 35,
                color: Colors.black.withValues(alpha: .06),
              ),

              Expanded(
                child: _info(
                  icon: Icons.people_outline_rounded,
                  title: 'Clientes',
                  value: '${ruta.cantidadClientes}',
                ),
              ),

              BlocBuilder<RutaCubit, RutaState>(
                builder: (context, state) {
                  final c = context.read<RutaCubit>();
                  return PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF929BAB),
                    ),
                    onSelected: (value) {
                      _handleMenu(value, ruta);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'abrir',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CajaPage(rutaId: ruta.id),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Gestión caja'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ver',
                        onTap: () {
                          c.movimientoRuta(idRuta: ruta.id);
                          c.clienteRuta(idRuta: ruta.id);
                          c.onEventChild(RutaDetalleView(ruta: ruta));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Ver ruta'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          c.llenarForm(ruta);
                          c.onEventChild(
                            CrearRutaView(isEdit: true, idRuta: ruta.id),
                          );
                        },
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'gastos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GastosRutaPage(ruta: ruta),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Gastos de ruta'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          c.historico(rutaId: ruta.id);
                        },
                        value: 'Historico',
                        child: Row(
                          children: [
                            Icon(Icons.history_edu_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Historico'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _status(bool activa) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: activa
            ? Colors.green.withValues(alpha: .08)
            : Colors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: activa ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 5),

          Text(
            activa ? 'Activa' : 'Inactiva',
            style: TextStyle(
              color: activa ? Colors.green : Colors.red,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _info({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF929BAB))),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF394354),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.route_outlined,
                    size: 38,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'No hay rutas creadas',
                  style: TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Crea una ruta para comenzar a organizar '
                  'los clientes y asignar cobradores.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF929BAB), fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================

  void _handleMenu(String value, DatumREntity ruta) {
    switch (value) {
      case 'ver':
        _verRuta(ruta);
        break;

      case 'editar':
        break;

      case 'cobrador':
        break;

      case 'estado':
        setState(() {
          // ruta.h = !ruta.activa;
        });
        break;
    }
  }

  void _verRuta(DatumREntity ruta) {
    // Navegar a detalle de ruta
  }
}
