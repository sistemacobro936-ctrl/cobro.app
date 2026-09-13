import 'package:flutter/material.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';

class ClienteSearchDelegate
    extends SearchDelegate<DatumClEntity?> {

  final List<DatumClEntity> clientes;

  ClienteSearchDelegate(this.clientes);

  @override
  Widget buildResults(BuildContext context) {
    return _buildClientes(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildClientes(context);
  }

  Widget _buildClientes(BuildContext context) {
    final q = query.toLowerCase().trim();

    final resultados = clientes.where((cliente) {
      final nombre =
          '${cliente.nombres} ${cliente.apellidos}'
              .toLowerCase();

      final cedula =
          cliente.cedula.toLowerCase();

      return nombre.contains(q) ||
          cedula.contains(q);
    }).toList();

    if (resultados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron clientes',
        ),
      );
    }

    return ListView.builder(
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        final cliente = resultados[index];

        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(
            '${cliente.nombres} ${cliente.apellidos}',
          ),
          subtitle: Text(
            'C.C. ${cliente.cedula}',
          ),
          onTap: () {
            close(context, cliente);
          },
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}