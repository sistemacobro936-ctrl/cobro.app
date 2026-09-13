import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';
import 'package:personal/src/ui/widgets/input_widget.dart';

class AbrirCajaView extends StatelessWidget {
  final String rutaId;
  const AbrirCajaView({super.key, required this.rutaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        final c = context.read<CajaCubit>();
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F8),
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor,
            title: const Text(
              'Gestión Caja',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inicia tu caja',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Registra el dinero disponible al comenzar tu jornada.',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Monto inicial',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Ingresa el dinero en efectivo con el que inicias la caja.',
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 14),

                  InputWidget.input(
                    controller: c.montoInicial,
                    keyboardType: TextInputType.number,
                    onChanged: (e) {
                      c.formValid();
                    },
                    prefixIcon: Icons.attach_money,
                    hintText: "100",
                    label: "",
                  ),

                  const SizedBox(height: 24),

                  // Información
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 21,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Este monto será tomado como saldo inicial. '
                            'Los préstamos, pagos y gastos registrados '
                            'durante la jornada afectarán el saldo esperado.',
                            style: TextStyle(
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resumen
                  const SizedBox(height: 30),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: BtnWidget.btn(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      enabled: state.btnEnabled,
                      onPressed: () {
                        c.crearCaja(rutaId: rutaId);
                      },
                      loading: false,
                      icon: Icons.lock_open_rounded,
                      text: state.btnLoading
                          ? 'Abriendo caja...'
                          : 'Abrir caja',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
