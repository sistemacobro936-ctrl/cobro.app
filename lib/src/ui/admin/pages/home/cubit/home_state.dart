part of 'home_cubit.dart';

class HomeState extends Equatable {
  final BuildContext context;
  final int currentIndex;
  final List<DatumClEntity>? clientes;
  final bool loadPay;
  final bool asignarPrestamo;
  final DashboardEntity? dashboard;
  final bool loadingDashboard;
  final bool errorDashboard;

  const HomeState({
    required this.context,
    this.currentIndex = 0,
    this.clientes,
    this.loadPay = false,
    this.asignarPrestamo = false,
    this.dashboard,
    this.loadingDashboard = false,
    this.errorDashboard = false,
  });

  @override
  List<Object?> get props => [
    context,
    currentIndex,
    clientes ?? [],
    loadPay,
    asignarPrestamo,
    dashboard,
    loadingDashboard,
    errorDashboard,
  ];
  HomeState copyWith({
    BuildContext? context,
    int? currentIndex,
    List<DatumClEntity>? clientes,
    bool? loadPay,
    bool? asignarPrestamo,
    DashboardEntity? dashboard,
    bool? loadingDashboard,
    bool? errorDashboard,
  }) {
    return HomeState(
      context: context ?? this.context,
      currentIndex: currentIndex ?? this.currentIndex,
      clientes: clientes ?? this.clientes,
      loadPay: loadPay ?? this.loadPay,
      asignarPrestamo:asignarPrestamo?? this.asignarPrestamo,
      dashboard: dashboard ?? this.dashboard,
      loadingDashboard: loadingDashboard ?? this.loadingDashboard,
      errorDashboard: errorDashboard ?? this.errorDashboard,
    );
  }
}
