part of 'auth_cubit.dart';

class AuthState extends Equatable {

  final BuildContext context;
  final bool loading;
  final bool ennaled;
  final bool showPassword;
  const AuthState({this.loading = false, this.ennaled = false, this.showPassword = false, required this.context });


  @override
  List<Object> get props => [loading, ennaled, showPassword, context];

  AuthState copyWith({bool? loading, bool? ennaled, bool? showPassword, BuildContext? context}) {
    return AuthState(
      loading: loading ?? this.loading,
      ennaled: ennaled ?? this.ennaled,
      showPassword: showPassword ?? this.showPassword,
      context: context ?? this.context,
    );
  }
}
