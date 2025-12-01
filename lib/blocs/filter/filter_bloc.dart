import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_event.dart';
import 'filter_state.dart';

/// Bloc para gerenciar os filtros de transações
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(const FilterState()) {
    on<FilterByType>((event, emit) {
      emit(state.copyWith(isIncome: event.isIncome));
    });

    on<FilterByCategory>((event, emit) {
      emit(state.copyWith(categoryId: event.categoryId));
    });

    on<FilterByDate>((event, emit) {
      emit(state.copyWith(startDate: event.start, endDate: event.end));
    });

    on<ClearFilters>((event, emit) {
      emit(const FilterState());
    });
  }
}
