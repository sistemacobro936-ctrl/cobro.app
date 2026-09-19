import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/dto/administrador_dto.dart';
import 'package:personal/src/domain/dto/registro_dto.dart';
import 'package:personal/src/domain/dto/registro_negocio_dto.dart';
import 'package:personal/src/domain/repository/negocio_repo.dart';

part 'registro_state.dart';

class RegistroCubit extends Cubit<RegistroState> {
  ///Repositorios
  ///
  ///
  final _negocioRepo = sl<NegocioRepo>();

  ///Constructor
  ///
  ///
  RegistroCubit({required BuildContext context})
    : super(RegistroState(context: context));

  ///Variables
  ///
  ///
  static const minPasswordLength = 8;

  final negNombreTxt = TextEditingController();
  final negDocumentoTxt = TextEditingController();
  final negTelefonoTxt = TextEditingController();
  final negDireccionTxt = TextEditingController();
  final admNombreTxt = TextEditingController();
  final admApellidoTxt = TextEditingController();
  final admDocumentoTxt = TextEditingController();
  final admTelefonoTxt = TextEditingController();
  final admEmailTxt = TextEditingController();
  final admUserTxt = TextEditingController();
  final admPassTxt = TextEditingController();

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
      negNombreTxt,
      negDocumentoTxt,
      negTelefonoTxt,
      negDireccionTxt,
      admNombreTxt,
      admApellidoTxt,
      admDocumentoTxt,
      admTelefonoTxt,
      admEmailTxt,
      admUserTxt,
      admPassTxt,
    ].every((c) => c.text.trim().isNotEmpty);
log("$passwordValida");
    emit(state.copyWith(btnEnabled: e && passwordValida));
  }

  bool get passwordValida => admPassTxt.text.trim().length >= minPasswordLength;

  String? get passwordError {
    final pass = admPassTxt.text.trim();
    if (pass.isEmpty || pass.length >= minPasswordLength) return null;
    return 'La contraseña debe tener mínimo $minPasswordLength caracteres';
  }

  ///Peticiones
  ///
  ///
  void registrar() async {
    emit(state.copyWith(loading: true));
    final r = await _negocioRepo.registrar(
      dto: RegistroDto(
        negocio: RegistroNegocioDto(
          nombre: negNombreTxt.text.trim(),
          documento: negDocumentoTxt.text.trim(),
          telefono: negTelefonoTxt.text.trim(),
          direccion: negDireccionTxt.text.trim(),
        ),
        admin: AdministradorDto(
          nombre: admNombreTxt.text.trim(),
          apellido: admApellidoTxt.text.trim(),
          documento: admDocumentoTxt.text.trim(),
          telefono: admTelefonoTxt.text.trim(),
          email: admEmailTxt.text.trim(),
          username: admUserTxt.text.trim(),
          password: admPassTxt.text.trim(),
        ),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        AppDialogUtil.success(
          state.context,
          message:
              "Negocio registrado con éxito. Ya puedes iniciar sesión con el usuario del administrador.",
          onPressed: () => Navigator.pop(state.context),
        );
      },
    );
    emit(state.copyWith(loading: false));
  }

  ///Otros
  ///
  ///
  @override
  Future<void> close() {
    negNombreTxt.dispose();
    negDocumentoTxt.dispose();
    negTelefonoTxt.dispose();
    negDireccionTxt.dispose();
    admNombreTxt.dispose();
    admApellidoTxt.dispose();
    admDocumentoTxt.dispose();
    admTelefonoTxt.dispose();
    admEmailTxt.dispose();
    admUserTxt.dispose();
    admPassTxt.dispose();
    return super.close();
  }
}
