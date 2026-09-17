part of 'perfil_cubit.dart';

class PerfilState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingBtn;
  final bool btnEnabled;
  final bool showPassword;
  final String? rol;
  final String? usuarioId;
  final List<DatumAdministradorEntity> administradores;

  const PerfilState({
    required this.context,
    this.loading = false,
    this.loadingBtn = false,
    this.btnEnabled = false,
    this.showPassword = false,
    this.rol,
    this.usuarioId,
    this.administradores = const [],
  });

  @override
  List<Object?> get props => [
    context,
    loading,
    loadingBtn,
    btnEnabled,
    showPassword,
    rol,
    usuarioId,
    administradores,
  ];

  PerfilState copyWith({
    BuildContext? context,
    bool? loading,
    bool? loadingBtn,
    bool? btnEnabled,
    bool? showPassword,
    String? rol,
    String? usuarioId,
    List<DatumAdministradorEntity>? administradores,
  }) => PerfilState(
    context: context ?? this.context,
    loading: loading ?? this.loading,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    btnEnabled: btnEnabled ?? this.btnEnabled,
    showPassword: showPassword ?? this.showPassword,
    rol: rol ?? this.rol,
    usuarioId: usuarioId ?? this.usuarioId,
    administradores: administradores ?? this.administradores,
  );
}
