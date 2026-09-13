import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/ui/admin/pages/config/cubit/config_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late ConfigCubit _configCubit;
  @override
  void initState() {
    super.initState();
    _configCubit = ConfigCubit(context: context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => _configCubit,
        child: BlocBuilder<ConfigCubit, ConfigState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FC),

              appBar: AppBar(
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,

                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),

                title: const Text(
                  'Configuración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              body: state.loading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(),

                          const SizedBox(height: 24),

                          // ==================================================
                          // DÍAS
                          // ==================================================
                          _sectionTitle(
                            icon: Icons.event_available_outlined,
                            title: 'Días de cobro',
                          ),

                          const SizedBox(height: 12),

                          _daysCard(),

                          const SizedBox(height: 28),

                          // ==================================================
                          // INTERESES
                          // ==================================================
                          _sectionTitle(
                            icon: Icons.percent_rounded,
                            title: 'Intereses',
                          ),

                          const SizedBox(height: 12),

                          _interestCard(),

                          const SizedBox(height: 28),

                          // ==================================================
                          // PERIODOS
                          // ==================================================
                          _sectionTitle(
                            icon: Icons.event_repeat_outlined,
                            title: 'Periodos de cobro',
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Configure las modalidades disponibles para los préstamos.',
                            style: TextStyle(color: Color(0xFF929BAB)),
                          ),

                          const SizedBox(height: 12),

                          ...state.config!.periodosCobro.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _periodCard(entry),
                            );
                          }),

                          const SizedBox(height: 20),

                          // ==================================================
                          // GUARDAR
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: BtnWidget.btn(
                              text: 'Guardar configuración',
                              icon: Icons.check_rounded,
                              onPressed: (){
                                _configCubit.actualizarConfiguracion();
                              },
                              enabled: true,
                              loading: state.loadingBtn,
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
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
          Icon(Icons.settings_outlined, color: Colors.white, size: 30),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reglas de préstamos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Estas reglas serán utilizadas al crear nuevos préstamos.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

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

  // ============================================================
  // DÍAS
  // ============================================================

  Widget _daysCard() {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, state) {
        final days = state.config!.diasCobro;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccione los días en los que se pueden realizar cobros.',
                style: TextStyle(color: Color(0xFF687386)),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...days.map(
                    (e) => GestureDetector(
                      onTap: () {
                        _configCubit.enabledDisabledDay(e);
                      },
                      child: _dayButton(
                        day: e.nombre.substring(0, 1).toUpperCase(),
                        name: e.nombre,
                        enabled: e.habilitado,
                      ),
                    ),
                  ),
                ],
                // children: [
                //   _dayButton(day: 'L', name: 'Lunes', value: DateTime.monday),
                //   _dayButton(day: 'M', name: 'Martes', value: DateTime.tuesday),
                //   _dayButton(
                //     day: 'X',
                //     name: 'Miércoles',
                //     value: DateTime.wednesday,
                //   ),
                //   _dayButton(day: 'J', name: 'Jueves', value: DateTime.thursday),
                //   _dayButton(day: 'V', name: 'Viernes', value: DateTime.friday),
                //   _dayButton(day: 'S', name: 'Sábado', value: DateTime.saturday),
                //   _dayButton(day: 'D', name: 'Domingo', value: DateTime.sunday),
                // ],
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FC),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF687386),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        _daysDescription(days),
                        style: const TextStyle(
                          color: Color(0xFF687386),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dayButton({
    required String day,
    required String name,
    required bool enabled,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 37,
          height: 37,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppTheme.primaryColor : const Color(0xFFF0F2F5),
            shape: BoxShape.circle,
          ),
          child: Text(
            day,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFFA0A7B3),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          name.substring(0, 3),
          style: const TextStyle(color: Color(0xFF929BAB), fontSize: 8),
        ),
      ],
    );
  }

  String _daysDescription(List<SCobroEntity> days) {
    final selected = days.where((entry) => entry.habilitado).length;

    return '$selected días habilitados para realizar cobros.';
  }

  // ============================================================
  // INTERESES
  // ============================================================

  Widget _interestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InputWidget.input(
            label: 'Interés del préstamo',
            hintText: 'Ej: 20',
            prefixIcon: Icons.percent_rounded,
            controller: _configCubit.interesCtrl,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          InputWidget.input(
            label: 'Interés del seguro',
            hintText: 'Ej: 10',
            prefixIcon: Icons.shield_outlined,
            controller: _configCubit.seguroCtrol,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FC),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF687386),
                ),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Estos porcentajes se utilizarán como valores predeterminados al crear un nuevo préstamo.',
                    style: TextStyle(color: Color(0xFF687386), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _periodCard(SCobroEntity periodo) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodo.nombre,
                  style: const TextStyle(
                    color: Color(0xFF202838),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${periodo.cantidadDias} ${periodo.cantidadDias == 1 ? 'día' : 'días'} por periodo',
                  style: const TextStyle(
                    color: Color(0xFF929BAB),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Duración editable
          Container(
            width: 62,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              initialValue: periodo.cantidadDias.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixText: 'd',
                suffixStyle: TextStyle(fontSize: 10, color: Color(0xFF929BAB)),
              ),
              onChanged: (value) {
                final dias = int.tryParse(value);

                if (dias != null && dias > 0) {
                  _configCubit.updateDaysPeriod(periodo, dias);
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          Switch.adaptive(
            value: periodo.habilitado,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) {
              // periodo.habilitado = value;
              _configCubit.enabledDisabledPeriod(periodo);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DECORACIÓN
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.black.withValues(alpha: .05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }


}

class PeriodoCobro {
  String nombre;
  int dias;
  final IconData icon;
  bool habilitado;

  PeriodoCobro({
    required this.nombre,
    required this.dias,
    required this.icon,
    required this.habilitado,
  });
}
