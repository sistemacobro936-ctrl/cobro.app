import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/pago_entity.dart';
import 'package:personal/src/domain/entities/pago_ruta_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/cobrar.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/dialogo_reembolso.dart';
import 'package:personal/src/ui/cobrador/c_home.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/cobrador/views/crear_prestamo_cobrador_view.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';
import 'package:personal/src/ui/widgets/input_widget.dart';

class Clientes extends StatelessWidget {
  const Clientes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();

        final clientes = state.clientes ?? [];
        final clientesPagados = state.pagados ?? [];
        final clientesNoPagados = state.noPagados ?? [];

        // Estado completamente vacío: nada pendiente, pagado ni no pagado hoy.
        if (clientes.isEmpty &&
            clientesPagados.isEmpty &&
            clientesNoPagados.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: _appBar(c),
            body: _emptyState(),
          );
        }

        return DefaultTabController(
          length: 3,
          initialIndex:
              clientes.isNotEmpty
                  ? 0
                  : clientesPagados.isNotEmpty
                  ? 1
                  : 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: _appBar(
              c,
              pendientesCount: clientes.length,
              pagadosCount: clientesPagados.length,
              noPagadosCount: clientesNoPagados.length,
            ),
            body: TabBarView(
              children: [
                _PendientesTab(
                  clientes: clientes,
                  state: state,
                  onCobrar:
                      (detalle) => _onCobrar(
                        context,
                        c,
                        detalle,
                        soloPendientes: true,
                        noPagosInfo: state.noPagosInfo,
                      ),
                ),
                _PagadosTab(clientesPagados: clientesPagados),
                _NoPagadosTab(
                  clientesNoPagados: clientesNoPagados,
                  noPagosInfo: state.noPagosInfo,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(
    CobradorRCubit c, {
    int? pendientesCount,
    int? pagadosCount,
    int? noPagadosCount,
  }) {
    final hasTabs =
        pendientesCount != null &&
        pagadosCount != null &&
        noPagadosCount != null;

    return AppBar(
      leading: IconButton(
        onPressed: () {
          c.onEventChild(CHome());
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      title: const Text(
        'Cobros',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottom:
          hasTabs
              ? TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: .65),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: 'Pendientes ($pendientesCount)'),
                  Tab(text: 'Pagados ($pagadosCount)'),
                  Tab(text: 'No pagados ($noPagadosCount)'),
                ],
              )
              : null,
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay cobros pendientes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202838),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Todos los clientes están al día.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB: PENDIENTES (resumen + cliente actual + próximos)
// ============================================================

class _PendientesTab extends StatefulWidget {
  final List<DetalleRutaEntity> clientes;
  final CobradorRState state;
  final void Function(DetalleRutaEntity detalle) onCobrar;

  const _PendientesTab({
    required this.clientes,
    required this.state,
    required this.onCobrar,
  });

  @override
  State<_PendientesTab> createState() => _PendientesTabState();
}

class _PendientesTabState extends State<_PendientesTab> {
  final _ccController = TextEditingController();
  String _filtroCc = '';

  /// Clientes que se omitieron como "cobro actual" en esta sesión (p. ej.
  /// porque su préstamo empieza hoy). No se descartan: solo pasan al final
  /// de la fila para no cobrarles todavía.
  final Set<String> _omitidos = {};

  @override
  void dispose() {
    _ccController.dispose();
    super.dispose();
  }

  /// true si alguno de los préstamos del cliente inicia hoy: el primer día
  /// no corresponde cobrarlo, así que se puede omitir en vez de cobrar.
  bool _iniciaHoy(DetalleRutaEntity detalle) {
    final hoy = DateTime.now();
    return (detalle.cliente.prestamos ?? <DatumPEntity>[]).any((p) {
      final f = p.fechaInicio;
      return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
    });
  }

  /// "Cobro actual" + "Próximos" de una ruta puntual. Con una sola ruta se
  /// usa sin encabezado (queda igual que antes, sin poder colapsarse). Con
  /// varias, cada ruta queda dentro de un desplegable (solo la primera
  /// abierta) para no tener que hacer tanto scroll, con su propio botón
  /// para crear préstamo: el cliente nuevo que se registre ahí queda con
  /// esa misma ruta.
  List<Widget> _seccionRuta({
    required DatumREntity? ruta,
    required String nombreRuta,
    required List<DetalleRutaEntity> pendientesRuta,
    required bool mostrarEncabezado,
    bool initiallyExpanded = false,
  }) {
    final cubit = context.read<CobradorRCubit>();
    final clienteActual =
        pendientesRuta.isNotEmpty ? pendientesRuta.first : null;
    final proximos = pendientesRuta.skip(1).toList();

    final cuerpo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clienteActual == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              mostrarEncabezado
                  ? 'Ya revisaste a todos los pendientes de esta ruta.'
                  : 'Ya revisaste a todos los pendientes de hoy.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          )
        else ...[
          const Text(
            'Cobro actual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202838),
            ),
          ),

          const SizedBox(height: 8),

          _ClienteActualCard(
            cliente: clienteActual,
            btnLoading: widget.state.btnLoading,
            onVerCliente: () {},
            onCobrar: () => widget.onCobrar(clienteActual),
            mostrarOmitir: _iniciaHoy(clienteActual),
            onOmitir:
                () => setState(() => _omitidos.add(clienteActual.cliente.id)),
          ),

          if (proximos.isNotEmpty) ...[
            const SizedBox(height: 24),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Próximos cobros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202838),
                    ),
                  ),
                ),
                _CountPill(
                  count: proximos.length,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...proximos.map(
              (detalle) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProximoClienteCard(
                  detalle: detalle,
                  onCobrar: () => widget.onCobrar(detalle),
                ),
              ),
            ),
          ],
        ],
      ],
    );

    if (!mostrarEncabezado) {
      return [cuerpo];
    }

    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: AppTheme.primaryColor,
            collapsedIconColor: const Color(0xFF8A93A3),
            leading: Icon(Icons.route_outlined, color: AppTheme.primaryColor),
            title: Text(
              nombreRuta,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF202838),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pendientesRuta.length} pendientes',
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),

                if (ruta != null)
                  _BotonCrearPrestamoChico(
                    onTap: () {
                      cubit.prepararNuevoPrestamo(
                        ruta: ruta,
                        clienteActual: clienteActual,
                      );
                      cubit.cedulaController.clear();
                      cubit.limpiarBusqueda();
                      cubit.onEventChild(CrearPrestamoCobradorView());
                      cubit.fechaFinal();
                    },
                  ),
              ],
            ),
            children: [cuerpo],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clientes.isEmpty) {
      return _SinPendientesState();
    }

    final rutas = widget.state.ruta ?? <DatumREntity>[];
    final rutasPorId = {for (final r in rutas) r.id: r};
    final clasificarPorRuta = rutas.length > 1;

    // Filtro por cédula: coincide si la CC contiene lo escrito.
    // Se calcula sobre la lista del estado, así un cliente que ya pagó
    // o no pagó desaparece también de los resultados de la búsqueda.
    final coinciden =
        _filtroCc.isEmpty
            ? widget.clientes
            : widget.clientes
                .where((d) => d.cliente.cedula.startsWith(_filtroCc))
                .toList();

    // Los omitidos salen de la fila normal y pasan a "En espera" (una sola
    // lista, sin importar la ruta): no se proponen como cobro actual ni
    // próximo, pero se pueden cobrar igual.
    final pendientesActivos =
        coinciden.where((d) => !_omitidos.contains(d.cliente.id)).toList();
    final enEspera =
        coinciden.where((d) => _omitidos.contains(d.cliente.id)).toList();

    // Rutas con clientes activos, en el orden de `state.ruta` (y al final
    // cualquier rutaId que no venga en esa lista, por si acaso).
    final rutaIdsConClientes =
        pendientesActivos.map((d) => d.cliente.rutaId).toSet();
    final ordenRutas = [
      for (final r in rutas)
        if (rutaIdsConClientes.contains(r.id)) r.id,
      for (final rutaId in rutaIdsConClientes)
        if (!rutasPorId.containsKey(rutaId)) rutaId,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputWidget.input(
          label: 'Buscar por CC',
          controller: _ccController,
          prefixIcon: Icons.search_rounded,
          keyboardType: TextInputType.number,
          suffixIcon: _filtroCc.isEmpty ? null : Icons.close_rounded,
          onSuffixPressed: () {
            _ccController.clear();
            setState(() => _filtroCc = '');
          },
          onChanged: (value) => setState(() => _filtroCc = value.trim()),
        ),

        const SizedBox(height: 16),

        _ResumenCard(
          totalClientes: coinciden.length,
          totalPendiente: coinciden.fold<num>(
            0,
            (sum, detalle) => sum + detalle.deudaActual,
          ),

          // Con una sola ruta, el botón vive aquí; con varias, cada sección
          // de ruta tiene el suyo (para saber a cuál corresponde el cliente).
          ruta:
              clasificarPorRuta
                  ? null
                  : rutas.isNotEmpty
                  ? rutas.first
                  : null,
          clienteActual:
              pendientesActivos.isNotEmpty ? pendientesActivos.first : null,
        ),
        const SizedBox(height: 16),
        if (pendientesActivos.isEmpty && enEspera.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Ningún cliente pendiente coincide con esa cédula.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          )
        else if (pendientesActivos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Ya revisaste a todos los pendientes de hoy. '
              'Los que dejaste en espera están abajo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          )
        else
          for (final rutaId in ordenRutas) ...[
            ..._seccionRuta(
              ruta: rutasPorId[rutaId],
              nombreRuta: rutasPorId[rutaId]?.nombre ?? 'Ruta',
              pendientesRuta:
                  pendientesActivos
                      .where((d) => d.cliente.rutaId == rutaId)
                      .toList(),
              mostrarEncabezado: clasificarPorRuta,
              // Solo la primera ruta abierta por defecto: con varias, el
              // resto queda colapsado para no obligar a tanto scroll.
              initiallyExpanded: false,
            ),
            SizedBox(height: clasificarPorRuta ? 10 : 20),
          ],

        if (enEspera.isNotEmpty) ...[
          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'En espera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
              ),
              _CountPill(count: enEspera.length, color: Colors.orange),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Su préstamo empieza hoy; puedes cobrarles igual si hace falta.',
            style: TextStyle(fontSize: 12, color: Color(0xFF929BAB)),
          ),

          const SizedBox(height: 10),

          ...enEspera.map(
            (detalle) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProximoClienteCard(
                detalle: detalle,
                onCobrar: () => widget.onCobrar(detalle),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

class _SinPendientesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.celebration_outlined,
                size: 34,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '¡Ya cobraste a todos!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202838),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Revisa la pestaña "Pagados" para ver el detalle.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESUMEN
// ============================================================

class _ResumenCard extends StatelessWidget {
  final int totalClientes;
  final num totalPendiente;

  /// Ruta a la que corresponde el botón "Crear préstamo". Null cuando el
  /// cobrador tiene varias rutas: ahí el botón vive en cada sección de ruta,
  /// para que quede claro a cuál se le está registrando el cliente nuevo.
  final DatumREntity? ruta;
  final DetalleRutaEntity? clienteActual;

  const _ResumenCard({
    required this.totalClientes,
    required this.totalPendiente,
    required this.ruta,
    required this.clienteActual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: .85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: _ResumenItem(
        icon: Icons.groups_outlined,
        label: 'Clientes por cobrar',
        value: '$totalClientes',
        ruta: ruta,
        clienteActual: clienteActual,
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final DatumREntity? ruta;
  final DetalleRutaEntity? clienteActual;

  const _ResumenItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.ruta,
    required this.clienteActual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: .85)),
        ),
        if (ruta != null) ...[
          SizedBox(height: 10),
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<CobradorRCubit>().prepararNuevoPrestamo(
                    ruta: ruta!,
                    clienteActual: clienteActual,
                  );
                  context.read<CobradorRCubit>().onEventChild(
                    CrearPrestamoCobradorView(),
                  );
                  context.read<CobradorRCubit>().fechaFinal();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_card_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Crear préstamo',
                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Botón chico de "Crear préstamo" para el encabezado de una sección de
/// ruta (cuando el cobrador tiene más de una).
class _BotonCrearPrestamoChico extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonCrearPrestamoChico({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_card_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Text(
                'Crear préstamo',
                style: TextStyle(
                  color: AppTheme.primaryColor,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  final Color color;

  const _CountPill({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================
// CLIENTE ACTUAL
// ============================================================

class _ClienteActualCard extends StatelessWidget {
  final DetalleRutaEntity cliente;
  final bool btnLoading;
  final VoidCallback onVerCliente;
  final VoidCallback onCobrar;

  /// true si el préstamo del cliente inicia hoy: aún no toca cobrarle, así
  /// que se ofrece "Omitir" en vez de forzar el cobro.
  final bool mostrarOmitir;
  final VoidCallback? onOmitir;

  const _ClienteActualCard({
    required this.cliente,
    required this.btnLoading,
    required this.onVerCliente,
    required this.onCobrar,
    this.mostrarOmitir = false,
    this.onOmitir,
  });

  @override
  Widget build(BuildContext context) {
    final data = cliente.cliente;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: .15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 34,
              color: Color(0xFF4164E8),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '${data.nombres} ${data.apellidos}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202838),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'CC: ${data.cedula}',
            style: const TextStyle(color: Color(0xFF929BAB)),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  'Deuda pendiente',
                  style: TextStyle(color: Color(0xFF929BAB)),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$ ${cliente.deudaActual}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF202838),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (mostrarOmitir) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF5C26B)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFB7791F),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Su préstamo empieza hoy: todavía no toca cobrarle.',
                      style: TextStyle(color: Color(0xFF8A5A0B), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            children: [
              if (mostrarOmitir) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOmitir,
                    icon: const Icon(Icons.skip_next_rounded, size: 18),
                    label: const Text('Omitir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF687386),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: .25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: BtnWidget.btn(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: onCobrar,
                  loading: btnLoading,
                  icon: Icons.payments_outlined,
                  text: 'Cobrar',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ============================================================
// PRÓXIMO CLIENTE (ahora con botón directo de cobro rápido)
// ============================================================

class _ProximoClienteCard extends StatelessWidget {
  final dynamic detalle;
  final VoidCallback onCobrar;

  const _ProximoClienteCard({required this.detalle, required this.onCobrar});

  @override
  Widget build(BuildContext context) {
    final cliente = detalle.cliente;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF929BAB),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cliente.nombres} ${cliente.apellidos}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'CC: ${cliente.cedula}',
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),
                Text(
                  'Deuda: \$ ${detalle.deudaActual}',
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onCobrar,
            icon: const Icon(Icons.payments_outlined),
            color: AppTheme.primaryColor,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: .08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            tooltip: 'Cobrar',
          ),
        ],
      ),
    );
  }
}

Widget _itemPrestamo(
  BuildContext context,
  String clienteNombre,
  DatumPEntity prestamo, {
  bool showNoPago = true,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap:
        prestamo.yaPago!
            ? null
            : () {
              Navigator.pop(context);

              showCobroBottomSheet(
                context,
                showNPago: showNoPago,
                clienteNombre: clienteNombre,
                cuota: prestamo.valorCuota,
                deudaActual: prestamo.deudaActual,
                onConfirmar: (String value) async {
                  context.read<CobradorRCubit>().pagar(
                    prestamoId: prestamo.id,
                    valorPago: int.parse(value),
                  );
                },
                onNoPago: (data) {
                  context.read<CobradorRCubit>().noPago(
                    prestamoId: prestamo.id,
                    motivo: data.motivo,
                    observacion: data.observacion,
                    fechaPromesa: data.fechaPromesa,
                  );
                },
                onReembolso: () => mostrarDialogoReembolso(
                  context,
                  prestamo: prestamo,
                  onConfirmar: (prestamoId, dto) => context
                      .read<CobradorRCubit>()
                      .reembolso(prestamoId: prestamoId, dto: dto),
                ),
              );
            },
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF4164E8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Préstamo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cuota: \$${prestamo.valorCuota}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF929BAB),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Deuda',
                style: TextStyle(fontSize: 10, color: Color(0xFF929BAB)),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${prestamo.deudaActual}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202838),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Visibility(
            visible: !prestamo.yaPago!,
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8A93A3),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// TAB: PAGADOS
// ============================================================

class _PagadosTab extends StatefulWidget {
  final List<DetalleRutaEntity> clientesPagados;

  const _PagadosTab({required this.clientesPagados});

  @override
  State<_PagadosTab> createState() => _PagadosTabState();
}

class _PagadosTabState extends State<_PagadosTab> {
  final _ccController = TextEditingController();
  String _filtroCc = '';

  @override
  void dispose() {
    _ccController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesPagados = widget.clientesPagados;

    if (clientesPagados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 34,
                  color: Color(0xFF929BAB),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aún no hay pagos registrados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Los clientes que pagues aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
              ),
            ],
          ),
        ),
      );
    }

    // Filtro por cédula: coincide si la CC contiene lo escrito
    final filtrados =
        _filtroCc.isEmpty
            ? clientesPagados
            : clientesPagados
                .where((d) => d.cliente.cedula.contains(_filtroCc))
                .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputWidget.input(
          label: 'Buscar por CC',
          controller: _ccController,
          prefixIcon: Icons.search_rounded,
          keyboardType: TextInputType.number,
          suffixIcon: _filtroCc.isEmpty ? null : Icons.close_rounded,
          onSuffixPressed: () {
            _ccController.clear();
            setState(() => _filtroCc = '');
          },
          onChanged: (value) => setState(() => _filtroCc = value.trim()),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Clientes que ya pagaron',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
            ),
            _CountPill(count: filtrados.length, color: Colors.green),
          ],
        ),
        const SizedBox(height: 10),
        if (filtrados.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Ningún cliente pagado coincide con esa cédula.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
          ),
        ...filtrados.map(
          (detalle) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ClientePagadoCard(detalle: detalle),
          ),
        ),
      ],
    );
  }
}

class _ClientePagadoCard extends StatelessWidget {
  final DetalleRutaEntity detalle;

  const _ClientePagadoCard({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final cliente = detalle;
    final pagos = [
      for (final prestamo in detalle.cliente.prestamos ?? <DatumPEntity>[])
        ...prestamo.pagos,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.green.withValues(alpha: .10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cliente.cliente.nombres} ${cliente.cliente.apellidos}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202838),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC: ${cliente.cliente.cedula}',
                      style: const TextStyle(color: Color(0xFF929BAB)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pagado',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (pagos.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            ...pagos.map((pago) => _PagoRow(pago: pago)),
          ],
          Center(
            child: TextButton(
              onPressed: () {
                _onCobrar(
                  context,
                  context.read<CobradorRCubit>(),
                  cliente,
                  showNoPago: false,
                );
              },
              child: Text("Volver a cobrar"),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un pago del cliente, con la opción de revertirlo si es de hoy
class _PagoRow extends StatefulWidget {
  final PagoEntity pago;

  const _PagoRow({required this.pago});

  @override
  State<_PagoRow> createState() => _PagoRowState();
}

class _PagoRowState extends State<_PagoRow> {
  bool get _reversado => widget.pago.estado == 'REVERSADO';

  @override
  Widget build(BuildContext context) {
    final pago = widget.pago;
    final color = _reversado ? const Color(0xFFE05252) : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _reversado ? Icons.undo_rounded : Icons.check_circle_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                if (pago.fechaPago != null)
                  DateUtil.formatLectura(pago.fechaPago!),
                if (_reversado) 'Reversado',
              ].join(' · '),
              style: const TextStyle(color: Color(0xFF929BAB)),
            ),
          ),
          Text(
            '\$${pago.valor}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _reversado ? color : const Color(0xFF202838),
              decoration: _reversado ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB: NO PAGADOS
// ============================================================

class _NoPagadosTab extends StatelessWidget {
  final List<DetalleRutaEntity> clientesNoPagados;
  final Map<String, NoPagoRutaEntity> noPagosInfo;

  const _NoPagadosTab({
    required this.clientesNoPagados,
    required this.noPagosInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (clientesNoPagados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.money_off_rounded,
                  size: 34,
                  color: Color(0xFF929BAB),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Sin no pagos registrados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Los clientes que marques como "No pagó" aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Clientes que no pagaron',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
            ),
            _CountPill(
              count: clientesNoPagados.length,
              color: Colors.redAccent,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...clientesNoPagados.map((detalle) {
          // El no pago del primer préstamo del cliente que lo tenga registrado
          final info =
              (detalle.cliente.prestamos ?? [])
                  .map((p) => noPagosInfo[p.id])
                  .whereType<NoPagoRutaEntity>()
                  .firstOrNull;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ClienteNoPagoCard(detalle: detalle, info: info),
          );
        }),
      ],
    );
  }
}

class _ClienteNoPagoCard extends StatelessWidget {
  final DetalleRutaEntity detalle;
  final NoPagoRutaEntity? info;

  const _ClienteNoPagoCard({required this.detalle, required this.info});

  @override
  Widget build(BuildContext context) {
    final cliente = detalle.cliente;
    final detalleTexto = <String>[
      if (info != null && info!.fechaPromesa != null)
        'Promete pagar: ${DateUtil.formatLectura(info!.fechaPromesa!)}',
      if (info != null && info!.observacion.isNotEmpty) info!.observacion,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.redAccent.withValues(alpha: .15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cliente.nombres} ${cliente.apellidos}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202838),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC: ${cliente.cedula}\nDeuda:\$ ${detalle.deudaActual}',
                      style: const TextStyle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (detalleTexto.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                detalleTexto.join(' · '),
                style: const TextStyle(fontSize: 12, color: Color(0xFF687386)),
              ),
            ),
          ],
          SizedBox(height: 10),
          Text(
            info == null ? 'No pagó' : MotivoNoPago.labelDe(info!.motivo),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
          Divider(),
          Center(
            child: TextButton(
              onPressed: () {
                _onCobrar(
                  context,
                  context.read<CobradorRCubit>(),
                  detalle,
                  showNoPago: false,
                );
              },
              child: const Text('Volver a cobrar'),
            ),
          ),
        ],
      ),
    );
  }
}

void _onCobrar(
  BuildContext context,
  CobradorRCubit c,
  DetalleRutaEntity cliente, {
  bool showNoPago = true,
  bool soloPendientes = false,
  Map<String, NoPagoRutaEntity> noPagosInfo = const {},
}) {
  final todos = cliente.cliente.prestamos ?? <DatumPEntity>[];

  // Desde "Pendientes" no se ofrecen los préstamos que ya tienen pago o no pago hoy
  final prestamos =
      soloPendientes
          ? todos
              .where((p) => p.yaPago != true && !noPagosInfo.containsKey(p.id))
              .toList()
          : todos;

  if (prestamos.length == 1) {
    final prestamo = prestamos.first;
    showCobroBottomSheet(
      context,
      showNPago: showNoPago,
      clienteNombre: cliente.cliente.nombres,
      cuota: prestamo.valorCuota,
      deudaActual: prestamo.deudaActual,
      onConfirmar: (String value) async {
        c.pagar(prestamoId: prestamo.id, valorPago: int.parse(value));
      },
      onNoPago: (data) {
        c.noPago(
          prestamoId: prestamo.id,
          motivo: data.motivo,
          observacion: data.observacion,
          fechaPromesa: data.fechaPromesa,
        );
      },
      onReembolso: () => mostrarDialogoReembolso(
        context,
        prestamo: prestamo,
        onConfirmar: (prestamoId, dto) =>
            c.reembolso(prestamoId: prestamoId, dto: dto),
      ),
    );
    return;
  }
  _showSeleccionPrestamo(
    context,
    cliente.cliente.nombres,
    prestamos,
    showNoPago: showNoPago,
  );
}

void _showSeleccionPrestamo(
  BuildContext context,
  String clienteNombre,
  List<DatumPEntity> prestamos, {
  bool showNoPago = true,
}) {
  showModalBottomSheet(
    context: context,

    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
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
              'Selecciona el préstamo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202838),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              clienteNombre,
              style: const TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
            ),
            const SizedBox(height: 18),
            ...prestamos.map(
              (prestamo) => _itemPrestamo(
                context,
                clienteNombre,
                prestamo,
                showNoPago: showNoPago,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      );
    },
  );
}
