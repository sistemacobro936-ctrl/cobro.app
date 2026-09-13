part of 'cobrador_cubit.dart';

class CobradorState extends Equatable {
  final BuildContext context;
  final Widget child;
  final bool loading;
  final bool loadingbtn;
  final bool btnEnabled;
  final bool showPass;
  final List<DatumCEntity>? cobradores;
  final DatumCEntity? cobrador;
  const CobradorState({
    required this.context,
    this.child = const SizedBox(),
    this.loading = false,
    this.loadingbtn = false,
    this.btnEnabled = false,
    this.showPass = false,
    this.cobradores,
    this.cobrador,
  });

  @override
  List<Object?> get props => [
    context,
    loading,
    btnEnabled,
    child,
    showPass,
    cobradores ?? [],
    loadingbtn,
    cobrador,
  ];

  CobradorState copyWith({
    BuildContext? context,
    bool? loading,
    bool? btnEnabled,
    Widget? child,
    bool? showPass,
    bool? loadingbtn,
    List<DatumCEntity>? cobradores,
    DatumCEntity? cobrador,
  }) {
    return CobradorState(
      context: context ?? this.context,
      loading: loading ?? this.loading,
      btnEnabled: btnEnabled ?? this.btnEnabled,
      child: child ?? this.child,
      showPass: showPass ?? this.showPass,
      cobradores: cobradores ?? this.cobradores,
      loadingbtn: loadingbtn ?? this.loadingbtn,
      cobrador: cobrador ?? this.cobrador,
    );
  }
}
