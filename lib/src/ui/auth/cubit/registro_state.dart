part of 'registro_cubit.dart';

class RegistroState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool btnEnabled;
  final bool showPassword;

  const RegistroState({
    required this.context,
    this.loading = false,
    this.btnEnabled = false,
    this.showPassword = false,
  });

  @override
  List<Object?> get props => [context, loading, btnEnabled, showPassword];

  RegistroState copyWith({
    BuildContext? context,
    bool? loading,
    bool? btnEnabled,
    bool? showPassword,
  }) => RegistroState(
    context: context ?? this.context,
    loading: loading ?? this.loading,
    btnEnabled: btnEnabled ?? this.btnEnabled,
    showPassword: showPassword ?? this.showPassword,
  );
}
