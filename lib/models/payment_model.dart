import 'package:flutter/material.dart';
import '../database/db_helper.dart';

enum PaymentType { debtPayment, receivablePayment }

class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime date;
  final String description;
  final PaymentType type;
  final int? bankId;
  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    this.bankId,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'debtId': debtId,
    'amount': amount,
    'type': type == PaymentType.debtPayment ? 'debtPayment' : 'receivablePayment',
    'description': description,
    'date': date.toIso8601String(),
    'bankId': bankId,
  };
  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
    id: map['id'],
    debtId: map['debtId'],
    amount: (map['amount'] as num).toDouble(),
    type: map['type'] == 'debtPayment' ? PaymentType.debtPayment : PaymentType.receivablePayment,
    description: map['description'],
    date: DateTime.parse(map['date']),
    bankId: map['bankId'],
  );
}

class PaymentProvider extends ChangeNotifier {
  List<Payment> payments = [];

  PaymentProvider() {
    loadPayments();
  }

  Future<void> loadPayments() async {
    payments = await DatabaseHelper.getPayments();
    notifyListeners();
  }

  Future<void> addPayment(Payment payment) async {
    final paymentToSave = payment.id == null
        ? Payment(
            id: DateTime.now().millisecondsSinceEpoch,
            debtId: payment.debtId,
            amount: payment.amount,
            date: payment.date,
            description: payment.description,
            type: payment.type,
            bankId: payment.bankId,
          )
        : payment;
    await DatabaseHelper.insertPayment(paymentToSave);
    await loadPayments();
  }

  Future<void> deletePayment(int id) async {
    await DatabaseHelper.deletePayment(id);
    await loadPayments();
  }
}
