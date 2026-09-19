// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/caja_entity.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';
import 'package:personal/src/ui/admin/pages/caja/views/dialogo_arqueo.dart';
import 'package:personal/src/ui/admin/pages/caja/views/dialogo_cerrar_caja.dart';
import 'package:personal/src/ui/admin/pages/caja/views/gestion_cobros.dart';

class DetalleCaja extends StatelessWidget {
  DetalleCaja({super.key});
  late DatumCajaEntity caja;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        caja = state.cajas!;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FC),
          appBar: AppBar(
            title: const Text(
              'Caja del día',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCaja(),

                const SizedBox(height: 12),

                _buildResumen(),

                const SizedBox(height: 18),

                const GestionCobros(),

                const SizedBox(height: 18),

                _buildPrestamos(),

                const SizedBox(height: 18),

                _buildGastos(),

                const SizedBox(height: 18),

                Visibility(
                  visible: caja.estado == "ABIERTA",
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        mostrarModalArqueo(
                          context,
                          context.read<CajaCubit>(),
                          caja.montoEsperado,
                        );
                      },
                      icon: const Icon(Icons.calculate_outlined, size: 18),
                      label: const Text('Realizar arqueo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: TextButton(onPressed: () {}, child: Text("Ver movimientos"))),
                const SizedBox(height: 18),

                Visibility(visible: state.showArqueo, child: _buildArqueo()),

                const SizedBox(height: 18),

                Visibility(
                  visible: state.showArqueo,
                  child: _buildCerrarCaja(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCaja() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Color(0xFF4164E8),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caja ${caja.estado.toLowerCase()}',
                  style: TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateUtil.formatDate(caja.fechaApertura),
                  style: TextStyle(color: Color(0xFF929BAB), fontSize: 12),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: caja.estado == "ABIERTA"
                  ? Colors.green.withValues(alpha: .10)
                  : Colors.grey.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              caja.estado,
              style: TextStyle(
                color: caja.estado == "ABIERTA" ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _buildResumen() {
    return _section(
      title: 'Resumen de caja',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _datoCaja('Saldo inicial', '\$ ${caja.montoInicial}'),
              ),
              Expanded(
                child: _datoCaja(
                  'Cobrado',
                  '\$ ${caja.cobrado}',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _datoCaja(
                  'Préstamos',
                  '\$ - ${caja.montoPrestado}',
                  color: Colors.redAccent,
                ),
              ),
              Expanded(
                child: _datoCaja(
                  'Gastos',
                  '\$ - ${caja.gastos}',
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _datoCaja(
                  'Cobro esperado',
                  '\$ ${caja.cobroEsperado}',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _datoCaja(
                  'Nivel de eficacia',
                 caja.cobroEsperado==0?'-' :'\$ ${((caja.cobrado / caja.cobroEsperado) * 100).toInt()} %',
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saldo esperado',
                  style: TextStyle(
                    color: Color(0xFF394354),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$ ${caja.montoEsperado} ',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRESTAMOS
  // ============================================================

  Widget _buildPrestamos() {
    return _section(
      title: 'Préstamos nuevos',
      icon: Icons.request_quote_outlined,
      child: Column(
        children: [
          _detalleMovimiento(
            titulo: 'Capital prestado',
            valor: '\$ ${caja.montoPrestado}',
            icon: Icons.payments_outlined,
          ),

          const SizedBox(height: 12),

          _detalleMovimiento(
            titulo: 'Intereses generados',
            valor: '\$ ${caja.interesGenerado}',
            icon: Icons.percent_rounded,
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          _detalleMovimiento(
            titulo: 'Seguros',
            valor: '\$ ${caja.saldoSeguros}',
            icon: Icons.shield_outlined,
            color: Colors.orange,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total préstamos',
                  style: TextStyle(
                    color: Color(0xFF202838),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$ ${caja.montoPrestado}',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ============================================================
  // GASTOS
  // ============================================================

  Widget _buildGastos() {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        final gastos = state.gastos ?? [];
        return _section(
          title: 'Gastos',
          icon: Icons.receipt_long_outlined,
          child: Column(
            children: [
              ...gastos.map((e) => _gastoItem(e.concepto, e.valor.toString())),
              Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total gastos',
                      style: TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '\$ ${caja.gastos}',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ARQUEO
  // ============================================================

  Widget _buildArqueo() {
    // Ejemplo:
    // esperado = 300.000
    // contado = 300.000
    // diferencia = 0

    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        int saldoEsperado = caja.montoEsperado;
        int dineroContado = int.parse(
          context.read<CajaCubit>().dineroRecibido.text,
        );
        int diferencia = dineroContado - saldoEsperado;

        final equilibrada = diferencia == 0;
        final falta = diferencia < 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: equilibrada
                ? Colors.green.withValues(alpha: .06)
                : falta
                ? Colors.red.withValues(alpha: .06)
                : Colors.blue.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: equilibrada
                  ? Colors.green.withValues(alpha: .15)
                  : falta
                  ? Colors.red.withValues(alpha: .15)
                  : Colors.blue.withValues(alpha: .15),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: equilibrada
                          ? Colors.green.withValues(alpha: .10)
                          : falta
                          ? Colors.redAccent.withValues(alpha: .10)
                          : Colors.blueAccent.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      equilibrada
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      color: equilibrada
                          ? Colors.green
                          : falta
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equilibrada
                              ? 'Caja equilibrada'
                              : falta
                              ? 'Falta dinero'
                              : 'Sobra dinero',
                          style: TextStyle(
                            color: equilibrada
                                ? Colors.green
                                : falta
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          equilibrada
                              ? 'El dinero recibido coincide con el saldo esperado.'
                              : falta
                              ? 'El dinero recibido es inferior al esperado.'
                              : 'El dinero recibido es superior al esperado.',
                          style: const TextStyle(color: Color(0xFF929BAB)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _datoCaja(
                      'Saldo esperado',
                      '\$ ${caja.montoEsperado + caja.cobrado}',
                    ),
                  ),
                  Expanded(
                    child: _datoCaja(
                      'Dinero recibido',
                      '\$ ${context.read<CajaCubit>().dineroRecibido.text}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Diferencia',
                        style: TextStyle(
                          color: Color(0xFF394354),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      diferencia == 0
                          ? '\$0'
                          : '${falta ? '-' : '+'}\$${diferencia.abs()}',
                      style: TextStyle(
                        color: equilibrada
                            ? Colors.green
                            : falta
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CERRAR CAJA
  // ============================================================

  Widget _buildCerrarCaja() {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () =>
                mostrarDialogoCerrarCaja(context, context.read<CajaCubit>()),
            icon: const Icon(Icons.lock_outline_rounded, size: 19),
            label: const Text(
              'Cerrar caja',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF202838),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // COMPONENTES
  // ============================================================

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF202838),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  Widget _datoCaja(String titulo, String valor, {Color? color}) {
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

  Widget _detalleMovimiento({
    required String titulo,
    required String valor,
    required IconData icon,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color ?? AppTheme.primaryColor),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(titulo, style: const TextStyle(color: Color(0xFF394354))),
        ),

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

  Widget _gastoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.remove_circle_outline_rounded,
            size: 18,
            color: Colors.redAccent,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(color: Color(0xFF394354), fontSize: 12),
            ),
          ),

          Text(
            '-$valor',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF929BAB)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF929BAB))),
        ),
      ],
    );
  }
}
