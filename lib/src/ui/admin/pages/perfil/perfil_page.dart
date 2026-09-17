import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/administrador_entity.dart';
import 'package:personal/src/ui/admin/pages/perfil/cubit/perfil_cubit.dart';
import 'package:personal/src/ui/admin/pages/perfil/views/dialogo_agregar_admin.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late PerfilCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PerfilCubit(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: BlocBuilder<PerfilCubit, PerfilState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              title: const Text(
                'Mi perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerfilHeader(state),
                  const SizedBox(height: 18),
                  _buildAdministradoresSection(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerfilHeader(PerfilState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de administración',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.rol == "ADMIN"
                      ? "Administrador"
                      : (state.rol ?? "Sin información de rol"),
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministradoresSection(BuildContext context, PerfilState state) {
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
              const Expanded(
                child: Text(
                  'Administradores',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202838),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => mostrarDialogoAgregarAdmin(context, _cubit),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (state.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (state.administradores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aún no hay administradores registrados.',
                style: TextStyle(color: Color(0xFF929BAB), fontSize: 13),
              ),
            )
          else
            ...state.administradores.map(
              (a) => _administradorItem(
                a,
                esActual: state.usuarioId != null &&
                    state.usuarioId!.isNotEmpty &&
                    a.id == state.usuarioId,
              ),
            ),
        ],
      ),
    );
  }

  Widget _administradorItem(
    DatumAdministradorEntity admin, {
    required bool esActual,
  }) {
    final activo = admin.estado == "ACTIVO";
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${admin.nombre} ${admin.apellido}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF394354),
                        ),
                      ),
                    ),
                    if (esActual) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tú',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  admin.email,
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activo
                  ? Colors.green.withValues(alpha: .10)
                  : Colors.grey.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              admin.estado,
              style: TextStyle(
                color: activo ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
