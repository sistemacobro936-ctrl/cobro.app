part of 'home_cubit.dart';

class HomeState extends Equatable {
  final BuildContext context;
  final int currentIndex;
  final List<DatumClEntity>? clientes;
  final bool loadPay;
  final bool asignarPrestamo;

  const HomeState({
    required this.context,
    this.currentIndex = 0,
    this.clientes,
    this.loadPay = false,
    this.asignarPrestamo = false,
  });

  @override
  List<Object?> get props => [context, currentIndex, clientes ?? [], loadPay, asignarPrestamo];
  HomeState copyWith({
    BuildContext? context,
    int? currentIndex,
    List<DatumClEntity>? clientes,
    bool? loadPay,
    bool? asignarPrestamo
  }) {
    return HomeState(
      context: context ?? this.context,
      currentIndex: currentIndex ?? this.currentIndex,
      clientes: clientes ?? this.clientes,
      loadPay: loadPay ?? this.loadPay,
      asignarPrestamo:asignarPrestamo?? this.asignarPrestamo,
    );
  }
}
