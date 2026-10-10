import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal/src/domain/entities/nomina_entity.dart';

/// Persona a la que se le puede pagar nómina
class EmpleadoNomina extends Equatable {
  final String id;
  final String nombre;

  /// Cobrador / Administrador
  final String rol;

  /// Solo se conoce si el backend la envía en el listado
  final ComisionEntity? comision;

  const EmpleadoNomina({
    required this.id,
    required this.nombre,
    required this.rol,
    this.comision,
  });

  @override
  List<Object?> get props => [id, nombre, rol, comision];
}

enum AtajoPeriodo { quincena1, quincena2, mes, personalizado }

/// Rango de fechas de un cálculo o consulta de nómina
class PeriodoNomina extends Equatable {
  final DateTime inicio;
  final DateTime fin;
  final AtajoPeriodo atajo;

  const PeriodoNomina({
    required this.inicio,
    required this.fin,
    required this.atajo,
  });

  factory PeriodoNomina.mesActual() {
    final hoy = DateTime.now();
    return PeriodoNomina.deMes(DateTime(hoy.year, hoy.month), AtajoPeriodo.mes);
  }

  /// Aplica un atajo (quincena 1, quincena 2, mes) sobre el mes [mes]
  factory PeriodoNomina.deMes(DateTime mes, AtajoPeriodo atajo) {
    final ultimoDia = DateTime(mes.year, mes.month + 1, 0);
    return switch (atajo) {
      AtajoPeriodo.quincena1 => PeriodoNomina(
        inicio: DateTime(mes.year, mes.month, 1),
        fin: DateTime(mes.year, mes.month, 15),
        atajo: atajo,
      ),
      AtajoPeriodo.quincena2 => PeriodoNomina(
        inicio: DateTime(mes.year, mes.month, 16),
        fin: ultimoDia,
        atajo: atajo,
      ),
      _ => PeriodoNomina(
        inicio: DateTime(mes.year, mes.month, 1),
        fin: ultimoDia,
        atajo: AtajoPeriodo.mes,
      ),
    };
  }

  DateTime get mes => DateTime(inicio.year, inicio.month);

  /// Mismo atajo en otro mes: [meses] = -1 anterior, +1 siguiente
  PeriodoNomina moverMes(int meses) => PeriodoNomina.deMes(
    DateTime(mes.year, mes.month + meses),
    atajo == AtajoPeriodo.personalizado ? AtajoPeriodo.mes : atajo,
  );

  bool get esMesActual {
    final hoy = DateTime.now();
    return mes.year == hoy.year && mes.month == hoy.month;
  }

  @override
  List<Object?> get props => [inicio, fin, atajo];
}

enum ConceptoNomina { nomina, prima, otro }

const conceptoNomina = 'Nómina';
const conceptoPrima = 'Prima';
const conceptoSupervisor = 'Nómina - Supervisor';

/// Texto del concepto a enviar; [porDefecto] cuando es nómina
String? textoConcepto(
  ConceptoNomina c,
  String otro, {
  String porDefecto = conceptoNomina,
}) => switch (c) {
  ConceptoNomina.nomina => porDefecto,
  ConceptoNomina.prima => conceptoPrima,
  ConceptoNomina.otro => otro.trim(),
};

/// "350.000" o "350000" → 350000; null si no es un entero válido
int? parseValor(String texto) =>
    int.tryParse(texto.replaceAll('.', '').replaceAll(',', '').trim());

DateTime hoy() => DateUtils.dateOnly(DateTime.now());
