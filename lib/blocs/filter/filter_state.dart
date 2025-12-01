import 'package:flutter/foundation.dart';

@immutable
class FilterState {
  final bool? isIncome; // true = entrada, false = saída, null = todos
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterState({
    this.isIncome,
    this.categoryId,
    this.startDate,
    this.endDate,
  });

  FilterState copyWith({
    bool? isIncome,
    bool isIncomeClear = false,
    int? categoryId,
    bool categoryIdClear = false,
    DateTime? startDate,
    bool startDateClear = false,
    DateTime? endDate,
    bool endDateClear = false,
  }) {
    return FilterState(
      isIncome: isIncomeClear ? null : (isIncome ?? this.isIncome),
      categoryId: categoryIdClear ? null : (categoryId ?? this.categoryId),
      startDate: startDateClear ? null : (startDate ?? this.startDate),
      endDate: endDateClear ? null : (endDate ?? this.endDate),
    );
  }
}
