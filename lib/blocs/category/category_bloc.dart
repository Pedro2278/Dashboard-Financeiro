// lib/blocs/category/category_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repo;

  CategoryBloc({CategoryRepository? repository})
    : _repo = repository ?? CategoryRepository(),
      super(CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<AddCategory>(_onAdd);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final list = await _repo.getAll();
      emit(CategoryLoaded(list));
    } catch (e) {
      // log error for debugging
      // ignore: avoid_print
      print('CategoryBloc._onLoad error: $e');
      emit(CategoryError('Falha ao carregar categorias'));
    }
  }

  Future<void> _onAdd(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      // se id for nulo, db com AUTOINCREMENT vai gerar um id
      await _repo.insert(event.category);
      add(LoadCategories());
    } catch (e) {
      // ignore: avoid_print
      print('CategoryBloc._onAdd error: $e');
      emit(CategoryError('Falha ao adicionar categoria'));
    }
  }

  Future<void> _onUpdate(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repo.update(event.category);
      add(LoadCategories());
    } catch (e) {
      // ignore: avoid_print
      print('CategoryBloc._onUpdate error: $e');
      emit(CategoryError('Falha ao atualizar categoria'));
    }
  }

  Future<void> _onDelete(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repo.delete(event.id);
      add(LoadCategories());
    } catch (e) {
      // ignore: avoid_print
      print('CategoryBloc._onDelete error: $e');
      emit(CategoryError('Falha ao deletar categoria'));
    }
  }
}
