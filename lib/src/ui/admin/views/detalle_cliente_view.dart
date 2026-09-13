import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/contact_util.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';

class DetalleClienteView extends StatelessWidget {
  const DetalleClienteView({
    super.key,
    required this.cliente,
    required this.onBack,
    required this.onEdit,
    this.showEdit = false,
  });
  final DatumClEntity cliente;
  final Function() onBack;
  final Function() onEdit;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            log(".a.a.a.a");
            onBack();
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: const Text(
          'Detalle del cliente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _clienteHeader(),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                _sectionTitle(
                  icon: Icons.person_outline_rounded,
                  title: 'Información personal',
                ),
                Visibility(
                  visible: showEdit,
                  child: IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _infoCard(),

            const SizedBox(height: 22),

            _sectionTitle(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Información financiera',
            ),

            const SizedBox(height: 12),

            _deudaCard(),

            const SizedBox(height: 22),

            _sectionTitle(
              icon: Icons.receipt_long_outlined,
              title: 'Préstamos activos',
            ),

            const SizedBox(height: 12),

            _prestamos(),
          ],
        ),
      ),
    );
  }

  Widget _clienteHeader() {
    final nombre = '${cliente.nombres} ${cliente.apellidos}'.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .25)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'CC ${cliente.cedula}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: .center,
            children: [
              IconButton(
                icon: Icon(Icons.call, color: Colors.white),
                onPressed: () {
                  ContactUtil.open(
                    telefono: cliente.telefono,
                    action: ContactAction.call,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.call, color: Colors.white),
                onPressed: () {
                  ContactUtil.open(
                    telefono: cliente.whatsapp,
                    action: ContactAction.whatsapp,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.badge_outlined,
            title: 'Cédula',
            value: cliente.cedula,
          ),

          _divider(),

          _detailRow(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            value: cliente.telefono,
          ),

          _divider(),
          _detailRow(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            value: cliente.whatsapp,
          ),

          _divider(),
          _detailRow(
            icon: Icons.location_on_outlined,
            title: 'Dirección',
            value: cliente.direccion,
          ),
        ],
      ),
    );
  }

  Widget _deudaCard() {
    final deuda =
        cliente.prestamos
            ?.where((prestamo) => prestamo.estado == 'ACTIVO')
            .fold<num>(0, (total, prestamo) => total + prestamo.deudaActual) ??
        0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deuda actual',
                  style: TextStyle(color: Color(0xFF929BAB), fontSize: 11),
                ),

                const SizedBox(height: 3),

                Text(
                  '\$${deuda.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prestamos() {
    final prestamos = cliente.prestamos ?? [];

    if (prestamos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 38,
              color: AppTheme.primaryColor.withValues(alpha: .6),
            ),
            const SizedBox(height: 10),
            const Text(
              'No tiene préstamos activos',
              style: TextStyle(
                color: Color(0xFF202838),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: prestamos.map((prestamo) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Préstamo ${prestamo.estado.toLowerCase()}',
                      style: TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Deuda: \$${prestamo.deudaActual}',
                      style: const TextStyle(
                        color: Color(0xFF929BAB),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202838),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 19),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF929BAB), ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
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
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.black.withValues(alpha: .06)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}
