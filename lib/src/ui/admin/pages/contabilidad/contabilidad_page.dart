import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';

class ContabilidadPage extends StatefulWidget {
  const ContabilidadPage({super.key});

  @override
  State<ContabilidadPage> createState() => _ContabilidadPageState();
}

class _ContabilidadPageState extends State<ContabilidadPage> {
  DateTime _fechaSeleccionada = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFecha(),
              const SizedBox(height: 12),
              _buildRuta(),
              const SizedBox(height: 12),

              _buildSeccion(
                titulo: 'Operación',
                icono: Icons.receipt_long_outlined,
                children: [
                  _dato('Total boletas', '125'),
                  _dato('Cantidad recibida', '\$850.000'),
                  _dato('Cantidad de abonos', '42'),
                ],
              ),

              const SizedBox(height: 12),

              _buildSeccion(
                titulo: 'Préstamos',
                icono: Icons.account_balance_wallet_outlined,
                children: [
                  _dato('Préstamos', '\$600.000'),
                  _dato('Cantidad de préstamos', '8'),
                  _dato('Seguro', '\$30.000'),
                ],
              ),

              const SizedBox(height: 12),

              _buildSeccion(
                titulo: 'Cobro',
                icono: Icons.payments_outlined,
                children: [
                  _dato('Esperado a cobrar', '\$720.000'),
                  _dato('Recibido', '\$850.000'),
                ],
              ),

              const SizedBox(height: 12),

              _buildSeccion(
                titulo: 'Caja',
                icono: Icons.point_of_sale_outlined,
                children: [
                  _dato('Gastos', '\$50.000'),
                  _dato('Inyección de capital', '\$100.000'),
                  _dato('Base', '\$200.000'),
                ],
              ),

              const SizedBox(height: 12),

              _buildResultado(),

              const SizedBox(height: 12),

              _buildArqueo(),
            ],
          ),
        ),
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
          Divider(),
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

  Widget _buildResultado() {
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
          _dato('Utilidad', '\$200.000'),
          _dato('Retiro de seguro', '\$30.000'),
        ],
      ),
    );
  }

  Widget _buildArqueo() {
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
          _dato('Efectivo recibido', '\$820.000'),
          _dato('Diferencia', '-\$30.000'),
        ],
      ),
    );
  }

  Widget _buildFecha() {
    return InkWell(
      onTap: _seleccionarFecha,
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
                DateFormat('dd/MM/yyyy', 'es_CO').format(_fechaSeleccionada),
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

  Widget _buildRuta() => DropdownButtonFormField<DatumREntity>(
    // initialValue: ,
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
    items: Shared.getRutas!.map((ruta) {
      return DropdownMenuItem<DatumREntity>(
        value: ruta,
        child: Text(ruta.nombre, overflow: TextOverflow.ellipsis),
      );
    }).toList(),
    onChanged: (e) {},
  );

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    setState(() {
      _fechaSeleccionada = fecha;
    });
  }
}
