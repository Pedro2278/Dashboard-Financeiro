import 'package:flutter/foundation.dart';

@immutable
abstract class FilterEvent {}

/// Evento para filtrar por tipo de transação (entrada/saída)
class FilterByType extends FilterEvent {
  final bool? isIncome; // null = todos
  FilterByType(this.isIncome);
}

/// Evento para filtrar por categoria
class FilterByCategory extends FilterEvent {
  final int? categoryId; // null = todas
  FilterByCategory(this.categoryId);
}

/// Evento para filtrar por período de datas
class FilterByDate extends FilterEvent {
  final DateTime? start;
  final DateTime? end;
  FilterByDate({this.start, this.end});
}

/// Evento para limpar todos os filtros
class ClearFilters extends FilterEvent {}
