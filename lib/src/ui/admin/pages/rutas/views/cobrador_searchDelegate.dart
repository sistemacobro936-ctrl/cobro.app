import 'package:flutter/material.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';

class CobradorSearchDelegate extends SearchDelegate<DatumCEntity?> {
  final List<DatumCEntity> cobradores;

  CobradorSearchDelegate(this.cobradores);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final texto = query.trim().toLowerCase();

    final resultados = cobradores.where((cobrador) {
      final nombre = '${cobrador.nombre} ${cobrador.apellido}'.toLowerCase();

      final documento = cobrador.documento.toLowerCase();

      final telefono = cobrador.telefono.toLowerCase();

      return texto.isEmpty ||
          nombre.contains(texto) ||
          documento.contains(texto) ||
          telefono.contains(texto);
    }).toList();

    if (resultados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron cobradores',
          style: TextStyle(color: Color(0xFF929BAB), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: resultados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cobrador = resultados[index];

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            close(context, cobrador);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: .06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF4164E8),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cobrador.nombre} ${cobrador.apellido}',
                        style: const TextStyle(
                          color: Color(0xFF202838),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'CC ${cobrador.documento}',
                        style: const TextStyle(
                          color: Color(0xFF929BAB),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        cobrador.telefono,
                        style: const TextStyle(
                          color: Color(0xFF929BAB),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A93A3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
