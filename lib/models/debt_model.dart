import 'package:flutter/material.dart';
import '../database/db_helper.dart';

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
      totalAmount: (map['totalAmount'] as num).toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'] == 'owed' ? DebtType.owed : DebtType.receivable,
      paidAmount: (map['paidAmount'] ?? 0 as num).toDouble(),
    );
  }
}

class DebtProvider extends ChangeNotifier {
  List<Debt> debts = [];

  DebtProvider() {
    loadDebts();
  }

  Future<void> loadDebts() async {
    debts = await DatabaseHelper.getDebts();
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    final debtToSave = debt.id == null
        ? Debt(
            id: DateTime.now().millisecondsSinceEpoch,
            personName: debt.personName,
            personFamily: debt.personFamily,
            totalAmount: debt.totalAmount,
            description: debt.description,
            date: debt.date,
            type: debt.type,
            paidAmount: debt.paidAmount,
          )
        : debt;
    await DatabaseHelper.insertDebt(debtToSave);
    await loadDebts();
  }

  Future<void> editDebt(Debt debt) async {
    await DatabaseHelper.updateDebt(debt);
    await loadDebts();
  }

  Future<void> payDebt(int id, double amount) async {
    final index = debts.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final debt = debts[index];
    if (debt.paidAmount + amount <= debt.totalAmount) {
      debt.paidAmount += amount;
      await DatabaseHelper.updateDebt(debt);
      await loadDebts();
    }
  }

  Future<void> refundDebt(int id, double amount) async {
    final index = debts.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final debt = debts[index];
    if (debt.paidAmount >= amount) {
      debt.paidAmount -= amount;
      await DatabaseHelper.updateDebt(debt);
      await loadDebts();
    }
  }

  Future<void> deleteDebt(int id) async {
    await DatabaseHelper.deleteDebt(id);
    await loadDebts();
  }

  // تسویه‌ی واسطه‌ای بین دو مخاطب (بدون دخالت بانک)
  // reduceType = نوع بدهی/طلبی که با این پرداخت کاهش پیدا می‌کنه
  // اگه مبلغ بیشتر از بدهی/طلب موجود بود، مابه‌التفاوت به‌عنوان نوع مخالف ثبت میشه
  Future<void> applyContactPayment({
    required String personName,
    required String personFamily,
    required double amount,
    required DebtType reduceType,
    required DateTime date,
    String description = '',
  }) async {
    final oppositeType = reduceType == DebtType.owed ? DebtType.receivable : DebtType.owed;

    final targetDebts = debts
        .where((d) =>
            d.personName == personName &&
            d.personFamily == personFamily &&
            d.type == reduceType &&
            d.remainder > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double remaining = amount;
    for (final debt in targetDebts) {
      if (remaining <= 0) break;
      final offset = remaining < debt.remainder ? remaining : debt.remainder;
      debt.paidAmount += offset;
      await editDebt(debt);
      remaining -= offset;
    }

    if (remaining > 0) {
      final newDebt = Debt(
        id: DateTime.now().millisecondsSinceEpoch + personName.hashCode.abs() % 1000,
        personName: personName,
        personFamily: personFamily,
        totalAmount: remaining,
        description: description,
        date: date,
        type: oppositeType,
        paidAmount: 0,
      );
      await addDebt(newDebt);
    }
  }

  double getTotalOwed(DateTime? startDate, DateTime? endDate) {
    return debts.where((d) => d.type == DebtType.owed).fold(0.0, (sum, d) => sum + d.remainder);
  }

  double getTotalReceivable(DateTime? startDate, DateTime? endDate) {
    return debts.where((d) => d.type == DebtType.receivable).fold(0.0, (sum, d) => sum + d.remainder);
  }
}
