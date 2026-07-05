import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class Loan {
  final int? id;
  final String bankName;
  final double totalAmount;
  final double monthlyPayment;
  final DateTime startDate;
  final DateTime endDate;
  final int bankId;
  final String description;
  double paidAmount;

  Loan({
    this.id,
    required this.bankName,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.startDate,
    required this.endDate,
    required this.bankId,
    required this.description,
    this.paidAmount = 0,
  });

  double get remainingAmount => totalAmount - paidAmount;

  int get totalMonths => ((endDate.year - startDate.year) * 12) + (endDate.month - startDate.month);

  int get paidMonths => (paidAmount / monthlyPayment).floor();

  int get remainingMonths => totalMonths - paidMonths;

  DateTime? getNextPaymentDate() {
    DateTime nextDate = startDate.add(Duration(days: 30 * (paidMonths + 1)));
    if (nextDate.isBefore(endDate)) {
      return nextDate;
    }
    return null;
  }

  int? getDaysUntilNextPayment() {
    final nextDate = getNextPaymentDate();
    if (nextDate != null) {
      return nextDate.difference(DateTime.now()).inDays;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'totalAmount': totalAmount,
      'monthlyPayment': monthlyPayment,
      'startDate': startDate.toString(),
      'endDate': endDate.toString(),
      'bankId': bankId,
      'description': description,
      'paidAmount': paidAmount,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      bankName: map['bankName'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      monthlyPayment: (map['monthlyPayment'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      bankId: map['bankId'],
      description: map['description'],
      paidAmount: (map['paidAmount'] ?? 0 as num).toDouble(),
    );
  }
}

class LoanProvider extends ChangeNotifier {
  List<Loan> loans = [];

  LoanProvider() {
    loadLoans();
  }

  Future<void> loadLoans() async {
    loans = await DatabaseHelper.getLoans();
    notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    final toSave = loan.id == null
        ? Loan(
            id: DateTime.now().millisecondsSinceEpoch,
            bankName: loan.bankName,
            totalAmount: loan.totalAmount,
            monthlyPayment: loan.monthlyPayment,
            startDate: loan.startDate,
            endDate: loan.endDate,
            bankId: loan.bankId,
            description: loan.description,
            paidAmount: loan.paidAmount,
          )
        : loan;
    await DatabaseHelper.insertLoan(toSave);
    await loadLoans();
  }

  Future<void> payLoanInstallment(int id, double amount) async {
    final loanIndex = loans.indexWhere((l) => l.id == id);
    if (loanIndex != -1) {
      loans[loanIndex].paidAmount += amount;
      await DatabaseHelper.updateLoan(loans[loanIndex]);
      await loadLoans();
    }
  }

  Future<void> deleteLoan(int id) async {
    await DatabaseHelper.deleteLoan(id);
    await loadLoans();
  }

  List<Loan> getUpcomingLoans() {
    return loans.where((loan) {
      final daysUntil = loan.getDaysUntilNextPayment();
      return daysUntil != null && daysUntil <= 7 && daysUntil > 0;
    }).toList();
  }

  double getTotalRemainingLoans() {
    return loans.fold(0, (sum, loan) => sum + loan.remainingAmount);
  }

  double getTotalPaidLoans() {
    return loans.fold(0, (sum, loan) => sum + loan.paidAmount);
  }
}
