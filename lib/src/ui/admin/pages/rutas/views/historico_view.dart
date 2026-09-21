import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/domain/entities/gasto_entity.dart';
import 'package:personal/src/ui/admin/pages/caja/views/movimientos_caja_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_home.dart';

class HistoricoView extends StatelessWidget {
  const HistoricoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        final cajas = state.historico ?? [];
        cajas.sort((a, b) => b.fechaOperacion.compareTo(a.fechaOperacion));
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            title: const Text(
              'Histórico',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                context.read<RutaCubit>().onEventChild(RutaHome());
              },

              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          body: cajas.isEmpty
              ? _buildVacio()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cajas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    return _buildCaja(context, cajas[index]);
                  },
                ),
        );
      },
    );
  }

  Widget _buildCaja(BuildContext context, DatumCajaEntity caja) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Color(0xFF4164E8),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  DateUtil.formatLectura(caja.fechaOperacion),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
              ),
              _estado(caja.estado),
            ],
          ),
          subtitle: Text(
            'Saldo inicial ${_moneda(caja.montoInicial)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF929BAB)),
          ),
          children: [
            _buildResumen(caja),

            if (caja.gastosCaja != null && caja.gastosCaja!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildGastos(caja),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () => abrirMovimientosCajaHistorica(context, caja.id),
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: const Text('Ver movimientos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(DatumCajaEntity caja) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202838),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_rounded,
                size: 20,
                color: Color(0xFF4164E8),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Monto inicial',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF394354),
                  ),
                ),
              ),
              Text(
                _moneda(caja.montoInicial),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202838),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _dato('Cobrado', caja.cobrado, Icons.payments_outlined),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dato(
                'Prestado',
                caja.montoPrestado,
                Icons.monetization_on_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _dato('Gastos', caja.gastos, Icons.receipt_long_outlined),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dato(
                'Intereses',
                caja.interesGenerado,
                Icons.trending_up_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _dato('Seguros', caja.saldoSeguros, Icons.shield_outlined),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dato(
                'Esperado',
                caja.montoEsperado,
                Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Visibility(
          visible: caja.estado == "CERRADA",
          child: Row(
            children: [
              Expanded(
                child: _dato(
                  'Monto real',
                  caja.montoReal,
                  Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  'Recibido',
                  caja.diferencia,
                  Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
        ),
        Text("${caja.observacion}"),
      ],
    );
  }

  Widget _buildGastos(DatumCajaEntity caja) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Gastos registrados',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
            ),
            Text(
              _moneda(caja.gastos),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202838),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ...caja.gastosCaja!.map((gasto) => _buildGasto(gasto)),
      ],
    );
  }

  Widget _buildGasto(GastoElementEntity gasto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 19,
              color: Color(0xFF929BAB),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto.concepto,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF394354),
                  ),
                ),

                if (gasto.observacion.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    gasto.observacion,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF929BAB),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Text(
            _moneda(gasto.valor),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202838),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, num? valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF929BAB)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Color(0xFF929BAB))),
                const SizedBox(height: 2),
                Text(
                  _moneda(valor),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF394354),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estado(String estado) {
    final abierta = estado == 'ABIERTA';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: abierta ? const Color(0xFFEAF8F0) : const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: abierta ? const Color(0xFF238B57) : const Color(0xFF737B8A),
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No hay registros históricos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF394354),
            ),
          ),
        ],
      ),
    );
  }

  String _moneda(num? valor) {
    return "\$ $valor";
  }
}
