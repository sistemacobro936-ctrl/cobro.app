part of 'rangos_mora_cubit.dart';

class RangosMoraState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool guardando;
  final List<FilaRango> filas;

  /// Las filas son mutables: la versión fuerza el rebuild
  final int version;

  const RangosMoraState({
    required this.context,
    this.loading = false,
    this.guardando = false,
    this.filas = const [],
    this.version = 0,
  });

  @override
  List<Object?> get props => [context, loading, guardando, filas, version];

  RangosMoraState copyWith({
    bool? loading,
    bool? guardando,
    List<FilaRango>? filas,
    int? version,
  }) {
    return RangosMoraState(
      context: context,
      loading: loading ?? this.loading,
      guardando: guardando ?? this.guardando,
      filas: filas ?? this.filas,
      version: version ?? this.version,
    );
  }
}
