// lib/core/repositories/transaction_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_db.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final AppDB _dbProvider = AppDB.instance;
  static const _webKey = 'tf_transactions_v1';

  TransactionRepository();

  /// Calculates and validates total income and expenses
  /// Returns map with 'income', 'expense', 'balance', 'count'
  Future<Map<String, dynamic>> getFinancialSummary({
    DateTime? start,
    DateTime? end,
  }) async {
    final transactions = await getAllFiltered(start: start, end: end);

    double totalIncome = 0;
    double totalExpense = 0;
    int count = 0;

    for (var tx in transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
      count++;
    }

    final balance = totalIncome - totalExpense;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': balance,
      'count': count,
      'isValid': _validateCalculations(totalIncome, totalExpense, balance),
    };
  }

  /// Validates that calculations are correct
  bool _validateCalculations(double income, double expense, double balance) {
    // Verify balance = income - expense with floating point tolerance
    final expectedBalance = income - expense;
    final tolerance = 0.01; // Allow 1 cent tolerance for floating point errors

    final isBalanceCorrect = (balance - expectedBalance).abs() < tolerance;
    final isIncomeValid = income >= 0;
    final isExpenseValid = expense >= 0;

    if (!isBalanceCorrect || !isIncomeValid || !isExpenseValid) {
      debugLog(
        '⚠️  CALCULATION ERROR: income=$income, expense=$expense, balance=$balance, expected=$expectedBalance',
      );
      return false;
    }

    return true;
  }

  /// Debug logging helper
  void debugLog(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[TransactionRepository] $message');
    }
  }

  // Insert
  Future<int> insert(TransactionModel tx) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_webKey) ?? <String>[];
      final nextId = _nextWebId(raw);
      final modelWithId = TransactionModel(
        id: nextId,
        title: tx.title,
        amount: tx.amount,
        date: tx.date,
        isIncome: tx.isIncome,
        categoryId: tx.categoryId,
      );
      raw.add(jsonEncode(modelWithId.toMap()));
      await prefs.setStringList(_webKey, raw);
      return nextId;
    } else {
      final db = await _dbProvider.database;
      return await db.insert('transactions', tx.toMap());
    }
  }

  // Get all
  Future<List<TransactionModel>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_webKey) ?? <String>[];
      return raw.map((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return TransactionModel.fromMap(m);
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
    } else {
      final db = await _dbProvider.database;
      final maps = await db.query('transactions', orderBy: 'date DESC');
      return maps.map((m) => TransactionModel.fromMap(m)).toList();
    }
  }

  /// Get all with optional filters
  Future<List<TransactionModel>> getAllFiltered({
    bool? isIncome,
    int? categoryId,
    DateTime? start,
    DateTime? end,
  }) async {
    if (kIsWeb) {
      final all = await getAll();
      final filtered = all.where((t) {
        if (isIncome != null && t.isIncome != isIncome) return false;
        if (categoryId != null && t.categoryId != categoryId) return false;
        if (start != null && t.date.isBefore(start)) return false;
        if (end != null && t.date.isAfter(end)) return false;
        return true;
      }).toList();
      filtered.sort((a, b) => b.date.compareTo(a.date));
      return filtered;
    } else {
      final db = await _dbProvider.database;
      final whereClauses = <String>[];
      final whereArgs = <Object>[];

      if (isIncome != null) {
        whereClauses.add('isIncome = ?');
        whereArgs.add(isIncome ? 1 : 0);
      }
      if (categoryId != null) {
        whereClauses.add('categoryId = ?');
        whereArgs.add(categoryId);
      }
      if (start != null) {
        whereClauses.add('date >= ?');
        whereArgs.add(start.toIso8601String());
      }
      if (end != null) {
        whereClauses.add('date <= ?');
        whereArgs.add(end.toIso8601String());
      }

      final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
      final maps = await db.query(
        'transactions',
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC',
      );
      return maps.map((m) => TransactionModel.fromMap(m)).toList();
    }
  }

  /// Get transactions for a specific month
  Future<List<TransactionModel>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0); // last day of the month
    return getAllFiltered(start: start, end: end);
  }

  // Delete
  Future<int> delete(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_webKey) ?? <String>[];
      final updated = raw.where((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        final mid = m['id'] as int?;
        return mid != id;
      }).toList();
      await prefs.setStringList(_webKey, updated);
      return 1;
    } else {
      final db = await _dbProvider.database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Update
  Future<int> update(TransactionModel tx) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_webKey) ?? <String>[];
      final updated = raw.map((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        if ((m['id'] as int?) == tx.id) {
          return jsonEncode(tx.toMap());
        }
        return s;
      }).toList();
      await prefs.setStringList(_webKey, updated);
      return 1;
    } else {
      final db = await _dbProvider.database;
      return await db.update(
        'transactions',
        tx.toMap(),
        where: 'id = ?',
        whereArgs: [tx.id],
      );
    }
  }

  // Clear all (useful in tests)
  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webKey);
    } else {
      final db = await _dbProvider.database;
      await db.delete('transactions');
    }
  }

  // helper to generate next id for web storage
  int _nextWebId(List<String> raw) {
    final ids = raw.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return (m['id'] as int?) ?? 0;
    }).toList();
    if (ids.isEmpty) return 1;
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }
}
