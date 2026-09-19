import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/domain/entities/pago_ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

/// Quiénes pagaron y quiénes no en la caja del día
class GestionCobros extends StatefulWidget {
  const GestionCobros({super.key});

  @override
  State<GestionCobros> createState() => _GestionCobrosState();
}

class _GestionCobrosState extends State<GestionCobros> {
  bool _verPagaron = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        final pagos = state.pagos;
        final noPagos = state.noPagos;

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
                  Icon(
                    Icons.fact_check_outlined,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Gestión de cobros',
                    style: TextStyle(
                      color: Color(0xFF202838),
                      
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _tab(
                      label: 'Pagaron',
                      count: pagos?.length,
                      color: Colors.green,
                      selected: _verPagaron,
                      onTap: () => setState(() => _verPagaron = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tab(
                      label: 'No pagaron',
                      count: noPagos?.length,
                      color: Colors.redAccent,
                      selected: !_verPagaron,
                      onTap: () => setState(() => _verPagaron = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (_verPagaron)
                _listaPagos(pagos)
              else
                _listaNoPagos(noPagos),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  Widget _listaPagos(List<PagoRutaEntity>? pagos) {
    if (pagos == null) return _cargando();
    if (pagos.isEmpty) return _vacio('Nadie ha pagado todavía.');

    return Column(
      children: pagos.map((p) {
        final hora = p.fechaPago == null
            ? null
            : '${p.fechaPago!.hour.toString().padLeft(2, '0')}:'
                  '${p.fechaPago!.minute.toString().padLeft(2, '0')}';

        return _item(
          icon: Icons.check_circle_rounded,
          cc: p.clienteCedula,
          color: p.aplicado ? Colors.green : Colors.grey,
          titulo: p.clienteNombre.isEmpty ? 'Cliente' : p.clienteNombre,
          subtitulo: [
            'Cuota \$${p.valorCuota}',
            'Deuda \$${p.deudaActual}',
            ?hora,
          ].join(' · '),
          trailing: '\$${p.valor}',
          trailingColor: p.aplicado ? Colors.green : Colors.grey,
          badge: p.aplicado ? null : p.estado,
        );
      }).toList(),
    );
  }

  Widget _listaNoPagos(List<NoPagoRutaEntity>? noPagos) {
    if (noPagos == null) return _cargando();
    if (noPagos.isEmpty) return _vacio('No hay no pagos registrados.');

    return Column(
      children: noPagos.map((n) {
        final detalle = <String>[
          if (n.fechaPromesa != null)
            'Promete pagar: ${DateUtil.formatDate(n.fechaPromesa!)}',
          if (n.observacion.isNotEmpty) n.observacion,
        ];

        return _item(
          cc:n.clienteCedula,
          icon: Icons.cancel_rounded,
          color: Colors.redAccent,
          titulo: n.clienteNombre.isEmpty ? 'Cliente' : n.clienteNombre,
          subtitulo: detalle.isEmpty
              ? 'Cuota \$${n.valorCuota}'
              : detalle.join(' · '),
          trailing: MotivoNoPago.labelDe(n.motivo),
          trailingColor: Colors.redAccent,
        );
      }).toList(),
    );
  }

  // ============================================================
  Widget _tab({
    required String label,
    required int? count,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: .10)
              : const Color(0xFFF5F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withValues(alpha: .40) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : const Color(0xFF7B8494),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? color : const Color(0xFFB0B6C0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count?.toString() ?? '-',
                style: const TextStyle(
                  color: Colors.white,
                 
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required Color color,
    required String titulo,
    required String cc,
    required String subtitulo,
    required String trailing,
    required Color trailingColor,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF202838),
                
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cc,
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                
                  ),
                ),

                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailing,
                style: TextStyle(
                  color: trailingColor,
                 
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (badge != null)
                Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cargando() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _vacio(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        texto,
        style: const TextStyle(color: Color(0xFF929BAB), fontSize: 13),
      ),
    );
  }
}
