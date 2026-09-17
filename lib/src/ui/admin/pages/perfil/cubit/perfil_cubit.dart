import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/secure_storage_util.dart';
import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/entities/administrador_entity.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';

part 'perfil_state.dart';

class PerfilCubit extends Cubit<PerfilState> {
  ///Repositorios
  ///
  ///
  final _negocioRepo = sl<NegocioRepo>();

  ///Constructor
  ///
  ///
  PerfilCubit({required BuildContext context})
    : super(PerfilState(context: context)) {
    _cargarRol();
    listarAdministradores();
  }

  ///Variables
  ///
  ///
  final nombreTxt = TextEditingController();
  final apellidoTxt = TextEditingController();
  final documentoTxt = TextEditingController();
  final telefonoTxt = TextEditingController();
  final emailTxt = TextEditingController();
  final userTxt = TextEditingController();
  final passTxt = TextEditingController();

  ///Eventos
  ///
  ///
  void onShowPassword() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  ///Validaciones
  ///
  ///
  void enabledBtn() {
    final e = [
      nombreTxt,
      apellidoTxt,
      documentoTxt,
      telefonoTxt,
      emailTxt,
      userTxt,
      passTxt,
    ].every((c) => c.text.trim().isNotEmpty);

    emit(state.copyWith(btnEnabled: e));
  }

  ///Peticiones
  ///
  ///
  void _cargarRol() async {
    final id = await SecureStorageUtil().read("usuario_id") ?? "";
    emit(state.copyWith(usuarioId: id));

    final token = await SecureStorageUtil().read("token") ?? "";
    if (token.isEmpty) return;
    final payload = JwtDecoder.decode(token);
    emit(state.copyWith(rol: payload["rol"]?.toString()));
  }

  void listarAdministradores() async {
    emit(state.copyWith(loading: true));
    final r = await _negocioRepo.listarAdministradores();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(administradores: r.data));
      },
    );
    emit(state.copyWith(loading: false));
  }

  void crearAdministrador() async {
    emit(state.copyWith(loadingBtn: true));
    final r = await _negocioRepo.crearAdministrador(
      dto: AdministradorDto(
        nombre: nombreTxt.text.trim(),
        apellido: apellidoTxt.text.trim(),
        documento: documentoTxt.text.trim(),
        telefono: telefonoTxt.text.trim(),
        email: emailTxt.text.trim(),
        username: userTxt.text.trim(),
        password: passTxt.text.trim(),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message: "Administrador creado con éxito.",
        );
        _limpiar();
        listarAdministradores();
      },
    );
    emit(state.copyWith(loadingBtn: false));
  }

  ///Otros
  ///
  ///
  void _limpiar() {
    nombreTxt.clear();
    apellidoTxt.clear();
    documentoTxt.clear();
    telefonoTxt.clear();
    emailTxt.clear();
    userTxt.clear();
    passTxt.clear();
    emit(state.copyWith(btnEnabled: false));
  }

  @override
  Future<void> close() {
    nombreTxt.dispose();
    apellidoTxt.dispose();
    documentoTxt.dispose();
    telefonoTxt.dispose();
    emailTxt.dispose();
    userTxt.dispose();
    passTxt.dispose();
    return super.close();
  }
}
