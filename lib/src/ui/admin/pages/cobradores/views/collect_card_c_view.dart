import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/utils/contact_util.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/corbador_detalle_view.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/status_collect_card.dart';
import 'package:personal/src/ui/admin/pages/rutas/ruta_page.dart';

// IMPORTA AQUÍ EL MODELO DE RUTA
// import 'package:personal/src/.../datum_r_model.dart';

class CollectCardCView extends StatelessWidget {
  final String name;
  final List<DatumREntity> rutas;
  final String id;
  final String phone;
  final int clients;
  final String collected;
  final String avatar;
  final bool active;

  const CollectCardCView({
    super.key,
    required this.name,
    required this.rutas,
    required this.clients,
    required this.collected,
    required this.avatar,
    required this.active,
    required this.phone,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: .04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // INFORMACIÓN DEL COBRADOR
          // =====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------
              // AVATAR
              // -------------------------------------------------
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 25)),
                ),
              ),

              const SizedBox(width: 12),

              // -------------------------------------------------
              // INFORMACIÓN
              // -------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE + ESTADO
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF202838),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        StatusCollectCard(active: active),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // =================================================
                    // RUTAS
                    // =================================================
                    _rutasInfo(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // =====================================================
          // PARTE INFERIOR
          // =====================================================
          Row(
            children: [
              // -------------------------------------------------
              // RECAUDADO
              // -------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF3),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collected,
                      style: const TextStyle(
                        color: Color(0xFF00A86B),
                 
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Recaudado hoy',
                      style: TextStyle(color: Color(0xFF7B8494), ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // -------------------------------------------------
              // LLAMAR
              // -------------------------------------------------
              _actionButton(
                action: () {
                  ContactUtil.open(telefono: phone, action: ContactAction.call);
                },
                icon: Icons.phone_outlined,
                color: const Color(0xFF4F7CFF),
              ),

              const SizedBox(width: 8),

              // -------------------------------------------------
              // VER DETALLE
              // -------------------------------------------------
              _actionButton(
                action: () {
                  context.read<CobradorCubit>().detalleCobrador(id);

                  context.read<CobradorCubit>().eventChild(
                    CobradorDetalleView(),
                  );
                },
                icon: Icons.visibility,
                color: const Color(0xFFFFA62B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // INFORMACIÓN DE RUTAS
  // ===========================================================

  Widget _rutasInfo() {
    // ----------------------------------------------------------
    // SIN RUTAS
    // ----------------------------------------------------------
    if (rutas.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.route_outlined, size: 14, color: Color(0xFF929BAB)),

          const SizedBox(width: 5),

          const Text(
            'Sin ruta asignada',
            style: TextStyle(color: Color(0xFF929BAB), ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // RUTAS ASIGNADAS
    // ----------------------------------------------------------
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: rutas.map((ruta) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      state.context,
                      MaterialPageRoute(
                        builder: (_) => RutaPage(showDetail: true, ruta: ruta),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          size: 13,
                          color: Color(0xFF5E6878),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          ruta.nombre,
                          style: const TextStyle(
                            color: Color(0xFF5E6878),
                         
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 13,
                  color: Color(0xFF929BAB),
                ),

                const SizedBox(width: 4),

                Text(
                  '$clients ${clients == 1 ? 'cliente' : 'clientes'}',
                  style: const TextStyle(
                    color: Color(0xFF7B8494),
                   
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // BOTÓN DE ACCIÓN
  // ===========================================================

  Widget _actionButton({
    required Function() action,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}
