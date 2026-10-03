import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/utils/contact_util.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/status_cliente_view.dart';

class ClientCardView extends StatelessWidget {
  const ClientCardView({
    super.key,
    required this.initials,
    required this.name,
    required this.document,
    required this.route,
    required this.phone,
    required this.balance,
    required this.active,
    required this.id,
    this.orden=0,
    this.dragIndex,
  });

  final String initials;
  final String name;
  final String id;
  final String document;
  final String route;
  final String phone;
  final String balance;
  final bool active;
  final int orden;

  /// Posición dentro del ReorderableListView; con esto la mano actúa como
  /// manija para arrastrar y reordenar. Null = no se puede reordenar ahora
  /// (hay búsqueda activa o está en "Todos", donde el orden no aplica).
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final hasDebt = balance != '\$0';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDebt
              ? const Color(0xFFDBE4FF)
              : Colors.black.withValues(alpha: .04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // AVATAR
          // ----------------------------------------------------
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                "$orden",
                style: const TextStyle(
                  color: Color(0xFF4164E8),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ----------------------------------------------------
          // INFORMATION
          // ----------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202838),
                       
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    StatusClienteView(active: active),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  document,
                  style: const TextStyle(
                    color: Color(0xFF7D8797),
               
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  route,
                  style: const TextStyle(
                    color: Color(0xFF7D8797),
                
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Color(0xFF6F7888),
                       
                      ),
                    ),

                    const SizedBox(width: 12),

                    
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // ----------------------------------------------------
          // ACTIONS
          // ----------------------------------------------------
          Column(
            children: [
              _actionButton(
                onTap: () {
                  ContactUtil.open(telefono: phone, action: ContactAction.call);
                },
                icon: Icons.phone_outlined,
                color: const Color(0xFF4F7CFF),
              ),

              const SizedBox(height: 7),

              _actionButton(
                onTap: () {
                  context.read<ClienteCubit>().detalleCliente(id);
                },
                icon: Icons.visibility_outlined,
                color: const Color(0xFFFFA62B),
              ),
              const SizedBox(height: 7),

              dragIndex != null
                  ? ReorderableDragStartListener(
                      index: dragIndex!,
                      child: _actionButton(
                        onTap: () {},
                        icon: Icons.back_hand_sharp,
                        color: Colors.green,
                      ),
                    )
                  : _actionButton(
                      onTap: () {},
                      icon: Icons.back_hand_sharp,
                      color: const Color(0xFFB0B6C0),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required Function() onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}
