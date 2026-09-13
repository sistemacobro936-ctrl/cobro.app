import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/collect_card_c_view.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/header_c_ciew.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/section_header_c_view.dart';

class CobradorHome extends StatelessWidget {
  const CobradorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        final cobradores = state.cobradores ?? [];
        return Column(
          children: [
            HeaderCCiew(),

            Visibility(
              visible: !state.loading,
              child: Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  children: [
                    SectionHeaderCView(),

                    ...cobradores.map(
                      (c) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: CollectCardCView(
                          name: c.nombre,
                          phone: c.telefono,
                          id: c.id,
                          rutas: c.rutas,

                          clients: c.rutas.fold<int>(
                            0,
                            (total, ruta) => total + (ruta.cantidadClientes),
                          ),
                          collected: '\$ 0',
                          avatar: '👩‍💼',
                          active: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
