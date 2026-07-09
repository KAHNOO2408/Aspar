import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  final String? contactName;
  final String? productInfo;
  final double laborFee;
  final int? ledgerEntryId;

  Transaction({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.bankId,
    this.contactName,
    this.productInfo,
    this.laborFee = 0,
    this.ledgerEntryId,
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
      'contactName': contactName,
      'productInfo': productInfo,
      'laborFee': laborFee,
      'ledgerEntryId': ledgerEntryId,
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
      contactName: map['contactName'],
      productInfo: map['productInfo'],
      laborFee: (map['laborFee'] ?? 0 as num).toDouble(),
      ledgerEntryId: map['ledgerEntryId'],
    );
  }
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      id: reader.read() as int?,
      title: reader.read() as String,
      description: reader.read() as String,
      amount: reader.read() as double,
      type: TransactionType.values[reader.readByte()],
      category: reader.read() as String,
      date: reader.read() as DateTime,
      bankId: reader.read() as int?,
      contactName: reader.read() as String?,
      productInfo: reader.read() as String?,
      laborFee: reader.read() as double,
      ledgerEntryId: reader.read() as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.amount);
    writer.writeByte(obj.type.index);
    writer.write(obj.category);
    writer.write(obj.date);
    writer.write(obj.bankId);
    writer.write(obj.contactName);
    writer.write(obj.productInfo);
    writer.write(obj.laborFee);
    writer.write(obj.ledgerEntryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransactionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
            contactName: transaction.contactName,
            productInfo: transaction.productInfo,
            laborFee: transaction.laborFee,
            ledgerEntryId: transaction.ledgerEntryId,
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
