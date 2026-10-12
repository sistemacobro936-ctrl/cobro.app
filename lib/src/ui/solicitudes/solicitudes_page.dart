import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/solicitud_cliente_entity.dart';
import 'package:personal/src/ui/solicitudes/cubit/solicitudes_cubit.dart';

/// Lista de solicitudes de clientes de otro negocio. Con [esAdmin] se pueden
/// aprobar o rechazar; si no, el cobrador consulta el estado de las suyas.
class SolicitudesPage extends StatelessWidget {
  const SolicitudesPage({super.key, required this.esAdmin, this.onAprobada});

  final bool esAdmin;

  /// Tras aprobar con éxito se vuelve a la primera pantalla (Home) y se
  /// llama esto, p. ej. para mostrar el Inicio con el resumen actualizado
  final VoidCallback? onAprobada;

  static const _filtros = {
    'PENDIENTE': 'Pendientes',
    'APROBADA': 'Aprobadas',
    'RECHAZADA': 'Rechazadas',
    '': 'Todas',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SolicitudesCubit(context, esAdmin: esAdmin),
      child: BlocBuilder<SolicitudesCubit, SolicitudesState>(
        builder: (context, state) {
          final c = context.read<SolicitudesCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FC),
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                esAdmin ? 'Solicitudes de clientes' : 'Mis solicitudes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: c.cargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                children: [
                  _filtrosEstado(state, c),
                  const SizedBox(height: 16),
                  if (state.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (state.solicitudes.isEmpty)
                    _vacio()
                  else
                    ...state.solicitudes.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SolicitudCard(
                          solicitud: s,
                          onTap: () => _abrirDetalle(context, s),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filtrosEstado(SolicitudesState state, SolicitudesCubit c) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final f in _filtros.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.value),
                selected: state.filtroEstado == f.key,
                showCheckmark: false,
                selectedColor: AppTheme.primaryColor,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black.withValues(alpha: .05)),
                labelStyle: TextStyle(
                  color: state.filtroEstado == f.key
                      ? Colors.white
                      : const Color(0xFF394354),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onSelected: (_) => c.seleccionarEstado(f.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vacio() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Color(0xFFB0B6C0)),
          SizedBox(height: 10),
          Text(
            'No hay solicitudes.',
            style: TextStyle(color: Color(0xFF929BAB)),
          ),
        ],
      ),
    );
  }

  void _abrirDetalle(BuildContext context, SolicitudClienteEntity s) {
    final cubit = context.read<SolicitudesCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: _DetalleSolicitud(solicitud: s, onAprobada: onAprobada),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════

/// Etiqueta y colores de cada estado
({String texto, Color color}) _estado(String estado) => switch (estado) {
  'PENDIENTE' => (texto: 'Pendiente', color: const Color(0xFFB7791F)),
  'APROBADA' => (texto: 'Aprobada', color: const Color(0xFF1E9E5A)),
  'RECHAZADA' => (texto: 'Rechazada', color: const Color(0xFFD64545)),
  _ => (texto: estado, color: const Color(0xFF8A93A3)),
};

Widget _chipEstado(String estado) {
  final e = _estado(estado);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: e.color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      e.texto,
      style: TextStyle(
        color: e.color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SolicitudCard extends StatelessWidget {
  const _SolicitudCard({required this.solicitud, required this.onTap});

  final SolicitudClienteEntity solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = solicitud;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${s.cliente.nombres} ${s.cliente.apellidos}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _chipEstado(s.estado),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'CC ${s.cedula} · ${s.rutaNombre}',
                style: const TextStyle(color: Color(0xFF7D8797)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.request_quote_outlined,
                    size: 16,
                    color: Color(0xFF7B8494),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${MoneyUtil.format(s.prestamo.monto)} · '
                    '${s.prestamo.numeroCuotas} cuotas '
                    '${s.prestamo.frecuencia.toLowerCase()}',
                    style: const TextStyle(
                      color: Color(0xFF394354),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (s.createdAt != null)
                    Text(
                      DateUtil.formatDate(s.createdAt!),
                      style: const TextStyle(
                        color: Color(0xFF9AA2AF),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              if (s.cobradorNombre.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Enviada por ${s.cobradorNombre}',
                  style: const TextStyle(
                    color: Color(0xFF9AA2AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════

class _DetalleSolicitud extends StatelessWidget {
  const _DetalleSolicitud({required this.solicitud, this.onAprobada});

  final SolicitudClienteEntity solicitud;
  final VoidCallback? onAprobada;

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final p = s.prestamo;

    return BlocBuilder<SolicitudesCubit, SolicitudesState>(
      builder: (context, state) {
        final c = context.read<SolicitudesCubit>();
        final acciones = state.esAdmin && s.pendiente;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Detalle de la solicitud',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${s.cliente.nombres} ${s.cliente.apellidos}',
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _chipEstado(s.estado),
                ],
              ),
              const SizedBox(height: 12),
              _aviso(
                icon: Icons.storefront_outlined,
                color: const Color(0xFFB7791F),
                texto: s.detalleOtroNegocio,
              ),
              if (s.estado == 'RECHAZADA' &&
                  (s.motivoRechazo ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                _aviso(
                  icon: Icons.block_rounded,
                  color: const Color(0xFFD64545),
                  texto: 'Motivo del rechazo: ${s.motivoRechazo}',
                ),
              ],
              const SizedBox(height: 18),
              _seccion('Cliente', [
                _fila('Cédula', s.cedula),
                _fila('Teléfono', s.cliente.telefono),
                if (s.cliente.whatsapp.isNotEmpty)
                  _fila('WhatsApp', s.cliente.whatsapp),
                _fila('Dirección', s.cliente.direccion),
                if (s.cliente.descripcionDireccion.isNotEmpty)
                  _fila('Referencia', s.cliente.descripcionDireccion),
                if (s.cliente.barrio.isNotEmpty)
                  _fila('Barrio', s.cliente.barrio),
                if (s.cliente.observacion.isNotEmpty)
                  _fila('Observación', s.cliente.observacion),
                _fila('Ruta', s.rutaNombre),
                if (s.cobradorNombre.isNotEmpty)
                  _fila('Cobrador', s.cobradorNombre),
              ]),
              const SizedBox(height: 14),
              _seccion('Préstamo solicitado', [
                _fila('Monto', MoneyUtil.format(p.monto)),
                _fila('Interés', '${p.interes}% (${MoneyUtil.format(p.montoInteres)})'),
                _fila('Seguro', MoneyUtil.format(p.valorSeguro)),
                _fila('Se entrega', MoneyUtil.format(p.monto - p.valorSeguro)),
                _fila('Total a pagar', MoneyUtil.format(p.monto + p.montoInteres)),
                _fila(
                  'Cuotas',
                  '${p.numeroCuotas} × ${MoneyUtil.format(p.valorCuota)} '
                      '(${p.frecuencia.toLowerCase()})',
                ),
                _fila('Inicio', p.fechaInicio),
                _fila('Fin', p.fechaFin),
              ]),
              if (acciones) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.procesando
                            ? null
                            : () => _rechazar(context, c),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.procesando
                            ? null
                            : () async {
                                final ok = await c.aprobar(s);
                                if (ok && context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                  onAprobada?.call();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: state.procesando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Aprobar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _rechazar(BuildContext context, SolicitudesCubit c) async {
    final motivo = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rechazar solicitud'),
        content: TextField(
          controller: motivo,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();

    if (confirmado != true) return;
    final ok = await c.rechazar(solicitud, texto);
    if (ok && context.mounted) Navigator.pop(context);
  }

  Widget _aviso({
    required IconData icon,
    required Color color,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> filas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF202838),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...filas,
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF7D8797)),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Color(0xFF202838),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
