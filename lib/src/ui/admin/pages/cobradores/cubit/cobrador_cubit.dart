import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/shared/shared.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/common/utils/update_util.dart';
import 'package:personal/src/domain/dto/crear_cobrador_dto.dart';
import 'package:personal/src/domain/entities/cobrador_entity.dart';
import 'package:personal/src/domain/repository/ruta_repo.dart';
import 'package:personal/src/domain/repository/usuario_repo.dart';
import 'package:personal/src/ui/admin/pages/cobradores/views/cobrador_home.dart';

part 'cobrador_state.dart';

class CobradorCubit extends Cubit<CobradorState> {
  ///Repositorios
  ///
  ///
  final _usuarioRepo = sl<UsuarioRepository>();
  final _rutaRepo = sl<RutaRepo>();

  ///Constructor
  ///
  ///
  CobradorCubit({required BuildContext context})
    : super(CobradorState(context: context)) {
    eventChild(CobradorHome());
    listarRuta();
  }

  ///Variables
  ///
  ///
  final nameTxt = TextEditingController();
  final lastNameTxt = TextEditingController();
  final ideTxt = TextEditingController();
  final contacTxt = TextEditingController();
  final userTxt = TextEditingController();
  final passTxt = TextEditingController();

  ///Eventos
  ///
  ///
  void eventChild(Widget child) {
    emit(state.copyWith(child: child));
  }

  void onShowPassword() {
    emit(state.copyWith(showPass: !state.showPass));
  }

  ///Validaciones
  ///
  ///
  void enbaledBtn({bool isEdit = false}) {
    final fieldsValid = [
      nameTxt,
      lastNameTxt,
      ideTxt,
      contacTxt,
    ].every((text) => text.text.trim().isNotEmpty);

    final credentialsValid = userTxt.text.isNotEmpty && passTxt.text.isNotEmpty;

    emit(
      state.copyWith(btnEnabled: fieldsValid && (isEdit || credentialsValid)),
    );
  }

  ///Peticiones
  ///
  ///
  void listarCobrador() async {
    emit(state.copyWith(loading: true));
    final r = await _usuarioRepo.listarCobradores();
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        Shared.setCobradores = r.data;
        emit(state.copyWith(cobradores: r.data));
      },
    );

    emit(state.copyWith(loading: false));
  }

  void listarRuta() async {
    if (Shared.getRutas != null) return;
    emit(state.copyWith(loading: true));
    final r = await _rutaRepo.listar();
    r.fold((l) {}, (r) {
      Shared.setRutas = r.data;
    });
    emit(state.copyWith(loading: false));
  }

  void crearCobrador() async {
    emit(state.copyWith(loadingbtn: true));
    final r = await _usuarioRepo.crearCobrador(
      dto: CrearCobradorDto(
        nombre: nameTxt.text.trim(),
        apellido: lastNameTxt.text.trim(),
        telefono: contacTxt.text.trim(),
        username: userTxt.text.trim(),
        password: passTxt.text.trim(),
        documento: ideTxt.text.trim(),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (e) {
        AppDialogUtil.success(
          state.context,
          message: "Cobrador creado con éxito.",
        );
        listarCobrador();
        eventChild(CobradorHome());
      },
    );
    emit(state.copyWith(loadingbtn: false));
  }

  void detalleCobrador(String id) async {
    emit(state.copyWith(loading: true));
    final r = await _usuarioRepo.detalleCobrador(id: id);
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        emit(state.copyWith(cobrador: r));
      },
    );
    emit(state.copyWith(loading: false));
  }

  void editarCobrador() async {
    emit(state.copyWith(loadingbtn: true));
    final r = await _usuarioRepo.editarCobrador(
      id: state.cobrador!.id,
      dto: CrearCobradorDto(
        nombre: UpdateUtil.valorModificado(
          state.cobrador!.nombre,
          nameTxt.text,
        ),
        apellido: UpdateUtil.valorModificado(
          state.cobrador!.apellido,
          lastNameTxt.text,
        ),
        telefono: UpdateUtil.valorModificado(
          state.cobrador!.telefono,
          contacTxt.text,
        ),
      ),
    );
    r.fold(
      (l) {
        AppDialogUtil.error(state.context, message: l.props[0].toString());
      },
      (r) {
        listarCobrador();
        eventChild(CobradorHome());
        AppDialogUtil.success(
          state.context,
          message: "Cobrador editado con exito.",
        );
      },
    );

    emit(state.copyWith(loadingbtn: false));
  }

  ///Navegacion
  ///
  ///

  ///Otros
  ///
  ///
  ///

  void loadC() {
    final c = state.cobrador!;

    nameTxt.text = c.nombre;
    lastNameTxt.text = c.apellido;
    ideTxt.text = c.documento;
    contacTxt.text = c.telefono;
  }

  void clear() {
    nameTxt.clear();
    lastNameTxt.clear();
    ideTxt.clear();
    contacTxt.clear();
    userTxt.clear();
    passTxt.clear();
    emit(state.copyWith(btnEnabled: false));
  }

  @override
  Future<void> close() {
    nameTxt.dispose();
    lastNameTxt.dispose();
    ideTxt.dispose();
    contacTxt.dispose();
    userTxt.dispose();
    passTxt.dispose();
    return super.close();
  }
}
