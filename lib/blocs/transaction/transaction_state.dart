import 'package:equatable/equatable.dart';
import '../../core/models/transaction_model.dart';

/// Classe base para estados do TransactionBloc
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial do TransactionBloc
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// Estado indicando que transações estão sendo carregadas
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Estado com a lista de transações carregadas
class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Estado indicando erro ao carregar transações
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
