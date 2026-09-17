import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/reporte_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/contabilidad/cubit/contabilidad_cubit.dart';

class ContabilidadPage extends StatefulWidget {
  const ContabilidadPage({super.key});

  @override
  State<ContabilidadPage> createState() => _ContabilidadPageState();
}

class _ContabilidadPageState extends State<ContabilidadPage> {
  late ContabilidadCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ContabilidadCubit(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => _cubit,
        child: BlocBuilder<ContabilidadCubit, ContabilidadState>(
          builder: (context, state) {
            final ResumenReporteEntity? reporte = state.rutaSeleccionada == null
                ? state.totales
                : state.cajaRuta;

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
                  'Contabilidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async => _cubit.cargarReporte(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFecha(context, state),
                      const SizedBox(height: 12),
                      _buildRuta(context, state),
                      const SizedBox(height: 12),

                      if (state.loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      else if (reporte == null)
                        _buildSinDatos()
                      else ...[
                        _buildSeccion(
                          titulo: 'Operación',
                          icono: Icons.receipt_long_outlined,
                          children: [
                            _dato('Total boletas', reporte.totalBoletas.toString()),
                            _dato('Cantidad recibida', _money(reporte.cantidadRecibida)),
                            _dato('Cantidad de abonos', reporte.cantidadAbonos.toString()),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _buildSeccion(
                          titulo: 'Préstamos',
                          icono: Icons.account_balance_wallet_outlined,
                          children: [
                            _dato('Préstamos', _money(reporte.cantidadPrestada)),
                            _dato('Cantidad de préstamos', reporte.cantidadPrestamos.toString()),
                            _dato('Seguro', _money(reporte.seguro)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _buildSeccion(
                          titulo: 'Cobro',
                          icono: Icons.payments_outlined,
                          children: [
                            _dato('Esperado a cobrar', _money(reporte.esperadoACobrar)),
                            _dato('Recibido', _money(reporte.cantidadRecibida)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _buildSeccion(
                          titulo: 'Caja',
                          icono: Icons.point_of_sale_outlined,
                          children: [
                            _dato('Gastos', _money(reporte.gastos)),
                            _dato('Inyección de capital', _money(reporte.inyeccionCapital)),
                            _dato('Base', _money(reporte.base)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _buildResultado(reporte),

                        const SizedBox(height: 12),

                        _buildArqueo(reporte),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSinDatos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Colors.grey.withValues(alpha: .5),
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay información de caja para la fecha y ruta seleccionadas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF929BAB), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202838),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
          const Divider(),
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 14, color: Color(0xFF929BAB)),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF394354),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado(ResumenReporteEntity reporte) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202838),
            ),
          ),
          const SizedBox(height: 16),
          _dato('Utilidad', _money(reporte.utilidad)),
          _dato('Retiro de seguro', _money(reporte.retiroSeguro)),
        ],
      ),
    );
  }

  Widget _buildArqueo(ResumenReporteEntity reporte) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arqueo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202838),
            ),
          ),
          const SizedBox(height: 16),
          _dato(
            'Efectivo recibido',
            reporte.efectivoRecibido == null
                ? 'Pendiente'
                : _money(reporte.efectivoRecibido!),
          ),
          _dato('Diferencia', _diferencia(reporte.diferencia)),
        ],
      ),
    );
  }

  Widget _buildFecha(BuildContext context, ContabilidadState state) {
    return InkWell(
      onTap: () => _seleccionarFecha(context, state),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: .05)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF929BAB),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy', 'es_CO').format(state.fecha),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF394354),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF8A93A3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuta(BuildContext context, ContabilidadState state) =>
      DropdownButtonFormField<DatumREntity?>(
        initialValue: state.rutaSeleccionada,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Seleccione una ruta',
          prefixIcon: const Icon(Icons.route_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: .15)),
          ),
        ),
        items: [
          const DropdownMenuItem<DatumREntity?>(
            value: null,
            child: Text('Todas las rutas'),
          ),
          ...state.rutas.map((ruta) {
            return DropdownMenuItem<DatumREntity?>(
              value: ruta,
              child: Text(ruta.nombre, overflow: TextOverflow.ellipsis),
            );
          }),
        ],
        onChanged: (ruta) => _cubit.seleccionarRuta(ruta),
      );

  Future<void> _seleccionarFecha(
    BuildContext context,
    ContabilidadState state,
  ) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: state.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    _cubit.seleccionarFecha(fecha);
  }

  String _money(int valor) =>
      '\$${NumberFormat('#,##0', 'es_CO').format(valor)}';

  String _diferencia(int? diferencia) {
    if (diferencia == null) return 'Pendiente';
    if (diferencia == 0) return '\$0';
    final signo = diferencia < 0 ? '-' : '+';
    return '$signo${_money(diferencia.abs())}';
  }
}
