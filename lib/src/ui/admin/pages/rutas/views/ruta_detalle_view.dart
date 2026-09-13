import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_home.dart';
import 'package:personal/src/ui/admin/views/detalle_cliente_view.dart';
import 'package:personal/src/ui/admin/views/form_client_view.dart';

class RutaDetalleView extends StatefulWidget {
  final DatumREntity ruta;
  const RutaDetalleView({super.key, required this.ruta});

  @override
  State<RutaDetalleView> createState() => _RutaDetalleViewState();
}

class _RutaDetalleViewState extends State<RutaDetalleView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        final c = context.read<RutaCubit>();
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  c.onEventChild(
                    Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          onPressed: () {
                            c.onEventChild(RutaHome());
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                        title: Text(
                          "Nuevo cliente",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      body: FormClientView(
                        action: (e) {
                          c.crearCliente(e);
                        },
                        onBack: () {
                          c.onEventChild(RutaHome());
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white),
              ),
            ],
            leading: IconButton(
              onPressed: () {
                c.onEventChild(const RutaHome());
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            title: const Text(
              'Detalle de ruta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: BlocBuilder<RutaCubit, RutaState>(
            builder: (context, state) {
              final clientes = state.clientes ?? [];

              return Column(
                children: [
                  _header(),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 20,
                          color: Color(0xFF202838),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Clientes de la ruta',
                          style: TextStyle(
                            color: Color(0xFF202838),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${clientes.length}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : clientes.isEmpty
                      ? _emptyClients()
                      : Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            itemCount: clientes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cliente = clientes[index];

                              return _clienteCard(cliente);
                            },
                          ),
                        ),
                  Visibility(
                    visible:
                        !state.loading && state.paginationClientes!.hasNextPage,
                    child: TextButton(
                      onPressed: () {
                        c.clienteRuta(
                          idRuta: widget.ruta.id,
                          page: state.pageClientes + 1,
                        );
                      },
                      child: Text("Cargar mas clientes"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _header() {
    return BlocBuilder<RutaCubit, RutaState>(
      builder: (context, state) {
        final movimiento = state.movimiento!;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 18, 10, 0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: .80),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // ─────────────────────────────────────────────
              // ENCABEZADO DE LA RUTA
              // ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ruta.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.ruta.descripcion.isEmpty
                              ? 'Sin descripción'
                              : widget.ruta.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .85),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ─────────────────────────────────────────────
              // CAPITAL / PRESTADO / DISPONIBLE
              // ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _headerInfo(
                      title: 'Capital',
                      value: '\$${movimiento.capital}',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: .15),
                  ),

                  Expanded(
                    child: _headerInfo(
                      title: 'Prestado',
                      value: '\$${movimiento.totalPrestado}',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: .15),
                  ),

                  Expanded(
                    child: _headerInfo(
                      title: 'Disponible',
                      value: '\$${movimiento.disponible}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Divider(height: 1, color: Colors.white.withValues(alpha: .15)),

              const SizedBox(height: 14),

              // ─────────────────────────────────────────────
              // INFORMACIÓN DEL MOVIMIENTO
              // ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _headerInfo(
                      title: 'Préstamos',
                      value: '${movimiento.totalPrestamos}',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withValues(alpha: .15),
                  ),

                  Expanded(
                    child: _headerInfo(
                      title: 'Ganancia',
                      value: '\$${movimiento.gananciaEsperada}',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withValues(alpha: .15),
                  ),

                  Expanded(
                    child: _headerInfo(
                      title: 'Seguros',
                      value: '\$${movimiento.totalSeguro}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ─────────────────────────────────────────────
              // COBRADOR / CLIENTES
              // ─────────────────────────────────────────────
              Divider(height: 1, color: Colors.white.withValues(alpha: .15)),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _headerInfo(
                      title: 'Cobrador',
                      value: widget.ruta.cobrador?.nombre ?? 'Sin asignación',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withValues(alpha: .15),
                  ),

                  Expanded(
                    child: _headerInfo(
                      title: 'Clientes',
                      value: '${widget.ruta.cantidadClientes}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerInfo({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clienteCard(DatumClEntity c) {
    final cliente = c;
    final nombre = '${cliente.nombres} ${cliente.apellidos}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primaryColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? 'Sin nombre' : nombre,
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'CC ${cliente.cedula}',
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),

                const SizedBox(height: 2),
                Text(
                  cliente.telefono,
                  style: const TextStyle(color: Color(0xFF929BAB)),
                ),
              ],
            ),
          ),
          BlocBuilder<RutaCubit, RutaState>(
            builder: (context, state) {
              final c = context.read<RutaCubit>();
              return IconButton(
                onPressed: () {
                  c.onEventChild(
                    DetalleClienteView(
                      cliente: cliente,
                      onBack: () {
                        c.onEventChild(RutaHome());
                      },
                      onEdit: () {},
                      showEdit: false,
                    ),
                  );
                },
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB3B9C3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyClients() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 38,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No hay clientes asociados',
              style: TextStyle(
                color: Color(0xFF202838),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Esta ruta todavía no tiene clientes asignados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF929BAB), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
