import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/ruta_entity.dart';
import 'package:personal/src/ui/admin/pages/rutas/cubit/ruta_cubit.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/crear_ruta_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_detalle_view.dart';
import 'package:personal/src/ui/admin/pages/rutas/views/ruta_home.dart';
import 'package:personal/src/ui/admin/views/form_client_view.dart';

class RutaPage extends StatefulWidget {
  final bool showDetail;
  final DatumREntity? ruta;
  const RutaPage({super.key, this.showDetail = false, this.ruta});

  @override
  State<RutaPage> createState() => _RutaPageState();
}

class _RutaPageState extends State<RutaPage> {
  late RutaCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = RutaCubit(context: context);
    _cubit.listarRutas();
    if (widget.showDetail) {
      _cubit.onEventChild(RutaDetalleView(ruta: widget.ruta!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: SafeArea(
        child: BlocBuilder<RutaCubit, RutaState>(
          builder: (context, state) {
            final c = context.read<RutaCubit>();
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FC),

              floatingActionButton: Visibility(
                visible:
                    state.child is RutaHome ,
                child: FloatingActionButton.extended(
                  onPressed: () {
                   
                    c.clear();
                    c.onEventChild(CrearRutaView());
                  },
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    state.child is RutaDetalleView
                        ? "Agregar cliente"
                        : 'Nueva ruta',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              body: state.loading
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : state.child,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================
