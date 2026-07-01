import 'package:flutter/material.dart';

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

  // بعدی‌ترین تاریخ قسط
  DateTime? getNextPaymentDate() {
    DateTime nextDate = startDate.add(Duration(days: 30 * (paidMonths + 1)));
    if (nextDate.isBefore(endDate)) {
      return nextDate;
    }
    return null;
  }

  // روزهای باقی‌مانده تا قسط بعدی
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
      totalAmount: map['totalAmount'],
      monthlyPayment: map['monthlyPayment'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      bankId: map['bankId'],
      description: map['description'],
      paidAmount: map['paidAmount'] ?? 0,
    );
  }
}

class LoanProvider extends ChangeNotifier {
  List<Loan> loans = [];

  void addLoan(Loan loan) {
    loans.add(Loan(
      id: loans.isEmpty ? 1 : loans.last.id! + 1,
      bankName: loan.bankName,
      totalAmount: loan.totalAmount,
      monthlyPayment: loan.monthlyPayment,
      startDate: loan.startDate,
      endDate: loan.endDate,
      bankId: loan.bankId,
      description: loan.description,
    ));
    notifyListeners();
  }

  void payLoanInstallment(int id, double amount) {
    final loanIndex = loans.indexWhere((l) => l.id == id);
    if (loanIndex != -1) {
      loans[loanIndex].paidAmount += amount;
      notifyListeners();
    }
  }

  void deleteLoan(int id) {
    loans.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // وام‌های نزدیک به تاریخ قسط
  List<Loan> getUpcomingLoans() {
    return loans.where((loan) {
      final daysUntil = loan.getDaysUntilNextPayment();
      return daysUntil != null && daysUntil <= 7 && daysUntil > 0;
    }).toList();
  }

  // کل وام‌های باقی
  double getTotalRemainingLoans() {
    return loans.fold(0, (sum, loan) => sum + loan.remainingAmount);
  }

  // کل پرداخت‌شده
  double getTotalPaidLoans() {
    return loans.fold(0, (sum, loan) => sum + loan.paidAmount);
  }
}
