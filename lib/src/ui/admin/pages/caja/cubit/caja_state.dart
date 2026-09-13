part of 'caja_cubit.dart';

class CajaState extends Equatable {
  final BuildContext context;
  final Widget child;
  final bool loading;
  final bool btnLoading;
  final bool btnEnabled;
  final DatumCajaEntity? cajas;
  final List<GastoElementEntity>? gastos;
  const CajaState({
    required this.context,
    this.child = const SizedBox(),
    this.loading = false,
    this.btnLoading = false,
    this.btnEnabled = false,
    this.cajas,
    this.gastos,
  });

  @override
  List<Object?> get props => [
    btnEnabled,
    context,
    loading,
    btnLoading,
    child,
    cajas,
    gastos,
  ];
  CajaState copyWith({
    BuildContext? context,
    Widget? child,
    bool? loading,
    bool? btnLoading,
    bool? btnEnabled,
    DatumCajaEntity? cajas,
    List<GastoElementEntity>? gastos,
  }) => CajaState(
    context: context ?? this.context,
    child: child ?? this.child,
    loading: loading ?? this.loading,
    btnLoading: btnLoading ?? this.btnLoading,
    cajas: cajas ?? this.cajas,
    btnEnabled: btnEnabled ?? this.btnEnabled,
    gastos: gastos ?? this.gastos,
  );
}
