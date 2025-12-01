class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final int? categoryId;

  // Constructor with validation
  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.categoryId,
  }) {
    // Validate that amount is positive
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive, got: $amount');
    }
    // Validate that amount is reasonable (less than 1 billion)
    if (amount >= 1000000000) {
      throw ArgumentError('Amount seems unreasonably large: $amount');
    }
    // Validate title is not empty
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'categoryId': categoryId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      isIncome: (map['isIncome'] == 1),
      categoryId: map['categoryId'] as int?,
    );
  }
}
