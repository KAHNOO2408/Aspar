import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final int? bankId; // بانک

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
      amount: map['amount'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'],
      date: DateTime.parse(map['date']),
      bankId: map['bankId'],
    );
  }
}

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];

  void addTransaction(Transaction transaction) {
    transactions.add(Transaction(
      id: transactions.isEmpty ? 1 : transactions.last.id! + 1,
      title: transaction.title,
      description: transaction.description,
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      date: transaction.date,
      bankId: transaction.bankId,
    ));
    notifyListeners();
  }

  void deleteTransaction(int id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double getTotalIncome(DateTime? startDate, DateTime? endDate) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(DateTime? startDate, DateTime? endDate) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getNetBalance() {
    return getTotalIncome(null, null) - getTotalExpense(null, null);
  }
}
