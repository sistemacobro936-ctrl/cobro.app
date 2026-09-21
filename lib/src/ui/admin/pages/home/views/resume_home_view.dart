import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/utils/date_util.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/common/utils/money_util.dart';
import 'package:personal/src/domain/entities/dashboard_entity.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';
import 'package:personal/src/ui/admin/pages/home/views/actividad_item.dart';
import 'package:personal/src/ui/admin/pages/home/views/actividad_page.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class ResumeHomeView extends StatelessWidget {
  const ResumeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final d = state.dashboard;

        return Container(
          color: const Color(0xFFF7F8FC),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: context.read<HomeCubit>().cargarDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, d),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      child: d == null
                          ? _cargandoOError(context, state)
                          : _contenido(context, d),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sin datos todavía: cargando o con error
  Widget _cargandoOError(BuildContext context, HomeState state) {
    if (state.errorDashboard && !state.loadingDashboard) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFFB0B6C0),
            ),
            const SizedBox(height: 10),
            const Text(
              'No se pudo cargar el resumen.',
              style: TextStyle(color: Color(0xFF7B8494)),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: context.read<HomeCubit>().cargarDashboard,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _contenido(BuildContext context, DashboardEntity d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title: 'Resumen de hoy'),

        const SizedBox(height: 14),

        _statistics(d),

        const SizedBox(height: 28),

        _sectionTitle(title: 'Estado de cartera'),

        const SizedBox(height: 14),

        _portfolioCard(d.cartera),

        const SizedBox(height: 28),

        _sectionTitle(
          title: 'Actividad reciente',
          action: 'Ver todo',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActividadPage()),
          ),
        ),

        const SizedBox(height: 14),

        _activityCard(d.actividadReciente),

        const SizedBox(height: 20),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header(BuildContext context, DashboardEntity? d) {
    final now = DateTime.now();
    final nombre = d == null
        ? ''
        : '${d.adminNombre} ${d.adminApellido}'.trim();

    return Builder(
      builder: (context) {
        return HeaderWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<HomeCubit>()
                            .scaffoldKey
                            .currentState
                            ?.openDrawer();
                      },
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido 👋',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          nombre.isEmpty ? 'Administrador' : nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Text(
                _formatDate(now),
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 5),

              const Text(
                'Panel general',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ESTADISTICAS
  // ============================================================

  Widget _statistics(DashboardEntity d) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_outlined,
            iconColor: const Color(0xFF4F7CFF),
            value: '${d.clientesActivos}',
            title: 'Clientes activos',
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _statCard(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFF9B59FF),
            value: '${d.cobradores}',
            title: 'Cobradores',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
  }) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D2433),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7B8494),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTERA
  // ============================================================

  Widget _portfolioCard(CarteraEntity c) {
    final double progress = (c.cumplimientoHoy / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26354A), Color(0xFF172131)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dinero en circulación',
                  style: TextStyle(color: Colors.white70, ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            MoneyUtil.format(c.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Cumplimiento del día · esperado ${MoneyUtil.format(c.cobroEsperadoHoy)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, ),
                ),
              ),
              Text(
                '${c.cumplimientoHoy.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7CFF6B),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

          const SizedBox(height: 18),

          // Row(
          //   children: [
          //     Expanded(
          //       child: _portfolioItem(
          //         icon: Icons.arrow_upward_rounded,
          //         title: 'Recaudado',
          //         value: MoneyUtil.format(c.recaudadoHoy),
          //         color: const Color(0xFF7CFF6B),
          //       ),
          //     ),

          //     Container(
          //       width: 1,
          //       height: 40,
          //       color: Colors.white.withValues(alpha: 0.10),
          //     ),

          //     Expanded(
          //       child: _portfolioItem(
          //         icon: Icons.warning_amber_rounded,
          //         title: 'Atrasado',
          //         value: MoneyUtil.format(c.atrasado),
          //         color: const Color(0xFFFF6B6B),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }


  // ============================================================
  // ACTIVIDAD
  // ============================================================

  Widget _activityCard(List<ActividadEntity> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Aún no hay actividad hoy.',
                  style: TextStyle(color: Color(0xFF8A93A3), fontSize: 13),
                ),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 24),
                  ActividadItem(actividad: items[i]),
                ],
              ],
            ),
    );
  }

  // ============================================================
  // TITULOS
  // ============================================================

  Widget _sectionTitle({
    required String title,
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1D2433),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                action,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // FECHA
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${DateUtil.nombreDia(date)} ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
