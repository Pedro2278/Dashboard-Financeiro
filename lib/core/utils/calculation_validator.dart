/// Utility class to validate financial calculations
class CalculationValidator {
  static const double _tolerance = 0.01; // Allow 1 cent tolerance

  /// Validates that balance = income - expense
  static bool isBalanceCorrect(double income, double expense, double balance) {
    final expectedBalance = income - expense;
    return (balance - expectedBalance).abs() < _tolerance;
  }

  /// Validates that all amounts are non-negative
  static bool isAmountValid(double amount) {
    return amount >= 0 && amount < 1000000000; // Less than 1 billion
  }

  /// Validates that income and expense are non-negative
  static bool areCategoryAmountsValid(Map<String, double> expenses) {
    for (final amount in expenses.values) {
      if (!isAmountValid(amount)) return false;
    }
    return true;
  }

  /// Validates that the sum of category expenses equals total expense
  static bool doExpenseCategoriesSumCorrectly(
    Map<String, double> categoryExpenses,
    double totalExpense,
  ) {
    double sum = 0;
    for (final amount in categoryExpenses.values) {
      sum += amount;
    }
    return (sum - totalExpense).abs() < _tolerance;
  }

  /// Comprehensive validation of all financial data
  static Map<String, dynamic> validateAllCalculations({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> incomeByCategory,
    required Map<String, double> expenseByCategory,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if amounts are valid
    if (!isAmountValid(totalIncome)) {
      errors.add('Invalid total income: $totalIncome');
    }
    if (!isAmountValid(totalExpense)) {
      errors.add('Invalid total expense: $totalExpense');
    }

    // Check if balance is correct
    if (!isBalanceCorrect(totalIncome, totalExpense, balance)) {
      errors.add(
        'Balance calculation error: $balance != ($totalIncome - $totalExpense)',
      );
    }

    // Check if category sums are correct
    if (expenseByCategory.isNotEmpty &&
        !doExpenseCategoriesSumCorrectly(expenseByCategory, totalExpense)) {
      final sum = expenseByCategory.values.fold(0.0, (a, b) => a + b);
      errors.add(
        'Expense categories do not sum to total: $sum != $totalExpense',
      );
    }

    if (incomeByCategory.isNotEmpty &&
        !doExpenseCategoriesSumCorrectly(incomeByCategory, totalIncome)) {
      final sum = incomeByCategory.values.fold(0.0, (a, b) => a + b);
      errors.add('Income categories do not sum to total: $sum != $totalIncome');
    }

    // Check for suspicious amounts
    if (balance < 0) {
      warnings.add('⚠️  Negative balance: $balance');
    }
    if (totalExpense > totalIncome) {
      warnings.add('⚠️  Total expenses exceed total income');
    }

    return {'isValid': errors.isEmpty, 'errors': errors, 'warnings': warnings};
  }
}
