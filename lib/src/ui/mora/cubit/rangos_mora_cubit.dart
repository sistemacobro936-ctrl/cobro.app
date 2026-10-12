import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal/get_it.dart';
import 'package:personal/src/common/utils/app_dialog_util.dart';
import 'package:personal/src/domain/entities/mora_entity.dart';
import 'package:personal/src/domain/repository/mora_repo.dart';

part 'rangos_mora_state.dart';

/// Fila editable: `desde` se deriva de la anterior; `hasta` vacío solo en
/// la última (en adelante)
class FilaRango {
  final int key;
  final TextEditingController hastaTxt;
  final TextEditingController etiquetaTxt;
  String colorHex;

  FilaRango({
    required this.key,
    int? hasta,
    String etiqueta = '',
    this.colorHex = '#8A93A3',
  }) : hastaTxt = TextEditingController(text: hasta?.toString() ?? ''),
       etiquetaTxt = TextEditingController(text: etiqueta);

  int? get hasta => int.tryParse(hastaTxt.text.trim());

  void dispose() {
    hastaTxt.dispose();
    etiquetaTxt.dispose();
  }
}

/// Colores para elegir en cada rango
const coloresMora = [
  '#8A93A3', // gris (normal)
  '#F2C94C', // amarillo
  '#F2994A', // naranja
  '#EB5757', // rojo
  '#9B51E0', // morado
  '#2D9CDB', // azul
  '#27AE60', // verde
  '#4F4F4F', // gris oscuro
];

class RangosMoraCubit extends Cubit<RangosMoraState> {
  final _moraRepo = sl<MoraRepo>();
  final List<FilaRango> _filas = [];
  int _siguienteKey = 0;

  RangosMoraCubit(BuildContext context)
    : super(RangosMoraState(context: context)) {
    cargar();
  }

  @override
  Future<void> close() {
    for (final f in _filas) {
      f.dispose();
    }
    return super.close();
  }

  Future<void> cargar() async {
    emit(state.copyWith(loading: true));
    final r = await _moraRepo.rangos();
    if (isClosed) return;

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      _ponerRangos,
    );
    emit(state.copyWith(loading: false));
  }

  /// Desde de la fila [i]: 1 la primera, si no el hasta anterior + 1
  int desde(int i) {
    if (i == 0) return 1;
    final anterior = _filas[i - 1].hasta;
    return anterior == null ? 0 : anterior + 1;
  }

  void agregarRango() {
    // La que era la última deja de ser "en adelante": se le sugiere un tope
    final ultima = _filas.last;
    final i = _filas.length - 1;
    if (ultima.hasta == null) ultima.hastaTxt.text = '${desde(i) + 29}';
    _filas.add(FilaRango(key: _siguienteKey++, etiqueta: 'Nuevo rango'));
    _emitir();
  }

  void quitarRango(FilaRango fila) {
    if (_filas.length <= 1) return;
    _filas.remove(fila);
    // La nueva última queda "en adelante"
    _filas.last.hastaTxt.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => fila.dispose());
    _emitir();
  }

  void cambiarColor(FilaRango fila, String hex) {
    fila.colorHex = hex;
    _emitir();
  }

  void onCambio() => _emitir();

  /// Primer problema de los rangos (mismas reglas del backend), o null
  String? validar() {
    for (var i = 0; i < _filas.length; i++) {
      final f = _filas[i];
      final n = i + 1;
      final d = desde(i);
      if (f.etiquetaTxt.text.trim().isEmpty) {
        return 'Ponle nombre al rango $n.';
      }
      if (i < _filas.length - 1) {
        final h = f.hasta;
        if (h == null || h < d) {
          return 'El rango $n debe terminar en un día igual o mayor a $d.';
        }
      }
    }
    return null;
  }

  Future<void> guardar() async {
    final error = validar();
    if (error != null) {
      AppDialogUtil.error(state.context, message: error);
      return;
    }

    final rangos = [
      for (var i = 0; i < _filas.length; i++)
        RangoMoraEntity(
          desde: desde(i),
          hasta: i == _filas.length - 1 ? null : _filas[i].hasta,
          colorHex: _filas[i].colorHex,
          etiqueta: _filas[i].etiquetaTxt.text.trim(),
        ),
    ];

    emit(state.copyWith(guardando: true));
    final r = await _moraRepo.guardarRangos(rangos);
    if (isClosed) return;
    emit(state.copyWith(guardando: false));

    r.fold(
      (l) => AppDialogUtil.error(state.context, message: l.props[0].toString()),
      (_) => AppDialogUtil.success(
        state.context,
        message: 'Rangos de mora guardados.',
      ),
    );
  }

  void _ponerRangos(List<RangoMoraEntity> rangos) {
    for (final f in _filas) {
      f.dispose();
    }
    _filas
      ..clear()
      ..addAll(
        rangos.map(
          (r) => FilaRango(
            key: _siguienteKey++,
            hasta: r.hasta,
            etiqueta: r.etiqueta,
            colorHex: r.colorHex,
          ),
        ),
      );
    _emitir();
  }

  void _emitir() => emit(
    state.copyWith(filas: List.unmodifiable(_filas), version: state.version + 1),
  );
}
