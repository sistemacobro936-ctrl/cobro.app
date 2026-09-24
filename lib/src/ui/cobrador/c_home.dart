import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/cobrador/dialogo_gasto.dart';
import 'package:personal/src/ui/cobrador/drawer_cobrador.dart';
import 'package:personal/src/ui/cobrador/views/crear_prestamo_cobrador_view.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart' show BtnWidget;

class CHome extends StatefulWidget {
  const CHome({super.key});

  @override
  State<CHome> createState() => _CHomeState();
}

class _CHomeState extends State<CHome> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const DrawerCobrador(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
          icon: Icon(Icons.menu, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Mi jornada',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<CobradorRCubit, CobradorRState>(
          builder: (context, state) {
            final sinRutas = state.ruta == null || state.ruta!.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 14),

                if (sinRutas)
                  _buildSinRuta()
                else ...[
                  _buildClientes(),

                  const SizedBox(height: 12),

                  _buildResumen(),

                  const SizedBox(height: 12),

                  _buildGastos(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  Widget _buildSinRuta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: const Column(
        children: [
          Icon(Icons.route_outlined, size: 40, color: Color(0xFF929BAB)),
          SizedBox(height: 10),
          Text(
            'No tienes una ruta asignada',
            style: TextStyle(
              color: Color(0xFF202838),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Cuando el administrador te asigne una ruta podrás ver tus clientes, el resumen y registrar gastos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF929BAB)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _buildHeader() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final nombre = state.ruta?.firstOrNull?.cobrador?.nombre;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF4164E8),
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre != null ? 'Hola, $nombre 👋' : 'Hola 👋',
                      style: TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aquí tienes el resumen de tu jornada',
                      style: TextStyle(color: Color(0xFF929BAB)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  Widget _buildClientes() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clientes asociados',
                          style: TextStyle(
                            color: Color(0xFF202838),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Clientes asignados para hoy',
                          style: TextStyle(color: Color(0xFF929BAB)),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.totalClientes.toString(),
                      style: TextStyle(
                        color: Color(0xFF4164E8),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              BtnWidget.btn(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                text: "Ver clientes",
                onPressed: () {
                  c.clientesRuta();
                },
                icon: Icons.people_outline_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  Widget _buildResumen() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        if (state.resumenRuta == null ||
            state.resumenRuta!.isEmpty ||
            state.ruta == null ||
            state.ruta!.isEmpty) {
          return const SizedBox.shrink();
        }

        final gestion = state.resumenRuta!.first;

        // Resumen indexado por rutaId
        final gestionMap = {
          for (final item in gestion.gestionRuta ?? []) item.rutaId: item,
        };
        final rutasOrdenadas = [...state.ruta!]
          ..sort((a, b) {
            final aTieneResumen = gestionMap.containsKey(a.id);
            final bTieneResumen = gestionMap.containsKey(b.id);

            if (aTieneResumen && !bTieneResumen) return -1;
            if (!aTieneResumen && bTieneResumen) return 1;

            return 0;
          });
        return _expansionSection(
          title: 'Resumen del día',
          icon: Icons.dashboard_outlined,
          children: [
            ...rutasOrdenadas.map((ruta) {
              final resumen = gestionMap[ruta.id];

              final cobrado = resumen?.cobrado ?? 0;
              final montoPrestado = resumen?.montoPrestado ?? 0;
              final gastos = resumen?.gastos ?? 0;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE DE LA RUTA
                    Row(
                      children: [
                        const Icon(Icons.route_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ruta.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _dato(
                            'Cobrado hoy',
                            '\$ $cobrado',
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _dato(
                            'Clientes asociados',
                            '${ruta.cantidadClientes}',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _dato(
                            'Monto prestado',
                            '\$ $montoPrestado',
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: _dato(
                            'Gastos',
                            '\$ - $gastos',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),
                 
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ============================================================
  Widget _buildGastos() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final rutas = state.ruta ?? [];
        final c = context.read<CobradorRCubit>();

        // Construye las filas de gastos por ruta
        final gastosWidgets = <Widget>[];

        for (final ruta in rutas) {
          final cajaId = state.cajaId(ruta.id);
          final gastos = state.gastos(ruta.id);

          // Encabezado de ruta (solo si hay más de una)
          if (rutas.length > 1) {
            gastosWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      size: 16,
                      color: Color(0xFF929BAB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ruta.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF929BAB),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sin caja abierta
          if (cajaId == null) {
            gastosWidgets.add(
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'No hay caja abierta para esta ruta.',
                  style: TextStyle(color: Color(0xFF929BAB), fontSize: 13),
                ),
              ),
            );
            continue;
          }

          // Caja abierta pero sin gastos aún
          if (gastos == null || gastos.isEmpty) {
            gastosWidgets.add(
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'No hay gastos registrados.',
                  style: TextStyle(color: Color(0xFF929BAB), fontSize: 13),
                ),
              ),
            );
            continue;
          }

          // Filas de gastos
          for (final g in gastos) {
            gastosWidgets.add(_gasto(g.concepto, '\$${g.valor}'));
            gastosWidgets.add(const SizedBox(height: 8));
          }
        }

        // Total global
        final total = (state.gastosPorRuta.values)
            .expand((lista) => lista)
            .fold<int>(0, (sum, g) => sum + g.valor);

        return _expansionSection(
          title: 'Gastos',
          icon: Icons.receipt_long_outlined,
          children: [
            ...gastosWidgets,

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total gastos',
                    style: TextStyle(
                      color: Color(0xFF202838),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '\$$total',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: BtnWidget.btn(
                onPressed: () {
                  dialogoGasto(context, state.ruta ?? [], c);
                },
                icon: Icons.add,
                text: 'Registrar gasto',
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  Widget _expansionSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppTheme.primaryColor,
          collapsedIconColor: const Color(0xFF8A93A3),
          leading: Icon(icon, color: AppTheme.primaryColor, size: 21),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202838),
              fontWeight: FontWeight.w700,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: Color(0xFF929BAB))),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: color ?? const Color(0xFF202838),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _gasto(String titulo, String valor) {
    return Row(
      children: [
        const Icon(
          Icons.remove_circle_outline_rounded,
          color: Colors.redAccent,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(titulo, style: const TextStyle(color: Color(0xFF394354))),
        ),
        Text(
          '-$valor',
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
