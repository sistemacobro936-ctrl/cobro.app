import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/movimientos_caja_entity.dart';
import 'package:personal/src/ui/admin/pages/caja/cubit/caja_cubit.dart';

/// Abre los movimientos de la caja y los consulta al backend
void abrirMovimientosCaja(BuildContext context, CajaCubit c) {
  c.movimientos();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          BlocProvider.value(value: c, child: const MovimientosCajaView()),
    ),
  );
}

/// Abre los movimientos de una caja del histórico. Usa su propio cubit, que se
/// cierra al salir de la pantalla.
void abrirMovimientosCajaHistorica(BuildContext context, String cajaId) {
  final c = CajaCubit(context: context)..movimientos(cajaId: cajaId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          BlocProvider(create: (_) => c, child: const MovimientosCajaView()),
    ),
  );
}

class MovimientosCajaView extends StatelessWidget {
  const MovimientosCajaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CajaCubit, CajaState>(
      builder: (context, state) {
        final m = state.movimientos;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FC),
          appBar: AppBar(
            title: const Text(
              'Movimientos de caja',
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
          body: state.loadingMovimientos
              ? const Center(child: CircularProgressIndicator.adaptive())
              : m == null
              ? _mensaje('No se pudieron cargar los movimientos.')
              : RefreshIndicator(
                  onRefresh: context.read<CajaCubit>().movimientos,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    children: [
                      _resumen(m),
                      const SizedBox(height: 18),
                      _inyecciones(m.inyeccionesCapital),
                      const SizedBox(height: 18),
                      _pagosDobles(m.pagosDobles),
                      const SizedBox(height: 18),
                      _pagosMenores(m.pagosMenores),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _resumen(MovimientosCajaEntity m) {
    final r = m.resumen;

    return _section(
      title: m.caja.rutaNombre.isEmpty ? 'Resumen' : m.caja.rutaNombre,
      icon: Icons.summarize_outlined,
      child: Column(
        children: [
          _filaResumen(
            'Dinero agregado',
            '${r.cantidadInyecciones}',
            '\$ ${r.totalInyectado}',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _filaResumen(
            'Multiples pagos',
            '${r.cantidadPagosDobles}',
            null,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _filaResumen(
            'Pagos menores (faltante)',
            '${r.cantidadPagosMenores}',
            '\$ ${r.faltanteTotal}',
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(
    String titulo,
    String cantidad,
    String? valor,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            cantidad,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(titulo, style: const TextStyle(color: Color(0xFF394354))),
        ),
        if (valor != null)
          Text(
            valor,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
      ],
    );
  }

  // ============================================================
  // LISTAS
  // ============================================================

  Widget _inyecciones(List<InyeccionCapitalEntity> lista) {
    return _section(
      title: 'Dinero agregado a la caja',
      icon: Icons.add_circle_outline_rounded,
      child: lista.isEmpty
          ? _vacio('No se ha agregado dinero a la caja.')
          : Column(
              children: lista
                  .map(
                    (e) => _item(
                      icon: Icons.arrow_circle_up_rounded,
                      color: Colors.blue,
                      titulo: e.observacion.isEmpty
                          ? 'Inyección de capital'
                          : e.observacion,
                      subtitulo: _fechaHora(e.fecha),
                      trailing: '+\$${e.valor}',
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _pagosDobles(List<PagoDobleEntity> lista) {
    return _section(
      title: 'Multiples pagos',
      icon: Icons.library_add_check_outlined,
      child: lista.isEmpty
          ? _vacio('Ningún cliente ha pagado más de una vez.')
          : Column(
              children: lista
                  .map(
                    (e) => _item(
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                      titulo: _cliente(e.clienteNombre),
                      subtitulo: [
                        'Cuota \$${e.valorCuota}',
                        '${e.cantidadPagos} pagos',
                      ].join(' · '),
                      detalle: _detallePagos(e.pagos),
                      trailing: '\$${e.valorPagado}',
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _pagosMenores(List<PagoMenorEntity> lista) {
    return _section(
      title: 'Pagos menores',
      icon: Icons.remove_circle_outline_rounded,
      child: lista.isEmpty
          ? _vacio('No hay pagos por debajo de la cuota.')
          : Column(
              children: lista
                  .map(
                    (e) => _item(
                      icon: Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      titulo: _cliente(e.clienteNombre+"\nCC: ${e.clienteCedula}"),
                      subtitulo: [
                        'Cuota \$${e.valorCuota}',
                        ' \nPagó\$${e.valorPagado}',
                      ].join(''),
                      detalle: _detallePagos(e.pagos),
                      trailing: '-\$${e.faltante}',
                    ),
                  )
                  .toList(),
            ),
    );
  }

  // ============================================================
  // COMPONENTES
  // ============================================================

  String _cliente(String nombre) => nombre.isEmpty ? 'Cliente' : nombre;

  /// "\$3 (22:04) · \$1 (22:05)": cada abono con su hora
  String? _detallePagos(List<PagoMovimientoEntity> pagos) {
    if (pagos.isEmpty) return null;
    return pagos
        .map((p) {
          return '\n\$${p.valor}';
        })
        .join('');
  }

  /// Lun dd-MM-yyyy HH:mm en hora local
  String? _fechaHora(DateTime? f) {
    if (f == null) return null;
    return '${DateUtil.formatLectura(f)} '
        '${f.hour.toString().padLeft(2, '0')}:'
        '${f.minute.toString().padLeft(2, '0')}';
  }

  Widget _item({
    required IconData icon,
    required Color color,
    required String titulo,
    required String? subtitulo,
    required String trailing,
    String? detalle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (detalle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Abonos: $detalle',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _vacio(String texto) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      texto,
      style: const TextStyle(color: Color(0xFF929BAB), fontSize: 13),
    ),
  );

  Widget _mensaje(String texto) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF929BAB), fontSize: 13),
      ),
    ),
  );

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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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
}
