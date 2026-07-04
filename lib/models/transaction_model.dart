import 'package:flutter/material.dart';
import '../database/db_helper.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final int? bankId;

  Transaction({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.bankId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'date': date.toString(),
      'bankId': bankId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'],
      date: DateTime.parse(map['date']),
      bankId: map['bankId'],
    );
  }
}

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    transactions = await DatabaseHelper.getTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final toSave = transaction.id == null
        ? Transaction(
            id: DateTime.now().millisecondsSinceEpoch,
            title: transaction.title,
            description: transaction.description,
            amount: transaction.amount,
            type: transaction.type,
            category: transaction.category,
            date: transaction.date,
            bankId: transaction.bankId,
          )
        : transaction;
    await DatabaseHelper.insertTransaction(toSave);
    await loadTransactions();
  }

  Future<void> editTransaction(Transaction transaction) async {
    await DatabaseHelper.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.deleteTransaction(id);
    await loadTransactions();
  }

  double getTotalIncome(DateTime? startDate, DateTime? endDate) {
    return transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(DateTime? startDate, DateTime? endDate) {
    return transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
  }

  double getNetBalance() {
    return getTotalIncome(null, null) - getTotalExpense(null, null);
  }
}
