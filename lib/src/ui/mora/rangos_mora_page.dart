import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/ui/mora/cubit/rangos_mora_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Configuración › Rangos de mora: tramos de días de atraso con su color
class RangosMoraPage extends StatelessWidget {
  const RangosMoraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RangosMoraCubit(context),
      child: BlocBuilder<RangosMoraCubit, RangosMoraState>(
        builder: (context, state) {
          final c = context.read<RangosMoraCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FC),
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Rangos de mora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: state.loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                    children: [
                      _encabezado(),
                      const SizedBox(height: 22),
                      for (var i = 0; i < state.filas.length; i++) ...[
                        _FilaRangoView(
                          key: ValueKey(state.filas[i].key),
                          numero: i + 1,
                          fila: state.filas[i],
                          desde: c.desde(i),
                          ultima: i == state.filas.length - 1,
                          puedeQuitar: state.filas.length > 1,
                          cubit: c,
                        ),
                        const SizedBox(height: 14),
                      ],
                      OutlinedButton.icon(
                        onPressed: c.agregarRango,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar rango'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(
                            color: AppTheme.primaryColor.withValues(alpha: .4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 54,
                        child: BtnWidget.btn(
                          text: 'Guardar rangos',
                          icon: Icons.check_rounded,
                          loading: state.guardando,
                          onPressed: c.guardar,
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _encabezado() {
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Días de atraso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Un préstamo se atrasa desde el día siguiente a su fecha '
                  'final. Cada rango tiene su nombre y su color.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaRangoView extends StatelessWidget {
  const _FilaRangoView({
    super.key,
    required this.numero,
    required this.fila,
    required this.desde,
    required this.ultima,
    required this.puedeQuitar,
    required this.cubit,
  });

  final int numero;
  final FilaRango fila;
  final int desde;
  final bool ultima;
  final bool puedeQuitar;
  final RangosMoraCubit cubit;

  @override
  Widget build(BuildContext context) {
    final color = colorDesdeHex(fila.colorHex);
    final hasta = fila.hasta;
    final textoDias = ultima
        ? '$desde días o más'
        : hasta == null || desde < 1
        ? 'Desde $desde días'
        : '$desde a $hasta días';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: número con el color del rango, días y quitar
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$numero',
                  style: TextStyle(
                    color: Color.lerp(color, Colors.black, .35),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fila.etiquetaTxt.text.trim().isEmpty
                          ? 'Rango $numero'
                          : fila.etiquetaTxt.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      textoDias,
                      style: const TextStyle(
                        color: Color(0xFF7D8797),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Quitar rango',
                onPressed: puedeQuitar ? () => cubit.quitarRango(fila) : null,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFD64545),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: fila.etiquetaTxt,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => cubit.onCambio(),
            decoration: _decoracion('Nombre', Icons.label_outline_rounded)
                .copyWith(counterText: ''),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: _decoracion('Desde', Icons.first_page_rounded),
                  child: Text(
                    desde < 1 ? '—' : '$desde',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ultima
                    ? InputDecorator(
                        decoration: _decoracion(
                          'Hasta',
                          Icons.all_inclusive_rounded,
                        ),
                        child: const Text(
                          'En adelante',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : TextField(
                        controller: fila.hastaTxt,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => cubit.onCambio(),
                        decoration: _decoracion(
                          'Hasta',
                          Icons.last_page_rounded,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Color',
            style: TextStyle(
              color: Color(0xFF687386),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final hex in coloresMora)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => cubit.cambiarColor(fila, hex),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colorDesdeHex(hex),
                          shape: BoxShape.circle,
                        ),
                        child: fila.colorHex.toUpperCase() == hex
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mismo estilo de los campos de la app (relleno, sin borde)
  InputDecoration _decoracion(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
