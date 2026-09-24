import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/prestamo_entity.dart';
import 'package:personal/src/ui/cobrador/cubit/cobrador_cubit.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';
import 'package:personal/src/ui/widgets/input_widget.dart';

class CrearPrestamoCobradorView extends StatelessWidget {
  const CrearPrestamoCobradorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
            title: const Text(
              'Nuevo préstamo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buscadorCedula(),

                const SizedBox(height: 16),

                if (state.buscoAlgunaVez &&
                    !state.buscando &&
                    state.cliente == null)
                  _clienteNoEncontrado(),

                if (state.cliente != null) ...[
                  _clienteEncontrado(c, state.cliente!),
                  const SizedBox(height: 24),
                  _FormularioPrestamo(cliente: state.cliente!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  Widget _buscadorCedula() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar cliente',
              style: TextStyle(
                color: Color(0xFF202838),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ingresa la cédula del cliente al que le vas a asignar el préstamo.',
              style: TextStyle(color: Color(0xFF929BAB), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InputWidget.input(
                    label: 'Número de cédula',
                    hintText: 'Ej: 1002345678',
                    prefixIcon: Icons.badge_outlined,
                    controller: c.cedulaController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    enabled: !state.buscando,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state.buscando ? null : c.buscarCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: state.buscando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
            if (state.cliente != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: c.limpiarBusqueda,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Buscar otro cliente'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _clienteNoEncontrado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: const Column(
        children: [
          Icon(Icons.person_off_outlined, size: 34, color: Color(0xFFB0B6C0)),
          SizedBox(height: 8),
          Text(
            'No se encontró un cliente con esa cédula.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF929BAB)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Cliente encontrado: datos básicos + resumen de préstamos existentes
  // (con la ruta de cada uno), como advertencia antes de crear el nuevo.
  // ============================================================
  Widget _clienteEncontrado(CobradorRCubit c, DatumClEntity cliente) {
    final prestamos = cliente.prestamos ?? <DatumPEntity>[];
    final activos = prestamos.where((p) => p.estado == 'ACTIVO').toList();

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF4164E8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cliente.nombres} ${cliente.apellidos}',
                      style: const TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC ${cliente.cedula} ',
                      style: const TextStyle(
                        color: Color(0xFF929BAB),
                     
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (activos.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'No tiene préstamos activos.',
              style: TextStyle(color: Color(0xFF929BAB), fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5C26B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFFB7791F),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activos.length == 1
                              ? 'Ya tiene 1 préstamo activo'
                              : 'Ya tiene ${activos.length} préstamos activos',
                          style: const TextStyle(
                            color: Color(0xFF8A5A0B),
                          
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...activos.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Ruta: ${c.nombreRuta(cliente.rutaId)} \n'
                        'Debe ${MoneyUtil.format(p.deudaActual)} \n'
                        'Cuota ${MoneyUtil.format(p.valorCuota)}',
                        style: const TextStyle(
                          color: Color(0xFF6B4A16),
                         
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// FORMULARIO DEL PRÉSTAMO
// ══════════════════════════════════════════════════════════════════════════

class _FormularioPrestamo extends StatefulWidget {
  const _FormularioPrestamo({required this.cliente});
  final DatumClEntity cliente;

  @override
  State<_FormularioPrestamo> createState() => _FormularioPrestamoState();
}

class _FormularioPrestamoState extends State<_FormularioPrestamo> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();

        final monto = int.tryParse(c.montoController.text) ?? 0;
        final interesPct = int.tryParse(c.interesController.text) ?? 0;
        final seguro = c.valorSeguro;
        final interesMonto = (monto * interesPct / 100).toInt();
        final total = monto + interesMonto;
        final cuotas = c.numeroCuotas;
        final valorCuota = cuotas > 0 ? (total / cuotas).toInt() : 0;

        final canCreate =
            monto > 0 &&
            valorCuota > 0 &&
            state.periodoSeleccionado != null &&
            state.fechaFinal != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos del préstamo',
              style: TextStyle(
                color: Color(0xFF202838),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),

            InputWidget.input(
              label: 'Monto inicial',
              hintText: 'Ej: 100000',
              prefixIcon: Icons.attach_money_rounded,
              controller: c.montoController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            InputWidget.input(
              label: 'Interés (%)',
              hintText: '20',
              prefixIcon: Icons.percent_rounded,
              controller: c.interesController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            _seguro(),
            const SizedBox(height: 20),

            const Text(
              'Frecuencia de cobro',
              style: TextStyle(
                
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _frecuencia(),
            const SizedBox(height: 16),

            InputWidget.input(
              label: 'Número de cuotas',
              prefixIcon: Icons.repeat_rounded,
              controller: c.cuotasController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                c.fechaFinal();
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            _fechaInicio(context),
            const SizedBox(height: 24),

            _resumen(
              monto: monto,
              interesMonto: interesMonto,
              seguro: seguro,
              total: total,
              cuotas: cuotas,
              valorCuota: valorCuota,
              fechaFinal: state.fechaFinal,
            ),
            const SizedBox(height: 24),

            BtnWidget.btn(
              text: 'Crear préstamo',
              icon: Icons.check_rounded,
              loading: state.loadingBtn,
              enabled: canCreate,
              onPressed: canCreate ? c.crearPrestamo : null,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ],
        );
      },
    );
  }

  Widget _seguro() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: .05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Switch(
                    value: state.aplicaSeguro,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (v) {
                      c.onAplicaSeguro(v);
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Aplicar seguro',
                      style: TextStyle(
                        color: Color(0xFF202838),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.aplicaSeguro) ...[
                const SizedBox(height: 8),
                Column(
                  children: [
                     InputWidget.input(
                        label: 'Seguro (%)',
                        controller: c.seguroController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          c.recalcularSeguro();
                          setState(() {});
                        },
                      ),
                    
                    const SizedBox(height: 10),
                    InputWidget.input(
                        label: 'Valor del seguro',
                        controller: c.seguroValorController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _frecuencia() {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        final c = context.read<CobradorRCubit>();
        if (state.loadingConfig) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: state.periodos.map((p) {
              final selected = state.periodoSeleccionado?.id == p.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.nombre),
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
                  onSelected: (_) {
                    c.onGetPeriodo(p);
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _fechaInicio(BuildContext context) {
    return BlocBuilder<CobradorRCubit, CobradorRState>(
      builder: (context, state) {
        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: .05)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha inicial',
                        style: TextStyle(
                        
                          
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateUtil.formatLectura(state.fechaInicial!),
                        style: const TextStyle(
                          color: Color(0xFF202838),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
               
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resumen({
    required int monto,
    required int interesMonto,
    required int seguro,
    required int total,
    required int cuotas,
    required int valorCuota,
    required DateTime? fechaFinal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          _fila('Monto', MoneyUtil.format(monto)),
          _fila('Interés', MoneyUtil.format(interesMonto)),
          _fila('Seguro', MoneyUtil.format(seguro)),
          const Divider(),
          _fila(
            'Total a pagar',
            MoneyUtil.format(total),
            destacado: true,
          ),
          _fila('Cuotas', '$cuotas'),
          _fila('Valor cuota', MoneyUtil.format(valorCuota)),
          _fila(
            'Fecha final',
            fechaFinal == null ? '-' : DateUtil.formatLectura(fechaFinal),
          ),
        ],
      ),
    );
  }

  Widget _fila(String label, String value, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: destacado
                  ? const Color(0xFF202838)
                  : const Color(0xFF929BAB),
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF202838),
              fontWeight: destacado ? FontWeight.w800 : FontWeight.w600,
              
            ),
          ),
        ],
      ),
    );
  }
}
