// ui/pages/prestamos/views/cuotas_esperadas_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/dto/cuota_esperada_dto.dart';
import 'package:personal/src/ui/admin/pages/prestamos/create_p_view.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class ResumenPrevio extends StatefulWidget {
  const ResumenPrevio({super.key, required this.cuotas});

  final List<CuotaEsperada> cuotas;

  @override
  State<ResumenPrevio> createState() => _ResumenPrevioState();
}

class _ResumenPrevioState extends State<ResumenPrevio> {
  late final List<CuotaEsperada> _cuotas;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _cuotas = List.from(widget.cuotas);
    _controllers = _cuotas
        .map((c) => TextEditingController(text: c.monto.toInt().toString()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  int get _cuotasPasadas => _cuotas.where((c) => c.esPasada).length;
  double get _totalPasado =>
      _cuotas.where((c) => c.esPasada).fold(0, (sum, c) => sum + c.monto);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            context.read<PrestamoCubit>().onGetChild(CrearPrestamoView());
          },
        ),
        title: const Text(
          'Pagos esperados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Banner resumen ──────────────────────────────────────
          _ResumenBanner(
            cuotasPasadas: _cuotasPasadas,
            totalCuotas: _cuotas.length,
            totalPasado: _totalPasado,
          ),

          // ── Lista ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: _cuotas.length,
              itemBuilder: (context, i) {
                final cuota = _cuotas[i];
                return _CuotaItem(
                  cuota: cuota,
                  controller: _controllers[i],
                  onMontoChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) {
                      setState(() => _cuotas[i].monto = parsed);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── Botón confirmar ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,

            child: BlocBuilder<PrestamoCubit, PrestamoState>(
              builder: (context, state) {
                return BtnWidget.btn(
                  enabled: true,
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  loading: state.loadingBtn,
                  text: "Confirmar y crear préstamo",
                  onPressed: () {
                    context.read<PrestamoCubit>().crearPrestamoExistente();
                  },
                  icon: Icons.check_rounded,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner resumen ────────────────────────────────────────────────────────────

class _ResumenBanner extends StatelessWidget {
  const _ResumenBanner({
    required this.cuotasPasadas,
    required this.totalCuotas,
    required this.totalPasado,
  });

  final int cuotasPasadas;
  final int totalCuotas;
  final double totalPasado;

  @override
  Widget build(BuildContext context) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuotas hasta la fecha',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$cuotasPasadas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'de $totalCuotas cuotas',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total esperado: \$${totalPasado.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item de cuota ─────────────────────────────────────────────────────────────

class _CuotaItem extends StatefulWidget {
  const _CuotaItem({
    required this.cuota,
    required this.controller,
    required this.onMontoChanged,
  });

  final CuotaEsperada cuota;
  final TextEditingController controller;
  final ValueChanged<String> onMontoChanged;

  @override
  State<_CuotaItem> createState() => _CuotaItemState();
}

class _CuotaItemState extends State<_CuotaItem> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final cuota = widget.cuota;
    final fecha = DateUtil.formatLectura(cuota.fechaCobro);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cuota.esPasada
              ? AppTheme.primaryColor.withValues(alpha: .25)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Row(
        children: [
          // ── Número ───────────────────────────────────────────────
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cuota.esPasada
                  ? AppTheme.primaryColor
                  : const Color(0xFFF0F2F5),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${cuota.numero}',
              style: TextStyle(
                color: cuota.esPasada ? Colors.white : const Color(0xFFA0A7B3),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuota ${cuota.numero}',
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: Color(0xFF929BAB),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fecha,
                      style: const TextStyle(
                        color: Color(0xFF929BAB),
                        fontSize: 11,
                      ),
                    ),
                    if (cuota.esPasada) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Esperada',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Monto editable ────────────────────────────────────────
          if (_editing)
            SizedBox(
              width: 90,
              child: TextField(
                controller: widget.controller,
                autofocus: true,
                enabled: cuota.esPasada,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF202838),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                onChanged: widget.onMontoChanged,
                onSubmitted: (_) => setState(() => _editing = false),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _editing = true),
              child: Row(
                children: [
                  Text(
                    '\$${cuota.monto.toInt()}',
                    style: TextStyle(
                      color: cuota.esPasada
                          ? AppTheme.primaryColor
                          : const Color(0xFF202838),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Visibility(
                    visible: cuota.esPasada,
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFF929BAB),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
