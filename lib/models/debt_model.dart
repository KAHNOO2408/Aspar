import 'package:flutter/material.dart';

enum DebtType { owed, receivable }

class Debt {
  final int? id;
  final String personName;
  final String personFamily;
  final double totalAmount;
  final String description;
  final DateTime date;
  final DebtType type;
  double paidAmount;

  Debt({
    this.id,
    required this.personName,
    required this.personFamily,
    required this.totalAmount,
    required this.description,
    required this.date,
    required this.type,
    this.paidAmount = 0,
  });

  double get remainder => totalAmount - paidAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'personFamily': personFamily,
      'totalAmount': totalAmount,
      'description': description,
      'date': date.toString(),
      'type': type == DebtType.owed ? 'owed' : 'receivable',
      'paidAmount': paidAmount,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      personName: map['personName'],
      personFamily: map['personFamily'],
      totalAmount: map['totalAmount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'] == 'owed' ? DebtType.owed : DebtType.receivable,
      paidAmount: map['paidAmount'] ?? 0,
    );
  }
}

class DebtProvider extends ChangeNotifier {
  List<Debt> debts = [];

  void addDebt(Debt debt) {
    debt.id == null ? debts.add(Debt(
      id: debts.isEmpty ? 1 : debts.last.id! + 1,
      personName: debt.personName,
      personFamily: debt.personFamily,
      totalAmount: debt.totalAmount,
      description: debt.description,
      date: debt.date,
      type: debt.type,
      paidAmount: 0,
    )) : debts.add(debt);
    notifyListeners();
  }

  void payDebt(int id, double amount) {
    final debt = debts.firstWhere((d) => d.id == id);
    if (debt.paidAmount + amount <= debt.totalAmount) {
      debt.paidAmount += amount;
      notifyListeners();
    }
  }

  void refundDebt(int id, double amount) {
    final debt = debts.firstWhere((d) => d.id == id);
    if (debt.paidAmount >= amount) {
      debt.paidAmount -= amount;
      notifyListeners();
    }
  }

  void deleteDebt(int id) {
    debts.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  double getTotalOwed(DateTime? startDate, DateTime? endDate) {
    return debts
        .where((d) => d.type == DebtType.owed)
        .fold(0.0, (sum, d) => sum + d.remainder);
  }

  double getTotalReceivable(DateTime? startDate, DateTime? endDate) {
    return debts
        .where((d) => d.type == DebtType.receivable)
        .fold(0.0, (sum, d) => sum + d.remainder);
  }
}
