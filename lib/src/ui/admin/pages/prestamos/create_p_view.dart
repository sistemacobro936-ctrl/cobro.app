import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/domain/entities/cliente_entity.dart';
import 'package:personal/src/domain/entities/config_entity.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cliente_search_delegate.dart';
import 'package:personal/src/ui/admin/pages/prestamos/cubit/prestamo_cubit.dart';
import 'package:personal/src/ui/admin/pages/prestamos/views/prestamos_home.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class CrearPrestamoView extends StatefulWidget {
  const CrearPrestamoView({super.key});

  @override
  State<CrearPrestamoView> createState() => _CrearPrestamoViewState();
}

class _CrearPrestamoViewState extends State<CrearPrestamoView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrestamoCubit, PrestamoState>(
      builder: (context, state) {
        final cubit = context.read<PrestamoCubit>();

        // ── Cálculos centralizados ──────────────────────────────
        final monto = int.tryParse(cubit.montoController.text) ?? 0;
        final interes = int.tryParse(cubit.interesController.text) ?? 0;
        final seguro = cubit.valorSeguro;
        final seguroPct = cubit.seguroController.text;
        final interesMonto = (monto * interes / 100).toInt();
        final total = monto + interesMonto;
        final cuotas = cubit.numeroCuotas;
        final valorCuota = cuotas > 0 ? (total / cuotas).toInt() : 0;
        final seguroLabel = !state.aplicaSeguro
            ? 'Seguro (no aplica)'
            : seguro == (monto * (num.tryParse(seguroPct) ?? 0) / 100).round()
            ? 'Seguro ($seguroPct%)'
            : 'Seguro (editado)';
        final canCreate = monto > 0 && valorCuota > 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: _AppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 24),

                // ── Cliente ──────────────────────────────────────
                _SectionTitle(
                  icon: Icons.person_outline_rounded,
                  title: 'Cliente',
                ),
                const SizedBox(height: 14),
                _ClientSelector(),
                const SizedBox(height: 28),

                // ── Info préstamo ─────────────────────────────────
                _SectionTitle(
                  icon: Icons.request_quote_outlined,
                  title: 'Información del préstamo',
                ),
                const SizedBox(height: 14),
                InputWidget.input(
                  label: 'Monto inicial',
                  hintText: 'Ej: 100',
                  prefixIcon: Icons.attach_money_rounded,
                  controller: cubit.montoController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    cubit.recalcularSeguro();
                    setState(() {});
                  }, // refresca el BlocBuilder raíz
                ),
                const SizedBox(height: 16),
                InputWidget.input(
                  label: 'Interés (%)',
                  hintText: '20',
                  prefixIcon: Icons.percent_rounded,
                  controller: cubit.interesController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _InsuranceSection(
                  state: state,
                  cubit: cubit,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 24),

                // ── Frecuencia ────────────────────────────────────
                const Text(
                  'Frecuencia de cobro',
                  style: TextStyle(
                    color: Color(0xFF687386),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _FrequencyDropdown(state: state, cubit: cubit),
                const SizedBox(height: 16),
                _CuotasField(
                  state: state,
                  cubit: cubit,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 28),

                // ── Cobro ─────────────────────────────────────────
                _SectionTitle(
                  icon: Icons.calendar_month_outlined,
                  title: 'Configuración de cobro',
                ),
                const SizedBox(height: 14),
                const _CollectionConfig(),
                const SizedBox(height: 16),
                _StartDate(state: state, cubit: cubit),
                const SizedBox(height: 28),

                // ── Resumen ───────────────────────────────────────
                _SectionTitle(
                  icon: Icons.calculate_outlined,
                  title: 'Resumen del préstamo',
                ),
                const SizedBox(height: 14),
                _Summary(
                  monto: monto,
                  interesMonto: interesMonto,
                  seguro: seguro,
                  seguroLabel: seguroLabel,
                  interesPct: cubit.interesController.text,
                  total: total,
                  cuotas: cuotas,
                  valorCuota: valorCuota,
                ),
                const SizedBox(height: 28),

                // ── Preview ───────────────────────────────────────
                if (state.periodoSeleccionado != null && cuotas > 0) ...[
                  _SchedulePreview(state: state, cuotas: cuotas),
                  const SizedBox(height: 30),
                ],
                const SizedBox(height: 14),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(
                        state.isPrevious
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 10),
                      Text("Préstamo existente"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Botones ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: BtnWidget.btn(
                    text: 'Crear préstamo',
                    icon: Icons.check_rounded,
                    loading: state.loadingBtn,
                    onPressed: canCreate
                        ? () {
                            if (state.isPrevious) {
                              context.read<PrestamoCubit>().goToPrevious();
                            } else {
                              context.read<PrestamoCubit>().crearPrestamo();
                            }
                          }
                        : null,
                    enabled: canCreate,
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => context.read<PrestamoCubit>().onGetChild(
                      PrestamosHome(),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: .25),
                      ),
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
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS PRIVADOS
// ══════════════════════════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () =>
            context.read<PrestamoCubit>().onGetChild(PrestamosHome()),
      ),
      title: const Text(
        'Nuevo préstamo',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
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
          Icon(Icons.request_quote_outlined, color: Colors.white, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar préstamo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Configure las condiciones del préstamo.',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
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
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsuranceSection extends StatelessWidget {
  const _InsuranceSection({
    required this.state,
    required this.cubit,
    required this.onChanged,
  });
  final PrestamoState state;
  final PrestamoCubit cubit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final aplica = state.aplicaSeguro;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => cubit.onAplicaSeguro(!aplica),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Checkbox(
                  value: aplica,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => cubit.onAplicaSeguro(v ?? false),
                ),
                const Icon(
                  Icons.security_outlined,
                  size: 18,
                  color: Color(0xFF687386),
                ),
                const SizedBox(width: 8),
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
          ),
          if (aplica) ...[
            const SizedBox(height: 10),

            InputWidget.input(
              label: 'Valor del seguro',
              hintText: '10',
              prefixIcon: Icons.attach_money_rounded,
              controller: cubit.seguroValorController,
              keyboardType: TextInputType.number,
              onChanged: (_) => onChanged(),
            ),

            const SizedBox(height: 10),
            const _InfoMessage(
              icon: Icons.info_outline_rounded,
              text:
                  'El valor se calcula con el % sobre el monto, pero puedes editarlo. Si cambias el monto o el %, se recalcula.',
            ),
          ],
        ],
      ),
    );
  }
}

class _CuotasField extends StatelessWidget {
  const _CuotasField({
    required this.state,
    required this.cubit,
    required this.onChanged,
  });
  final PrestamoState state;
  final PrestamoCubit cubit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final periodo = state.periodoSeleccionado;
    final porDefecto = periodo?.cuotas;
    final editado =
        periodo != null && cubit.cuotasController.text != '${porDefecto ?? ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputWidget.input(
          label: 'Número de cuotas',
          hintText: periodo == null
              ? 'Seleccione una frecuencia'
              : '$porDefecto',
          prefixIcon: Icons.format_list_numbered_rounded,
          controller: cubit.cuotasController,
          keyboardType: TextInputType.number,
          enabled: periodo != null,
          errorText: cubit.cuotasError,
          suffixIcon: editado ? Icons.restart_alt_rounded : null,
          onSuffixPressed: () {
            cubit.restablecerCuotas();
            onChanged();
          },
          onChanged: (_) {
            cubit.fechaFinal();
            onChanged();
          },
        ),
        if (periodo != null) ...[
          const SizedBox(height: 10),
          _InfoMessage(
            icon: Icons.info_outline_rounded,
            text:
                'Por defecto son $porDefecto cuotas según la frecuencia ${periodo.nombre.toLowerCase()}, pero puedes modificarlas.',
          ),
        ],
      ],
    );
  }
}

class _FrequencyDropdown extends StatefulWidget {
  const _FrequencyDropdown({required this.state, required this.cubit});
  final PrestamoState state;
  final PrestamoCubit cubit;

  @override
  State<_FrequencyDropdown> createState() => _FrequencyDropdownState();
}

class _FrequencyDropdownState extends State<_FrequencyDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SCobroEntity>(
          hint: const Text('Seleccionar frecuencia'),
          isExpanded: true,
          value: widget.state.periodoSeleccionado,
          elevation: 12,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF687386),
          ),
          items:
              (Shared.getConfig?.periodosCobro.where((e) => e.habilitado) ?? [])
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.nombre)))
                  .toList(),
          onChanged: (value) {
            if (value == null) return;
            widget.cubit.onGetPeriodo(value);
            widget.cubit.fechaFinal();
            setState(() {});
          },
        ),
      ),
    );
  }
}

class _ClientSelector extends StatelessWidget {
  const _ClientSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrestamoCubit, PrestamoState>(
      buildWhen: (prev, curr) => prev.cliente != curr.cliente,
      builder: (context, state) {
        final cubit = context.read<PrestamoCubit>();
        return GestureDetector(
          onTap: () async {
            if (Shared.getIdClient.isNotEmpty) return;
            final clientes = Shared.getClientes ?? [];
            final seleccionado = await showSearch<DatumClEntity?>(
              context: context,
              delegate: ClienteSearchDelegate(clientes),
            );
            if (seleccionado != null) cubit.onGetClient(seleccionado);
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: .05)),
            ),
            child: state.cliente == null
                ? const _ClientEmpty()
                : _ClientSelected(state.cliente!),
          ),
        );
      },
    );
  }
}

class _ClientEmpty extends StatelessWidget {
  const _ClientEmpty();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Avatar(icon: Icons.person_outline_rounded),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seleccionar cliente',
                style: TextStyle(
                  color: Color(0xFF202838),

                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Busque por nombre o número de cédula',
                style: TextStyle(color: Color(0xFF929BAB)),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: Color(0xFF8A93A3)),
      ],
    );
  }
}

class _ClientSelected extends StatelessWidget {
  const _ClientSelected(this.cliente);
  final DatumClEntity cliente;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Avatar(icon: Icons.person_rounded),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cliente.nombres} ${cliente.apellidos}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF202838),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              _IconText(icon: Icons.badge_outlined, text: cliente.cedula),
              const SizedBox(height: 3),
              _IconText(icon: Icons.phone_outlined, text: cliente.telefono),
            ],
          ),
        ),
        Visibility(
          visible: Shared.getIdClient.isEmpty,
          child: Icon(Icons.edit_outlined, size: 19, color: Color(0xFF8A93A3)),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: const Color(0xFF4164E8)),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF929BAB)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF929BAB), fontSize: 11),
        ),
      ],
    );
  }
}

class _CollectionConfig extends StatelessWidget {
  const _CollectionConfig();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Color(0xFF00A86B),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendario de cobro',
                      style: TextStyle(
                        color: Color(0xFF202838),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Configuración global',
                      style: TextStyle(color: Color(0xFF929BAB)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Color(0xFF929BAB),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Días habilitados para cobro',
            style: TextStyle(
              color: Color(0xFF687386),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: (Shared.getConfig?.diasCobro ?? [])
                .map(
                  (e) => _DayBadge(
                    e.nombre.substring(0, 1).toUpperCase(),
                    e.habilitado,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge(this.day, this.enabled);
  final String day;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
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
    );
  }
}

class _StartDate extends StatelessWidget {
  const _StartDate({required this.state, required this.cubit});
  final PrestamoState state;
  final PrestamoCubit cubit;

  @override
  Widget build(BuildContext context) {
    final fecha = state.fechaInicial;
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(15),
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF4164E8),
                    size: 20,
                  ),
                ),
                SizedBox(width: 10),
                Text('Fecha de inicio'),
              ],
            ),
            const SizedBox(width: 12),

            SizedBox(height: 3),
            Text(
              'Seleccione la fecha de inicio del cobro',
              style: TextStyle(
                color: Color(0xFF202838),

                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            if (fecha != null)
              Text(
                '${fecha.day}/${fecha.month}/${fecha.year}',
                style: const TextStyle(
                  color: Color(0xFF4164E8),

                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: cubit.state.fechaInicial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      cubit.onGetFechaInicial(date);
      cubit.fechaFinal();
    }
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.monto,
    required this.interesMonto,
    required this.seguro,
    required this.seguroLabel,
    required this.interesPct,
    required this.total,
    required this.cuotas,
    required this.valorCuota,
  });

  final int monto, interesMonto, seguro, total, cuotas, valorCuota;
  final String seguroLabel, interesPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26354A), Color(0xFF182436)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SummaryRow('Monto inicial', '$monto'),
          const SizedBox(height: 10),
          _SummaryRow('Interés ($interesPct%)', '$interesMonto'),
          const SizedBox(height: 10),
          _SummaryRow(seguroLabel, '$seguro'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24),
          ),
          _SummaryRow('Total a pagar', '$total', highlight: true),
          const SizedBox(height: 10),
          _SummaryRow('Número de cuotas', '$cuotas'),
          const SizedBox(height: 10),
          _SummaryRow('Valor de cada cuota', '$valorCuota', highlight: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.highlight = false});
  final String label, value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white60)),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFF7CFF6B) : Colors.white,

            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  const _SchedulePreview({required this.state, required this.cuotas});
  final PrestamoState state;
  final int cuotas;

  @override
  Widget build(BuildContext context) {
    final periodo = state.periodoSeleccionado!;
    final showTimeline =
        periodo.codigo == 'SEMANAL' || periodo.codigo == 'QUINCENAL';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_note_outlined,
                color: Color(0xFF4164E8),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Calendario estimado',
                style: TextStyle(
                  color: Color(0xFF202838),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CalendarInfo('Inicio', _formatDate(state.fechaInicial)),
              ),
              Container(
                width: 1,
                height: 35,
                color: Colors.black.withValues(alpha: .08),
              ),
              Expanded(
                child: _CalendarInfo(
                  'Final estimado',
                  _formatDate(state.fechaFinal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'El pago total del préstamo se debe realizar en $cuotas ${cuotas == 1 ? 'cuota' : 'cuotas'}',
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: Color(0xFF687386),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (showTimeline && state.fechasPago != null) ...[
            const SizedBox(height: 12),
            ...state.fechasPago!.asMap().entries.map((entry) {
              final i = entry.key;
              final fecha = entry.value;
              final isLast = i == state.fechasPago!.length - 1;
              return _TimelineItem(index: i, fecha: fecha, isLast: isLast);
            }),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) =>
      date == null ? '' : '${date.day}/${date.month}/${date.year}';
}

class _CalendarInfo extends StatelessWidget {
  const _CalendarInfo(this.title, this.value);
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF929BAB))),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF202838),
        
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.index,
    required this.fecha,
    required this.isLast,
  });
  final int index;
  final DateTime fecha;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: .20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppTheme.primaryColor.withValues(alpha: .15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black.withValues(alpha: .05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF4164E8),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cuota ${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF202838),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Fecha de cobro',
                          style: TextStyle(
                            color: Color(0xFF929BAB),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
                    style: const TextStyle(
                      color: Color(0xFF4164E8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
