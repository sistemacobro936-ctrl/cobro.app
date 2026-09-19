import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/domain/dto/no_pago_dto.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Datos capturados en el formulario de "No pagó"
class NoPagoData {
  final MotivoNoPago motivo;
  final String observacion;
  final DateTime? fechaPromesa;

  NoPagoData({
    required this.motivo,
    required this.observacion,
    this.fechaPromesa,
  });
}

/// Devuelve los datos si el usuario confirma, o null si cancela.
Future<NoPagoData?> showNoPagoBottomSheet(
  BuildContext context, {
  required String clienteNombre,
}) {
  final observacionController = TextEditingController();
  MotivoNoPago? motivo;
  DateTime? fechaPromesa;

  return showModalBottomSheet<NoPagoData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final requiereFecha = motivo?.requiereFechaPromesa ?? false;
          final puedeConfirmar =
              motivo != null && (!requiereFecha || fechaPromesa != null);

          Future<void> elegirFecha() async {
            final manana = DateUtils.dateOnly(
              DateTime.now().add(const Duration(days: 1)),
            );
            final date = await showDatePicker(
              context: context,
              initialDate: fechaPromesa ?? manana,
              firstDate: manana,
              lastDate: manana.add(const Duration(days: 365)),
            );
            if (date != null) setState(() => fechaPromesa = date);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.money_off_rounded,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registrar no pago',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                clienteNombre,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      'Motivo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MotivoNoPago.values.map((m) {
                        final selected = m == motivo;
                        return ChoiceChip(
                          label: Text(m.label),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF394354),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onSelected: (_) => setState(() {
                            motivo = m;
                            if (!m.requiereFechaPromesa) fechaPromesa = null;
                          }),
                        );
                      }).toList(),
                    ),

                    if (requiereFecha) ...[
                      const SizedBox(height: 18),
                      Text(
                        'Fecha en que promete pagar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: elegirFecha,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: .05),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                color: Color(0xFF7B8494),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                fechaPromesa == null
                                    ? 'Seleccionar fecha'
                                    : DateUtil.formatDate(fechaPromesa!),
                                style: TextStyle(
                                  color: fechaPromesa == null
                                      ? Colors.grey.shade500
                                      : const Color(0xFF202838),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    Text(
                      'Observación (opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: observacionController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ej: Dice que paga el viernes',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.black.withValues(alpha: .05),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: BtnWidget.btn(
                        enabled: puedeConfirmar,
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        text: 'Confirmar no pago',
                        onPressed: () {
                          Navigator.pop(
                            context,
                            NoPagoData(
                              motivo: motivo!,
                              observacion: observacionController.text.trim(),
                              fechaPromesa: fechaPromesa,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
