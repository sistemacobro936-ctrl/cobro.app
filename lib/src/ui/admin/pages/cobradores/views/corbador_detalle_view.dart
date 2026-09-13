import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/contact_util.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/cobradores/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/cobrador_home.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/create_c_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/ruta_page.dart';

// ignore: must_be_immutable
class CobradorDetalleView extends StatelessWidget {
  CobradorDetalleView({super.key});

  late DatumCEntity cobrador;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        cobrador = state.cobrador!;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                context.read<CobradorCubit>().eventChild(CobradorHome());
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Detalle del cobrador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 25),
            child: Column(
              children: [
                _profileCard(),

                const SizedBox(height: 12),

                _rutaCard(),

                const SizedBox(height: 12),

                _infoCard(),

                const SizedBox(height: 12),

                _editButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PERFIL
  // ---------------------------------------------------------------------------

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: .80),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 34,
              color: Color(0xFF4164E8),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${cobrador.nombre} ${cobrador.apellido}',
            style: const TextStyle(
              color: Color(0xFF202838),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          _contactButton(
            icon: Icons.phone_outlined,
            text: 'Llamar',
            onTap: () {
              ContactUtil.open(
                telefono: cobrador.telefono,
                action: ContactAction.call,
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RUTA
  // ---------------------------------------------------------------------------

  Widget _rutaCard() {
    final rutas = cobrador.rutas;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.route_outlined),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rutas asignadas',
                      style: TextStyle(color: Color(0xFF929BAB), fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${rutas.length} ${rutas.length == 1 ? 'ruta asignada' : 'rutas asignadas'}',
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...rutas.asMap().entries.map((entry) {
            final index = entry.key;
            final ruta = entry.value;

            return Column(
              children: [
                _rutaItem(ruta),

                if (index < rutas.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE8EBF0)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _rutaItem(DatumREntity ruta) {
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        return InkWell(
          onTap: () {
            // Ir al detalle de la ruta
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: Color(0xFF202838),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ruta.nombre,
                        style: const TextStyle(
                          color: Color(0xFF202838),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 13,
                            color: Color(0xFF929BAB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ruta.cantidadClientes} clientes',
                            style: TextStyle(
                              color: Color(0xFF929BAB),
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 13,
                            color: Color(0xFF929BAB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${ruta.capital}',
                            style: const TextStyle(
                              color: Color(0xFF929BAB),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.push(
                      state.context,
                      MaterialPageRoute(
                        builder: (_) => RutaPage(showDetail: true, ruta: ruta),
                      ),
                    );
                  },
                  icon: Icon(Icons.keyboard_arrow_right_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ---------------------------------------------------------------------------
  // INFORMACIÓN
  // ---------------------------------------------------------------------------

  Widget _infoCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              color: Color(0xFF202838),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          _detailRow(
            icon: Icons.badge_outlined,
            title: 'Documento',
            value: cobrador.documento,
          ),

          _divider(),
          _detailRow(
            icon: Icons.phone,

            title: 'Teléfono',
            value: cobrador.telefono,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENTES
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // BOTÓN
  // ---------------------------------------------------------------------------

  Widget _editButton() {
    return BlocBuilder<CobradorCubit, CobradorState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.read<CobradorCubit>().loadC();
              context.read<CobradorCubit>().eventChild(
                CreateCView(isEdit: true),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Editar cobrador',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES
  // ---------------------------------------------------------------------------

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF4164E8), size: 22),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 19),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF929BAB), fontSize: 9),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF394354),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.black.withValues(alpha: .06)),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FC),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4164E8)),

            const SizedBox(width: 7),

            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF394354),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withValues(alpha: .05)),
    );
  }
}
