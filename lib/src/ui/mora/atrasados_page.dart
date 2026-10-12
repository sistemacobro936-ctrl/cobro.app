import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/ui/mora/cubit/atrasados_cubit.dart';
import 'package:personal/src/ui/mora/mora_widgets.dart';

/// Clientes con préstamos vencidos, del más atrasado al menos, filtrables
/// por nivel de atraso o por clientes CLAVO
class AtrasadosPage extends StatelessWidget {
  const AtrasadosPage({super.key, this.nivel, this.soloClavos = false});

  final int? nivel;
  final bool soloClavos;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AtrasadosCubit(context, nivel: nivel, soloClavos: soloClavos),
      child: BlocBuilder<AtrasadosCubit, AtrasadosState>(
        builder: (context, state) {
          final c = context.read<AtrasadosCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FC),
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Clientes atrasados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  c.cargarMas();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: c.cargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  children: [
                    _filtros(state, c),
                    const SizedBox(height: 10),
                    if (state.pagination != null)
                      Text(
                        '${state.pagination!.total} '
                        '${state.pagination!.total == 1 ? 'préstamo vencido' : 'préstamos vencidos'}',
                        style: const TextStyle(
                          color: Color(0xFF929BAB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (state.atrasados.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Column(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 44,
                              color: Color(0xFFB0B6C0),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No hay clientes atrasados con este filtro.',
                              style: TextStyle(color: Color(0xFF929BAB)),
                            ),
                          ],
                        ),
                      )
                    else
                      ...state.atrasados.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AtrasadoTile(
                            atrasado: a,
                            onCambiarEstado: (nuevo) async {
                              final ok = await cambiarEstadoCliente(
                                context,
                                clienteId: a.clienteId,
                                nombre: '${a.nombres} ${a.apellidos}',
                                estadoActual: a.estadoCliente,
                                nuevoEstado: nuevo,
                              );
                              if (ok) c.cargar();
                            },
                          ),
                        ),
                      ),
                    if (state.loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filtros(AtrasadosState state, AtrasadosCubit c) {
    final niveles = state.resumen?.niveles ?? const <NivelMoraEntity>[];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'Todos (${state.resumen?.total ?? 0})',
            selected: state.nivel == null && !state.soloClavos,
            onTap: () => c.seleccionarNivel(null),
          ),
          for (final n in niveles)
            _chip(
              label: '${n.etiqueta} (${n.cantidad})',
              color: n.color,
              tooltip: '${n.textoDias} · ${MoneyUtil.format(n.saldo)}',
              selected: state.nivel == n.indice && !state.soloClavos,
              onTap: () => c.seleccionarNivel(n.indice),
            ),
          _chip(
            label: 'Clavos (${state.resumen?.clavos ?? 0})',
            color: colorClavo,
            selected: state.soloClavos,
            onTap: c.verClavos,
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
    String? tooltip,
  }) {
    final chip = ChoiceChip(
      avatar: color == null
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.black.withValues(alpha: .05)),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF394354),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (_) => onTap(),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: tooltip == null ? chip : Tooltip(message: tooltip, child: chip),
    );
  }
}
