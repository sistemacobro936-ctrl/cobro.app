import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/clientes/cubit/cliente_cubit.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/client_card_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/filter_client_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/header_cliente_view.dart';
import 'package:personal/src/ui/admin/pages/clientes/views/search_cliente_view.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClienteCubit, ClienteState>(
      builder: (context, state) {
        final c = context.read<ClienteCubit>();
        final clientes = state.clientes ?? [];
        final buscando = state.busqueda.isNotEmpty;
        final cargando = state.search || state.loadingLista;

        final total = buscando
            ? clientes.length
            : state.paginationClientes?.total ?? clientes.length;

        return Column(
          children: [
            HeaderClienteView(),

            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // Al acercarse al final se pide la siguiente página
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    c.cargarMas();
                  }
                  return false;
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  children: [
                    SearchClienteView(
                      controller: c.busquedaController,
                      onSearch: c.buscar,
                      onClear: c.limpiarBusqueda,
                    ),

                    const SizedBox(height: 14),

                    _rutas(state, c),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            buscando
                                ? '$total ${total == 1 ? 'resultado' : 'resultados'} para "${state.busqueda}"'
                                : '$total ${total == 1 ? 'cliente' : 'clientes'}',
                            style: const TextStyle(
                              color: Color(0xFF929BAB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (buscando)
                          TextButton.icon(
                            onPressed: c.limpiarBusqueda,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Limpiar búsqueda'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
 
                      ],
                    ),

                    if (cargando)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (clientes.isEmpty)
                      _vacio(buscando)
                    else
                      ...clientes.map(
                        (cl) => Container(
                          margin: const EdgeInsets.only(top: 14),
                          child: ClientCardView(
                            id: cl.id,
                            initials:
                                '${cl.nombres.substring(0, 1).toUpperCase()}${cl.apellidos.substring(0, 1).toUpperCase()}',
                            name: cl.nombres,
                            document: 'CC ${cl.cedula}',
                            route: _nombreRuta(state.rutas, cl.rutaId),
                            phone: cl.telefono,
                            balance: '\$${cl.totalPrestado}',
                            active: true,
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
          ],
        );
      },
    );
  }

  // ============================================================
  // RUTAS
  // ============================================================

  /// Chips para elegir la ruta cuyos clientes se listan
  Widget _rutas(ClienteState state, ClienteCubit c) {
    final rutas = state.rutas ?? [];

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'Todos',
            icon: Icons.groups_outlined,
            selected: state.filtroRutaId == '',
            onTap: () => c.seleccionarRuta(''),
          ),
          ...rutas.map(
            (r) => _chip(
              label: r.nombre,
              icon: Icons.route_outlined,
              selected: state.filtroRutaId == r.id,
              onTap: () => c.seleccionarRuta(r.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : const Color(0xFF687386),
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
      ),
    );
  }

  Widget _vacio(bool buscando) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            buscando ? Icons.search_off_rounded : Icons.people_outline_rounded,
            size: 44,
            color: const Color(0xFFB0B6C0),
          ),
          const SizedBox(height: 10),
          Text(
            buscando
                ? 'Ningún cliente coincide con la búsqueda.'
                : 'No hay clientes en esta ruta.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF929BAB)),
          ),
        ],
      ),
    );
  }

  String _nombreRuta(List<DatumREntity>? rutas, String rutaId) {
    if (rutaId.isEmpty) return 'Sin asignación';
    for (final r in rutas ?? <DatumREntity>[]) {
      if (r.id == rutaId) return r.nombre;
    }
    return 'Ruta desconocida';
  }
}
