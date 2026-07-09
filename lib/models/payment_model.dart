import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 9;

  @override
  Payment read(BinaryReader reader) {
    return Payment(
      id: reader.read() as int?,
      debtId: reader.read() as int,
      amount: reader.read() as double,
      date: reader.read() as DateTime,
      description: reader.read() as String,
      type: PaymentType.values[reader.readByte()],
      bankId: reader.read() as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer.write(obj.id);
    writer.write(obj.debtId);
    writer.write(obj.amount);
    writer.write(obj.date);
    writer.write(obj.description);
    writer.writeByte(obj.type.index);
    writer.write(obj.bankId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaymentAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
