import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/detalle_ruta_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/cobrar.dart';
import 'package:personal/src/ui/cobrador/c_home.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';

class Clientes extends StatelessWidget {
  const Clientes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();

        final clientes = state.clientes ?? [];
        final clientesPagados = state.pagados ?? [];

        // Estado completamente vacío: nada pendiente y nada pagado hoy.
        if (clientes.isEmpty && clientesPagados.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: _appBar(c),
            body: _emptyState(),
          );
        }

        final clienteActual = clientes.isNotEmpty ? clientes.first : null;
        final proximos = clientes.isNotEmpty
            ? clientes.skip(1).toList()
            : <dynamic>[];

        final totalPendiente = clientes.fold<num>(
          0,
          (sum, detalle) => sum + (detalle.deudaActual as num),
        );

        return DefaultTabController(
          length: 2,
          initialIndex: clientes.isEmpty ? 1 : 0,
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: _appBar(
              c,
              pendientesCount: clientes.length,
              pagadosCount: clientesPagados.length,
            ),
            body: TabBarView(
              children: [
                _PendientesTab(
                  clienteActual: clienteActual,
                  proximos: proximos,
                  totalPendiente: totalPendiente,
                  state: state,
                  onCobrar: (detalle) => _onCobrar(context, c, detalle),
                ),
                _PagadosTab(clientesPagados: clientesPagados),
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
  }) {
    final hasTabs = pendientesCount != null && pagadosCount != null;

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
      bottom: hasTabs
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

class _PendientesTab extends StatelessWidget {
  final DetalleRutaEntity? clienteActual;
  final List<dynamic> proximos;
  final num totalPendiente;
  final CobradorRState state;
  final void Function(dynamic detalle) onCobrar;

  const _PendientesTab({
    required this.clienteActual,
    required this.proximos,
    required this.totalPendiente,
    required this.state,
    required this.onCobrar,
  });

  @override
  Widget build(BuildContext context) {
    if (clienteActual == null) {
      return _SinPendientesState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ResumenCard(
          totalClientes: proximos.length + 1,
          totalPendiente: totalPendiente,
        ),

        const SizedBox(height: 20),

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
          cliente: clienteActual!,
          btnLoading: state.btnLoading,
          onVerCliente: () {},
          onCobrar: () => onCobrar(clienteActual),
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
              _CountPill(count: proximos.length, color: AppTheme.primaryColor),
            ],
          ),

          const SizedBox(height: 10),

          ...proximos.map(
            (detalle) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProximoClienteCard(
                detalle: detalle,
                onCobrar: () => onCobrar(detalle),
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

  const _ResumenCard({
    required this.totalClientes,
    required this.totalPendiente,
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
      child: Row(
        children: [
          Expanded(
            child: _ResumenItem(
              icon: Icons.groups_outlined,
              label: 'Clientes por cobrar',
              value: '$totalClientes',
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: .25),
          ),
          Expanded(
            child: _ResumenItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Total pendiente',
              value: '\$ $totalPendiente',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResumenItem({
    required this.icon,
    required this.label,
    required this.value,
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: .85),
          ),
        ),
      ],
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

  const _ClienteActualCard({
    required this.cliente,
    required this.btnLoading,
    required this.onVerCliente,
    required this.onCobrar,
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
            style: const TextStyle(fontSize: 13, color: Color(0xFF929BAB)),
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
                  style: TextStyle(fontSize: 12, color: Color(0xFF929BAB)),
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

          BtnWidget.btn(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            onPressed: onCobrar,
            loading: btnLoading,
            icon: Icons.payments_outlined,
            text: 'Cobrar',
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: onVerCliente,
            icon: const Icon(Icons.person_outline_rounded, size: 18),
            label: const Text('Ver información del cliente'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'CC: ${cliente.cedula} · \$ ${detalle.deudaActual}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF929BAB),
                  ),
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
  DatumPEntity prestamo,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: prestamo.yaPago!
        ? null
        : () {
            Navigator.pop(context);

            showCobroBottomSheet(
              context,
              clienteNombre: clienteNombre,
              cuota: prestamo.valorCuota,
              deudaActual: prestamo.deudaActual,
              onConfirmar: (String value) async {
                context.read<CobradorRCubit>().pagar(
                  prestamoId: prestamo.id,
                  valorPago: int.parse(value),
                );
              },
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

class _PagadosTab extends StatelessWidget {
  final List<DetalleRutaEntity> clientesPagados;

  const _PagadosTab({required this.clientesPagados});

  @override
  Widget build(BuildContext context) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
            _CountPill(count: clientesPagados.length, color: Colors.green),
          ],
        ),
        const SizedBox(height: 10),
        ...clientesPagados.map(
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202838),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC: ${cliente.cliente.cedula}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF929BAB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pagado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Center(
            child: TextButton(
              onPressed: () {
                _onCobrar(context, context.read<CobradorRCubit>(), cliente);
              },
              child: Text("Volver a cobrar"),
            ),
          ),
        ],
      ),
    );
  }
}

void _onCobrar(BuildContext context, CobradorRCubit c, DetalleRutaEntity   cliente) {
  if (cliente.cliente.prestamos!.length == 1) {
    showCobroBottomSheet(
      context,
      clienteNombre: cliente.cliente.nombres,
      cuota: cliente.cliente.prestamos!.first.valorCuota,
      deudaActual: cliente.cliente.prestamos!.first.deudaActual,
      onConfirmar: (String value) async {
        c.pagar(
          prestamoId: cliente.cliente.prestamos!.first.id,
          valorPago: int.parse(value),
        );
      },
    );
    return;
  }
  _showSeleccionPrestamo(
    context,
    cliente.cliente.nombres,
    cliente.cliente.prestamos ?? [],
  );
}

void _showSeleccionPrestamo(
  BuildContext context,
  String clienteNombre,
  List<DatumPEntity> prestamos,
) {
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
              (prestamo) => _itemPrestamo(context, clienteNombre, prestamo),
            ),
            const SizedBox(height: 48),
          ],
        ),
      );
    },
  );
}
