part of 'config_cubit.dart';

class ConfigState extends Equatable {
  final BuildContext context;
  final bool loading;
  final bool loadingBtn;
  final DataConEntity? config;
  const ConfigState({
    required this.context,
    this.loading = false,
    this.loadingBtn = false,
    this.config
  });

  @override
  List<Object?> get props => [context, loading, loadingBtn, config];

  ConfigState copyWith({
    BuildContext? context,
    bool? loading,
    bool? loadingBtn,
    DataConEntity? config,
  }) => ConfigState(
    context: context ?? this.context,
    loading: loading ?? this.loading,
    loadingBtn: loadingBtn ?? this.loadingBtn,
    config: config ?? this.config
  );
}
