import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/db_helper.dart';

class Loan {
  final int? id;
  final String bankName;
  final double totalAmount;
  final double principalAmount;
  final double interestPercent;
  final double monthlyPayment;
  final int months;
  final DateTime startDate;
  final DateTime endDate;
  final int bankId;
  final String description;
  double paidAmount;

  Loan({
    this.id,
    required this.bankName,
    required this.totalAmount,
    this.principalAmount = 0,
    this.interestPercent = 0,
    required this.monthlyPayment,
    this.months = 0,
    required this.startDate,
    required this.endDate,
    required this.bankId,
    required this.description,
    this.paidAmount = 0,
  });

  double get remainingAmount => totalAmount - paidAmount;

  int get totalMonths => months > 0 ? months : (((endDate.year - startDate.year) * 12) + (endDate.month - startDate.month));

  int get paidMonths => monthlyPayment > 0 ? (paidAmount / monthlyPayment).floor() : 0;

  int get remainingMonths => totalMonths - paidMonths;

  DateTime? getNextPaymentDate() {
    final nextDate = DateTime(startDate.year, startDate.month + paidMonths + 1, startDate.day);
    if (nextDate.isBefore(endDate) || nextDate.isAtSameMomentAs(endDate)) {
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
      'principalAmount': principalAmount,
      'interestPercent': interestPercent,
      'monthlyPayment': monthlyPayment,
      'months': months,
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
      principalAmount: (map['principalAmount'] ?? 0 as num).toDouble(),
      interestPercent: (map['interestPercent'] ?? 0 as num).toDouble(),
      monthlyPayment: (map['monthlyPayment'] as num).toDouble(),
      months: map['months'] ?? 0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      bankId: map['bankId'],
      description: map['description'],
      paidAmount: (map['paidAmount'] ?? 0 as num).toDouble(),
    );
  }
}

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 7;

  @override
  Loan read(BinaryReader reader) {
    return Loan(
      id: reader.read() as int?,
      bankName: reader.read() as String,
      totalAmount: reader.read() as double,
      principalAmount: reader.read() as double,
      interestPercent: reader.read() as double,
      monthlyPayment: reader.read() as double,
      months: reader.read() as int,
      startDate: reader.read() as DateTime,
      endDate: reader.read() as DateTime,
      bankId: reader.read() as int,
      description: reader.read() as String,
      paidAmount: reader.read() as double,
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer.write(obj.id);
    writer.write(obj.bankName);
    writer.write(obj.totalAmount);
    writer.write(obj.principalAmount);
    writer.write(obj.interestPercent);
    writer.write(obj.monthlyPayment);
    writer.write(obj.months);
    writer.write(obj.startDate);
    writer.write(obj.endDate);
    writer.write(obj.bankId);
    writer.write(obj.description);
    writer.write(obj.paidAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LoanAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
            principalAmount: loan.principalAmount,
            interestPercent: loan.interestPercent,
            monthlyPayment: loan.monthlyPayment,
            months: loan.months,
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

  Future<void> editLoan(Loan loan) async {
    await DatabaseHelper.updateLoan(loan);
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
