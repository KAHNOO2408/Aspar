import 'package:flutter/material.dart';

enum PaymentType { debtPayment, receivablePayment }

class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime date;
  final String description;
  final PaymentType type;

  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'debtId': debtId,
    'amount': amount,
    'type': type == PaymentType.debtPayment ? 'debtPayment' : 'receivablePayment',
    'description': description,
    'date': date.toIso8601String(),
  };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
    id: map['id'],
    debtId: map['debtId'],
    amount: (map['amount'] as num).toDouble(),
    type: map['type'] == 'debtPayment' ? PaymentType.debtPayment : PaymentType.receivablePayment,
    description: map['description'],
    date: DateTime.parse(map['date']),
  );
}
