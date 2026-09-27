import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/movimiento_log_entity.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_home.dart';

/// Bitácora de eventos de la ruta: quién hizo qué y cuándo (edición de ruta,
/// inyección de capital, etc.). GET /movimientos/ruta/:rutaId
class MovimientoRutaView extends StatelessWidget {
  const MovimientoRutaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        final c = context.read<RutaCubit>();
        final movimientos = state.movimientosRuta ?? [];
        final cargando = state.loadingMovimientos;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            title: const Text(
              'Movimiento de ruta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              onPressed: () => c.onEventChild(const RutaHome()),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          body: cargando
              ? const Center(child: CircularProgressIndicator.adaptive())
              : movimientos.isEmpty
              ? _buildVacio()
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      c.cargarMasMovimientos();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: movimientos.length + (state.loadingMasMovimientos ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      if (index >= movimientos.length) {
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
                      return _buildMovimiento(movimientos[index]);
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMovimiento(DatumMovimientoLogEntity mov) {
    final estilo = _estiloTipo(mov.tipo);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: estilo.color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(estilo.icon, size: 19, color: estilo.color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        estilo.etiqueta,
                        style: TextStyle(
                          
                          fontWeight: FontWeight.w800,
                          color: estilo.color,
                        ),
                      ),
                    ),
                    Text(
                      DateUtil.formatLectura(mov.createdAt),
                      style: const TextStyle(
                        
                        color: Color(0xFF929BAB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mov.descripcion.isEmpty ? mov.tipo : mov.descripcion,
                  style: const TextStyle(
                   
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

  /// Ícono/color según el tipo de evento. Los tipos que no se conocen caen
  /// en un estilo neutro, con el código tal cual como etiqueta.
  _EstiloTipo _estiloTipo(String tipo) {
    switch (tipo) {
      case 'RUTA_EDITADA':
      case 'RUTA_CREADA':
        return _EstiloTipo(Icons.edit_outlined, AppTheme.primaryColor, 'Ruta');
      case 'INYECCION_CAPITAL':
        return _EstiloTipo(
          Icons.add_circle_outline_rounded,
          Colors.green,
          'Capital',
        );
      case 'COBRADOR_ASIGNADO':
        return _EstiloTipo(
          Icons.person_outline_rounded,
          Colors.blue,
          'Cobrador',
        );
      case 'GASTO_RUTA':
        return _EstiloTipo(
          Icons.receipt_long_outlined,
          Colors.redAccent,
          'Gasto',
        );
      default:
        return _EstiloTipo(
          Icons.history_rounded,
          const Color(0xFF929BAB),
          tipo.isEmpty ? 'Evento' : tipo,
        );
    }
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Sin movimientos registrados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF394354),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aquí aparecerán los cambios que se hagan sobre esta ruta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF929BAB)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstiloTipo {
  final IconData icon;
  final Color color;
  final String etiqueta;

  _EstiloTipo(this.icon, this.color, this.etiqueta);
}
