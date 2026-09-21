import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/pagos.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/prestamos_home.dart';

class PrestamoDetalleView extends StatelessWidget {
  PrestamoDetalleView({super.key});
  late DatumPEntity pEntity;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrestamoCubit, PrestamoState>(
      builder: (context, state) {
        pEntity = state.prestamo!;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                context.read<PrestamoCubit>().onGetChild(PrestamosHome());
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Detalle del préstamo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 25),
            child: Column(
              children: [
                _loanHeader(),

                const SizedBox(height: 12),

                _summaryCard(),

                const SizedBox(height: 12),

                _loanInfoCard(),

                const SizedBox(height: 12),

                _datesCard(),

                const SizedBox(height: 12),

                _clientCard(),

                const SizedBox(height: 20),

                _paymentsButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _loanHeader() {
    return Container(
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
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF4164E8),
              size: 27,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '\$ ${pEntity.deudaActual}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESUMEN
  // ---------------------------------------------------------------------------

  Widget _summaryCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              color: Color(0xFF202838),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          _moneyRow(label: 'Monto prestado ', value: '\$ ${pEntity.monto}'),
          const SizedBox(height: 15),

          _moneyRow(label: 'Total a pagar', value: '\$ ${pEntity.totalPagar}'),

          const SizedBox(height: 12),

          _moneyRow(
            label: 'Ganancia esperada',
            value: '\$ ${pEntity.montoInteres}',
          ),
          Divider(),

          const SizedBox(height: 12),
          _moneyRow(
            label: 'Total pagado',
            value: '\$ ${pEntity.totalPagar - pEntity.deudaActual}',
          ),

          const SizedBox(height: 12),

          _moneyRow(
            label: 'Saldo pendiente',
            value: '\$ ${pEntity.deudaActual}',
            highlight: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFORMACIÓN
  // ---------------------------------------------------------------------------

  Widget _loanInfoCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del préstamo',
            style: TextStyle(
              color: Color(0xFF202838),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: _infoItem('Interés', '${pEntity.interes}%')),
              Expanded(child: _infoItem('Cuota', '\$ ${pEntity.valorCuota}')),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _infoItem('Número de cuotas', '${pEntity.numeroCuotas}'),
              ),
              Expanded(child: _infoItem('Frecuencia', pEntity.frecuencia)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FECHAS
  // ---------------------------------------------------------------------------

  Widget _datesCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fechas',
            style: TextStyle(
              color: Color(0xFF202838),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  'Fecha de inicio',
                  DateUtil.formatLectura(pEntity.fechaInicio),
                ),
              ),
              Expanded(
                child: _infoItem(
                  'Fecha final',
                  DateUtil.formatLectura(pEntity.fechaFin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENTE
  // ---------------------------------------------------------------------------

  Widget _clientCard() {
    return _sectionCard(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF4164E8),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente', style: TextStyle(color: Color(0xFF929BAB))),

                  SizedBox(height: 3),

                  Text(
                    pEntity.cliente.nombres,
                    style: TextStyle(
                      color: Color(0xFF202838),
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'CC ${pEntity.cliente.cedula}',
                    style: TextStyle(color: Color(0xFF929BAB)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTÓN
  // ---------------------------------------------------------------------------

  Widget _paymentsButton() {
    return BlocBuilder<PrestamoCubit, PrestamoState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final cubit = context.read<PrestamoCubit>();
              showPagosDialog(
                context: context,
                pagos: pEntity.pagos,
                onRevertir: (pagoId,) => cubit.revertirPago(
                  pagoId: pagoId,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Ver pagos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES
  // ---------------------------------------------------------------------------

  Widget _moneyRow({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF929BAB))),
        ),

        Text(
          value,
          style: TextStyle(
            color: highlight ? AppTheme.primaryColor : const Color(0xFF394354),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF929BAB))),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF394354),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withValues(alpha: .05)),
    );
  }
}
