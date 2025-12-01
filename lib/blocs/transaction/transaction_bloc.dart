import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../core/repositories/transaction_repository.dart';
import '../filter/filter_bloc.dart';

/// Bloc responsável por gerenciar as transações
/// Carrega, adiciona e remove transações
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository = TransactionRepository();
  final FilterBloc filterBloc;
  late final StreamSubscription _filterSub;

  /// Inicializa o Bloc com estado inicial TransactionInitial e escuta mudanças no FilterBloc
  TransactionBloc({required this.filterBloc}) : super(TransactionInitial()) {
    // Evento para carregar todas as transações
    on<LoadTransactions>(_onLoad);

    // Evento para carregar transações de um mês específico
    on<LoadTransactionsByMonth>(_onLoadByMonth);

    // Evento para adicionar uma nova transação
    on<AddTransaction>(_onAdd);

    // Evento para deletar uma transação existente
    on<DeleteTransaction>(_onDelete);

    // Recarrega transações sempre que os filtros mudarem
    _filterSub = filterBloc.stream.listen((_) {
      add(const LoadTransactions());
    });
  }

  /// Handler para o evento LoadTransactions
  Future<void> _onLoad(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading()); // Mostra o loading
    try {
      // Lê os filtros atuais e aplica na consulta
      final f = filterBloc.state;
      final list = await repository.getAllFiltered(
        isIncome: f.isIncome,
        categoryId: f.categoryId,
        start: f.startDate,
        end: f.endDate,
      );
      emit(TransactionLoaded(list)); // Emite lista carregada
    } catch (e) {
      // Em caso de erro, emite TransactionError
      emit(TransactionError('Falha ao carregar transações'));
    }
  }

  /// Handler para o evento LoadTransactionsByMonth
  Future<void> _onLoadByMonth(
    LoadTransactionsByMonth event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final list = await repository.getByMonth(event.year, event.month);
      emit(TransactionLoaded(list));
    } catch (e) {
      emit(TransactionError('Falha ao carregar transações do mês'));
    }
  }

  /// Handler para o evento AddTransaction
  Future<void> _onAdd(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.insert(event.transaction); // Insere a transação no DB
      add(const LoadTransactions()); // Recarrega a lista de transações
    } catch (e) {
      emit(TransactionError('Falha ao adicionar transação'));
    }
  }

  /// Handler para o evento DeleteTransaction
  Future<void> _onDelete(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.delete(event.id); // Deleta a transação pelo id
      add(const LoadTransactions()); // Recarrega a lista de transações
    } catch (e) {
      emit(TransactionError('Falha ao deletar transação'));
    }
  }

  @override
  Future<void> close() {
    _filterSub.cancel();
    return super.close();
  }
}
