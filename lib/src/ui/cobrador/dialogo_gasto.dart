
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';

void dialogoGasto(
  BuildContext context,
  List<DatumREntity> rutas,
  CobradorRCubit c,
) {
  if (rutas.isEmpty) return;

  // Rutas que tienen caja abierta (O(1) gracias al mapa del state)
  final cajaPorRuta = c.state.cajaPorRuta;

  if (rutas.length == 1) {
    _mostrarFormularioGasto(context, rutas.first, c);
    return;
  }

  // Ordena: primero las que tienen caja
  final rutasOrdenadas = [...rutas]
    ..sort((a, b) {
      final aTiene = cajaPorRuta.containsKey(a.id);
      final bTiene = cajaPorRuta.containsKey(b.id);
      if (aTiene && !bTiene) return -1;
      if (!aTiene && bTiene) return 1;
      return 0;
    });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider.value(
        value: c,
        child: BlocBuilder<CobradorRCubit, CobradorRState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8DCE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Selecciona una ruta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202838),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Selecciona la ruta a la que pertenece el gasto.',
                      style: TextStyle(color: Color(0xFF929BAB)),
                    ),

                    const SizedBox(height: 20),

                    ...rutasOrdenadas.map(
                      (ruta) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: !cajaPorRuta.containsKey(ruta.id)
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _mostrarFormularioGasto(context, ruta, c);
                                },

                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE1E5EC),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      .10,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.route_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ruta.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF202838),
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        'Selecciona e ingresa la información',
                                        style: const TextStyle(
                                          color: Color(0xFF929BAB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Visibility(
                                  visible: cajaPorRuta.containsKey(ruta.id),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF929BAB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void _mostrarFormularioGasto(
  BuildContext context,
  DatumREntity ruta,
  CobradorRCubit c,
) {
  // O(1) — no más búsqueda en listas anidadas
  final cajaId = c.state.cajaId(ruta.id) ?? '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider.value(
        value: c,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DCE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registrar gasto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF202838),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Registra un gasto realizado durante la jornada.',
                              style: TextStyle(color: Color(0xFF929BAB)),
                            ),
                          ],
                        ),
                      ),

                      // Ruta seleccionada
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ruta.nombre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: c.concepto,
                    textInputAction: TextInputAction.next,
                    onChanged: (e) {
                      c.validarForm();
                    },
                    decoration: InputDecoration(
                      labelText: 'Concepto',

                      hintText: 'Ej. Transporte',
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: c.valor,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (e) {
                      c.validarForm();
                    },
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      hintText: 'Ej. 15000',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: c.observacion,
                    maxLines: 2,
                    onChanged: (e) {
                      c.validarForm();
                    },
                    decoration: InputDecoration(
                      labelText: 'Observación',
                      hintText: 'Opcional',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  BlocBuilder<CobradorRCubit, CobradorRState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: BtnWidget.btn(
                          enabled: state.formGasto,
                          onPressed: () async {
                            c.crearGasto(idCaja: cajaId);
                            Navigator.pop(context);
                          },
                          icon: Icons.check_rounded,
                          text: 'Registrar gasto',
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
