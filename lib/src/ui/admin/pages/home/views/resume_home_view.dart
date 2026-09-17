import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/admin/pages/home/cubit/home_cubit.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

class ResumeHomeView extends StatelessWidget {
  const ResumeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FC),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(title: 'Resumen de hoy'),

                    const SizedBox(height: 14),

                    _statistics(),

                    const SizedBox(height: 28),

                    _sectionTitle(title: 'Estado de cartera'),

                    const SizedBox(height: 14),

                    _portfolioCard(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      title: 'Actividad reciente',
                      action: 'Ver todo',
                    ),

                    const SizedBox(height: 14),

                    _activityCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    final now = DateTime.now();

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
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

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido 👋',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Administrador',
                          style: TextStyle(
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

  Widget _statistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_outlined,
            iconColor: const Color(0xFF4F7CFF),
            value: '10',
            title: 'Clientes activos',
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _statCard(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFF9B59FF),
            value: '3',
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

  Widget _portfolioCard() {
    const double progress = 0.65;

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
                  'Cartera total',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          const Text(
            '\$120.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Cumplimiento del día',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
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

          Row(
            children: [
              Expanded(
                child: _portfolioItem(
                  icon: Icons.arrow_upward_rounded,
                  title: 'Recaudado',
                  value: '\$15.000',
                  color: const Color(0xFF7CFF6B),
                ),
              ),

              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.10),
              ),

              Expanded(
                child: _portfolioItem(
                  icon: Icons.warning_amber_rounded,
                  title: 'Atrasado',
                  value: '\$20.000',
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portfolioItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 17),
        ),

        const SizedBox(width: 9),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVIDAD
  // ============================================================

  Widget _activityCard() {
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
      child: Column(
        children: [
          _activityItem(
            icon: Icons.payments_outlined,
            color: Colors.green,
            title: 'Pago recibido',
            subtitle: 'Juan Pérez • Ruta Norte',
            value: '+\$50.000',
          ),

          const Divider(height: 24),

          _activityItem(
            icon: Icons.payments_outlined,
            color: Colors.green,
            title: 'Pago recibido',
            subtitle: 'Carlos Gómez • Ruta Centro',
            value: '+\$35.000',
          ),

          const Divider(height: 24),

          _activityItem(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            title: 'Pago pendiente',
            subtitle: 'Pedro Martínez • Ruta Sur',
            value: '\$20.000',
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8A93A3), fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TITULOS
  // ============================================================

  Widget _sectionTitle({required String title, String? action}) {
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
          Text(
            action,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
