enum TransactionType {
  /// Transação concretizada/realizada
  completed,

  /// Conta a pagar - despesa futura planejada
  billToPay,

  /// Conta a receber - receita futura planejada
  billToReceive,

  /// Fatura - despesa futura vinculada (cartão de crédito, etc)
  invoice;

  String get label {
    switch (this) {
      case TransactionType.completed:
        return 'Realizada';
      case TransactionType.billToPay:
        return 'Conta a Pagar';
      case TransactionType.billToReceive:
        return 'Conta a Receber';
      case TransactionType.invoice:
        return 'Fatura';
    }
  }

  String get shortLabel {
    switch (this) {
      case TransactionType.completed:
        return 'Realizada';
      case TransactionType.billToPay:
        return 'A Pagar';
      case TransactionType.billToReceive:
        return 'A Receber';
      case TransactionType.invoice:
        return 'Fatura';
    }
  }

  bool get isFuture {
    return this != TransactionType.completed;
  }

  bool get isPlanned {
    return this != TransactionType.completed;
  }
}
