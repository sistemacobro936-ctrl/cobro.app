import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/domain/repository/cliente_repo.dart';

/// Estados del cliente con su texto y color
const estadosCliente = {
  'ACTIVO': 'Activo',
  'INACTIVO': 'Inactivo',
  'CLAVO': 'Clavo',
};

const colorClavo = Color(0xFF7A1F1F);

({String texto, Color color}) estadoClienteUi(String estado) =>
    switch (estado) {
      'ACTIVO' => (texto: 'Activo', color: const Color(0xFF4164E8)),
      'CLAVO' => (texto: 'Clavo', color: colorClavo),
      'INACTIVO' => (texto: 'Inactivo', color: const Color(0xFF8A93A3)),
      _ => (texto: estado, color: const Color(0xFF8A93A3)),
    };

class EstadoClienteChip extends StatelessWidget {
  const EstadoClienteChip({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final e = estadoClienteUi(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: e.color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: estado == 'CLAVO' ? Border.all(color: colorClavo) : null,
      ),
      child: Text(
        e.texto,
        style: TextStyle(
          color: e.color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Fila de un préstamo vencido: barra de color del nivel, cliente, días y
/// saldo. [onCambiarEstado] muestra el menú para marcar/quitar CLAVO.
class AtrasadoTile extends StatelessWidget {
  const AtrasadoTile({super.key, required this.atrasado, this.onCambiarEstado});

  final AtrasadoEntity atrasado;
  final ValueChanged<String>? onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final a = atrasado;
    final color = a.nivel?.color ?? const Color(0xFF8A93A3);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${a.nombres} ${a.apellidos}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF202838),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        EstadoClienteChip(estado: a.estadoCliente),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC ${a.cedula}${a.rutaNombre.isEmpty ? '' : ' · ${a.rutaNombre}'}',
                      style: const TextStyle(color: Color(0xFF7D8797)),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                   
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${a.diasAtraso} ${a.diasAtraso == 1 ? 'día' : 'días'}',
                        style: TextStyle(
                          color: _textoSobre(color),

                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    Text(
                      'Venció ${DateUtil.formatLectura(DateTime.parse(a.fechaFin))}',
                      style: const TextStyle(color: Color(0xFF7D8797)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Saldo ${MoneyUtil.format(a.saldo)} · Préstamo ${MoneyUtil.format(a.monto)}',
                      style: const TextStyle(
                        color: Color(0xFF394354),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onCambiarEstado != null)
              PopupMenuButton<String>(
                tooltip: 'Estado del cliente',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF9AA2AF),
                ),
                onSelected: onCambiarEstado,
                itemBuilder: (_) => [
                  if (!a.clavo)
                    const PopupMenuItem(
                      value: 'CLAVO',
                      child: Text('Marcar como CLAVO'),
                    )
                  else
                    const PopupMenuItem(
                      value: 'ACTIVO',
                      child: Text('Quitar CLAVO (volver a Activo)'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Texto legible sobre el fondo claro del color del nivel
  static Color _textoSobre(Color c) => Color.lerp(c, Colors.black, .45)!;
}

/// Pide confirmación (con motivo opcional) y cambia el estado del cliente.
/// Devuelve true si se cambió.
Future<bool> cambiarEstadoCliente(
  BuildContext context, {
  required String clienteId,
  required String nombre,
  required String estadoActual,
  required String nuevoEstado,
}) async {
  final motivo = TextEditingController();
  final nuevo = estadosCliente[nuevoEstado] ?? nuevoEstado;
  final actual = estadosCliente[estadoActual] ?? estadoActual;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        nuevoEstado == 'CLAVO' ? 'Marcar como CLAVO' : 'Cambiar estado',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nombre pasará de "$actual" a "$nuevo". '
            'No cambia sus deudas, pagos ni historial.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: motivo,
            maxLines: 2,
            maxLength: 250,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: nuevoEstado == 'CLAVO'
              ? ElevatedButton.styleFrom(
                  backgroundColor: colorClavo,
                  foregroundColor: Colors.white,
                )
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  final texto = motivo.text;
  motivo.dispose();
  if (confirmado != true || !context.mounted) return false;

  final r = await sl<ClienteRepository>().cambiarEstado(
    id: clienteId,
    estado: nuevoEstado,
    motivo: texto,
  );
  if (!context.mounted) return false;

  return r.fold(
    (l) {
      AppDialogUtil.error(context, message: l.props[0].toString());
      return false;
    },
    (_) {
      AppDialogUtil.success(
        context,
        message: 'Estado de $nombre cambiado a "$nuevo".',
      );
      return true;
    },
  );
}
