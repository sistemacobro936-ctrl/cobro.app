import 'package:flutter/material.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/dto/crear_cliente_dto.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/widgets/btn_widget.dart';
import 'package:personal/src/ui/widgets/input_widget.dart';

class FormClientView extends StatefulWidget {
  final Function(CrearClienteDto dto) action;
  final Function() onBack;
  final bool isEdit;
  final bool loadingBtn;
  final DatumClEntity? cliente;
  const FormClientView({
    super.key,
    required this.action,
    required this.onBack,
    this.isEdit = false,
    this.loadingBtn = false,
    this.cliente,
  });

  @override
  State<FormClientView> createState() => _FormClientViewState();
}

class _FormClientViewState extends State<FormClientView> {
  final nameTxt = TextEditingController();

  final lastNameTxt = TextEditingController();

  final ideTxt = TextEditingController();

  final contactTxt = TextEditingController();

  final whatsappTxt = TextEditingController();

  final directionTxt = TextEditingController();

  final addressDescriptionTxt = TextEditingController();

  final barrioTxt = TextEditingController();

  final observationTxt = TextEditingController();

  bool btnEnabled = false;
  DatumREntity? ruta;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() {
    if (widget.isEdit) {
      final c = widget.cliente!;
      nameTxt.text = c.nombres;
      lastNameTxt.text = c.apellidos;
      ideTxt.text = c.cedula;
      contactTxt.text = c.telefono;
      whatsappTxt.text = c.whatsapp;
      directionTxt.text = c.direccion;
      addressDescriptionTxt.text = c.descripcionDireccion;
      barrioTxt.text = c.barrio;
      observationTxt.text = c.observacion;
      ruta = Shared.getRutas!.firstWhere((e) => e.id == c.rutaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),

          const SizedBox(height: 24),

          _sectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Información personal',
          ),

          const SizedBox(height: 14),

          InputWidget.input(
            label: 'Nombres',
            hintText: 'Ingrese los nombres',
            prefixIcon: Icons.person_outline_rounded,
            controller: nameTxt,

            textInputAction: TextInputAction.next,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 16),

          InputWidget.input(
            label: 'Apellidos',
            hintText: 'Ingrese los apellidos',
            prefixIcon: Icons.person_outline_rounded,
            controller: lastNameTxt,
            textInputAction: TextInputAction.next,
            enabled: !widget.loadingBtn,
            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 16),

          InputWidget.input(
            label: 'Número de cédula',
            hintText: 'Ingrese el número de cédula',
            prefixIcon: Icons.badge_outlined,
            controller: ideTxt,
            keyboardType: TextInputType.number,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 28),

          _sectionTitle(
            icon: Icons.phone_outlined,
            title: 'Información de contacto',
          ),

          const SizedBox(height: 14),

          InputWidget.input(
            label: 'Número de contacto',
            hintText: 'Ej: 300 123 4567',
            prefixIcon: Icons.phone_outlined,
            controller: contactTxt,
            keyboardType: TextInputType.phone,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 16),

          InputWidget.input(
            label: 'Número de WhatsApp',
            hintText: 'Ej: 300 123 4567',
            prefixIcon: Icons.chat_outlined,
            controller: whatsappTxt,
            keyboardType: TextInputType.phone,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 28),

          _sectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Información de dirección',
          ),

          const SizedBox(height: 14),

          InputWidget.input(
            label: 'Dirección',
            hintText: 'Ej: Calle 32 # 14-25',
            prefixIcon: Icons.home_outlined,
            controller: directionTxt,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 16),

          InputWidget.input(
            label: 'Descripción de la dirección',
            hintText: 'Ej: Casa blanca, frente a la tienda...',
            prefixIcon: Icons.description_outlined,
            controller: addressDescriptionTxt,
            maxLines: 3,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 16),

          InputWidget.input(
            label: 'Barrio / Sector',
            hintText: 'Ingrese el barrio o sector',
            prefixIcon: Icons.map_outlined,
            controller: barrioTxt,
            enabled: !widget.loadingBtn,

            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 28),
          const SizedBox(height: 16),

          DropdownButtonFormField<DatumREntity>(
            initialValue: ruta,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Ruta',
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
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: .15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            items: Shared.getRutas!.map((ruta) {
              return DropdownMenuItem<DatumREntity>(
                value: ruta,
                child: Text(ruta.nombre, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: widget.loadingBtn
                ? null
                : (value) {
                    if (value != null) {
                      ruta = value;
                      enabledBtn();
                    }
                  },
          ),
          const SizedBox(height: 28),

          _sectionTitle(
            icon: Icons.notes_rounded,
            title: 'Información adicional',
          ),

          const SizedBox(height: 14),

          InputWidget.input(
            label: 'Descripción',
            enabled: !widget.loadingBtn,
            hintText: 'Agregue alguna observación del cliente...',
            prefixIcon: Icons.notes_rounded,
            controller: observationTxt,
            maxLines: 4,
            onChanged: (value) => enabledBtn(),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: BtnWidget.btn(
              text: widget.isEdit ? "Editar cliente" : 'Crear cliente',
              loading: widget.loadingBtn,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: btnEnabled
                  ? () {
                    
                        widget.action(
                          CrearClienteDto(
                            nombres: nameTxt.text,
                            apellidos: lastNameTxt.text,
                            cedula: ideTxt.text,
                            telefono: contactTxt.text,
                            whatsapp: whatsappTxt.text,
                            direccion: directionTxt.text,
                            descripcionDireccion: addressDescriptionTxt.text,
                            observacion: observationTxt.text,
                            barrio: barrioTxt.text,
                            rutaId: ruta!.id,
                          ),
                        );
                    }
                  : null,
              enabled: btnEnabled,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => widget.onBack(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF687386),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Visibility(
      visible: !widget.isEdit,
      child: Container(
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
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 32),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrar cliente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete la información del nuevo cliente.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202838),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  void enabledBtn() {
    final checkEnabled = [
      nameTxt,
      lastNameTxt,
      ideTxt,
      contactTxt,
      whatsappTxt,
      directionTxt,
      barrioTxt,
      observationTxt,
    ].every((text) => text.text.trim().isNotEmpty);

    btnEnabled = checkEnabled && ruta != null;

    setState(() {});
  }
}
