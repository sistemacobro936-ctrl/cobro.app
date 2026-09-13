import 'package:flutter/material.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/entities/pago_entity.dart';

/// Abre el diálogo de pagos.
///
/// [onRevertir] es opcional. Si se pasa, cada pago APLICADO muestra el botón
/// "Revertir" que al confirmarse invoca `onRevertir(pagoId, motivo)`.
Future<void> showPagosDialog({
  required BuildContext context,
  required List<PagoEntity> pagos,
  Future<bool> Function(String pagoId)? onRevertir,
}) {
  pagos.sort((a, b) => b.fechaPago!.compareTo(a.fechaPago!));
  return showDialog(
    context: context,
    builder: (_) => _PagosDialog(pagos: pagos, onRevertir: onRevertir),
  );
}

// ---------------------------------------------------------------------------
// Dialog (StatefulWidget para actualizar visualmente la lista tras revertir)
// ---------------------------------------------------------------------------

class _PagosDialog extends StatefulWidget {
  const _PagosDialog({required this.pagos, this.onRevertir});

  final List<PagoEntity> pagos;
  final Future<bool> Function(String pagoId)? onRevertir;

  @override
  State<_PagosDialog> createState() => _PagosDialogState();
}

class _PagosDialogState extends State<_PagosDialog> {
  late List<PagoEntity> _pagos;

  @override
  void initState() {
    super.initState();
    _pagos = List.from(widget.pagos);
  }

  /// Marca el pago como REVERSADO localmente para que la UI reaccione
  /// inmediatamente sin necesidad de cerrar el diálogo.
  void _marcarReversado(String pagoId) {
    setState(() {
      final idx = _pagos.indexWhere((p) => p.id == pagoId);
      if (idx == -1) return;
      final p = _pagos[idx];
      _pagos[idx] = PagoEntity(
        id: p.id,
        prestamoId: p.prestamoId,
        registradoPorId: p.registradoPorId,
        valor: p.valor,
        estado: 'REVERSADO',
        fechaPago: p.fechaPago,
        fechaReversion: DateTime.now(),
        usuarioReversionId: p.usuarioReversionId,
        createdAt: p.createdAt,
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PagosHeader(pagos: _pagos),
            Flexible(
              child: _pagos.isEmpty
                  ? _emptyPayments()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                      shrinkWrap: true,
                      itemCount: _pagos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final pago = _pagos[index];
                        return _PagoCard(
                          pago: pago,
                          onRevertir:
                              DateUtil.formatDate(pago.fechaPago!) !=
                                  DateUtil.formatDate(DateTime.now())
                              ? null
                              : widget.onRevertir == null
                              ? null
                              : () async {
                                  final ok = await widget.onRevertir!(
                                    pago.id
                                  );
                                  if (ok) _marcarReversado(pago.id);
                                  return ok;
                                },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _PagosHeader extends StatelessWidget {
  const _PagosHeader({required this.pagos});
  final List<PagoEntity> pagos;

  @override
  Widget build(BuildContext context) {
    final aplicados = pagos
        .where((e) => e.estado == 'APLICADO')
        .fold<num>(0, (t, p) => t + p.valor);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF4164E8),
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pagos realizados',
                  style: TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${pagos.where((e) => e.estado == 'APLICADO').length} pagos • ${_formatMoney(aplicados)}',
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF8A93A3),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de pago
// ---------------------------------------------------------------------------

class _PagoCard extends StatefulWidget {
  const _PagoCard({required this.pago, this.onRevertir});

  final PagoEntity pago;

  /// Devuelve true si la reversión fue exitosa.
  final Future<bool> Function()? onRevertir;

  @override
  State<_PagoCard> createState() => _PagoCardState();
}

class _PagoCardState extends State<_PagoCard> {
  bool _loadingRevertir = false;

  Future<void> _handleRevertir() async {
    final motivo = await _showMotivoDialog(context);
    if (motivo == null) return;

    setState(() => _loadingRevertir = true);
    await widget.onRevertir!();
    if (mounted) setState(() => _loadingRevertir = false);
  }

  @override
  Widget build(BuildContext context) {
    final reversado = widget.pago.estado == 'REVERSADO';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        children: [
          // Ícono de estado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: reversado
                  ? const Color(0xFFFFF1F1)
                  : const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              reversado ? Icons.undo_rounded : Icons.check_rounded,
              color: reversado ? const Color(0xFFE05252) : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reversado ? 'Pago reversado' : 'Pago realizado',
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(widget.pago.fechaPago!),
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),
                if (reversado && widget.pago.motivoReversion != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.pago.motivoReversion!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE05252),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Monto
          Text(
            _formatMoney(widget.pago.valor),
            style: TextStyle(
              color: reversado
                  ? const Color(0xFFE05252)
                  : const Color(0xFF202838),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),

          // Botón revertir — solo si hay callback y el pago está APLICADO
          if (!reversado && widget.onRevertir != null) ...[
            const SizedBox(width: 8),
            _loadingRevertir
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE05252),
                    ),
                  )
                : Tooltip(
                    message: 'Revertir pago',
                    child: InkWell(
                      onTap: _handleRevertir,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Color(0xFFE05252),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogo de motivo
// ---------------------------------------------------------------------------

Future<String?> _showMotivoDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.undo_rounded, color: Color(0xFFE05252), size: 20),
          SizedBox(width: 8),
          Text(
            'Revertir pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202838),
            ),
          ),
        ],
      ),
      content: Text("Esta acción no se puede deshacer, ¿Estás seguro?", textAlign: TextAlign.center,),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF929BAB)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
              Navigator.pop(ctx, controller.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE05252),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Confirmar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

Widget _emptyPayments() {
  return const Padding(
    padding: EdgeInsets.all(35),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.payments_outlined, size: 42, color: Color(0xFFB8BFCC)),
        SizedBox(height: 10),
        Text(
          'Sin pagos registrados',
          style: TextStyle(
            color: Color(0xFF394354),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Este préstamo aún no tiene pagos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF929BAB), fontSize: 10),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatMoney(num value) => '\$${value.toStringAsFixed(0)}';

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$d/$m/$y • $hour:$minute';
}
