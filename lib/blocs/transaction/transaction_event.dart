import 'package:equatable/equatable.dart';
import '../../core/models/transaction_model.dart';

/// Classe base para eventos do TransactionBloc
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar todas as transações
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

/// Evento para adicionar uma nova transação
class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Evento para deletar uma transação
class DeleteTransaction extends TransactionEvent {
  final int id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

/// Evento para carregar transações de um mês específico
class LoadTransactionsByMonth extends TransactionEvent {
  final int year;
  final int month;

  const LoadTransactionsByMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}
