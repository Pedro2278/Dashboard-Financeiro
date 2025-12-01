class BalanceBreakdown {
  /// Saldo disponível = transações já realizadas
  final double availableBalance;

  /// Saldo projetado = saldo disponível + transações futuras
  final double projectedBalance;

  /// Receitas realizadas
  final double realizedIncome;

  /// Despesas realizadas
  final double realizedExpense;

  /// Receitas futuras planejadas (a receber + faturas de receita)
  final double plannedIncome;

  /// Despesas futuras planejadas (a pagar + faturas)
  final double plannedExpense;

  BalanceBreakdown({
    required this.availableBalance,
    required this.projectedBalance,
    required this.realizedIncome,
    required this.realizedExpense,
    required this.plannedIncome,
    required this.plannedExpense,
  });

  /// Diferença entre saldo projetado e disponível
  double get projectionGap => projectedBalance - availableBalance;

  /// Se o saldo projetado é negativo mesmo considerando planejamento
  bool get isProjectedNegative => projectedBalance < 0;

  /// Percentual de realização das receitas planejadas
  double get incomeRealizationRate {
    final total = realizedIncome + plannedIncome;
    return total > 0 ? (realizedIncome / total) * 100 : 0;
  }

  /// Percentual de realização das despesas planejadas
  double get expenseRealizationRate {
    final total = realizedExpense + plannedExpense;
    return total > 0 ? (realizedExpense / total) * 100 : 0;
  }

  @override
  String toString() {
    return '''
BalanceBreakdown:
  Available Balance: R\$ ${availableBalance.toStringAsFixed(2)}
  Projected Balance: R\$ ${projectedBalance.toStringAsFixed(2)}
  Projection Gap: R\$ ${projectionGap.toStringAsFixed(2)}
  Realized Income: R\$ ${realizedIncome.toStringAsFixed(2)}
  Realized Expense: R\$ ${realizedExpense.toStringAsFixed(2)}
  Planned Income: R\$ ${plannedIncome.toStringAsFixed(2)}
  Planned Expense: R\$ ${plannedExpense.toStringAsFixed(2)}
''';
  }
}
