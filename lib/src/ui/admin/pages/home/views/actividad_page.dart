import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/actividad_cubit.dart';
import 'package:personal/src/ui/admin/pages/home/views/actividad_item.dart';

/// "Ver todo" de la actividad del día, paginado y filtrable por tipo
class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  static const _filtros = <(String, TipoActividad?)>[
    ('Todos', null),
    ('Pagos', TipoActividad.pago),
    ('No pagaron', TipoActividad.noPago),
    ('Préstamos', TipoActividad.prestamo),
    ('Gastos', TipoActividad.gasto),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActividadCubit(),
      child: BlocBuilder<ActividadCubit, ActividadState>(
        builder: (context, state) {
          final cubit = context.read<ActividadCubit>();

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
                'Actividad de hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: _filtros.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final (label, tipo) = _filtros[i];
                      final selected = state.tipo == tipo;
                      return ChoiceChip(
                        label: Text(label),
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
                        onSelected: (_) => cubit.onTipo(tipo),
                      );
                    },
                  ),
                ),
                Expanded(child: _body(context, state, cubit)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, ActividadState state, ActividadCubit c) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.error) {
      return _mensaje(
        icon: Icons.cloud_off_rounded,
        texto: 'No se pudo cargar la actividad.',
        accion: TextButton(onPressed: c.cargar, child: const Text('Reintentar')),
      );
    }

    if (state.items.isEmpty) {
      return _mensaje(
        icon: Icons.inbox_outlined,
        texto: 'Sin actividad para mostrar.',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // Al acercarse al final se pide la siguiente página
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          c.cargarMas();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: c.cargar,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.items.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const Divider(height: 24),
          itemBuilder: (_, i) {
            if (i >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return ActividadItem(actividad: state.items[i]);
          },
        ),
      ),
    );
  }

  Widget _mensaje({
    required IconData icon,
    required String texto,
    Widget? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: const Color(0xFFB0B6C0)),
            const SizedBox(height: 10),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF929BAB), fontSize: 14),
            ),
            ?accion,
          ],
        ),
      ),
    );
  }
}
