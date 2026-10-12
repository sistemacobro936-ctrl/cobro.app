part of 'solicitudes_cubit.dart';

class SolicitudesState extends Equatable {
  final BuildContext context;
  final bool esAdmin;
  final bool loading;

  /// Aprobando o rechazando una solicitud
  final bool procesando;
  final List<SolicitudClienteEntity> solicitudes;

  /// PENDIENTE, APROBADA, RECHAZADA; '' = todas
  final String filtroEstado;

  const SolicitudesState({
    required this.context,
    required this.esAdmin,
    this.loading = false,
    this.procesando = false,
    this.solicitudes = const [],
    this.filtroEstado = 'PENDIENTE',
  });

  @override
  List<Object?> get props => [
    context,
    esAdmin,
    loading,
    procesando,
    solicitudes,
    filtroEstado,
  ];

  SolicitudesState copyWith({
    bool? loading,
    bool? procesando,
    List<SolicitudClienteEntity>? solicitudes,
    String? filtroEstado,
  }) {
    return SolicitudesState(
      context: context,
      esAdmin: esAdmin,
      loading: loading ?? this.loading,
      procesando: procesando ?? this.procesando,
      solicitudes: solicitudes ?? this.solicitudes,
      filtroEstado: filtroEstado ?? this.filtroEstado,
    );
  }
}
