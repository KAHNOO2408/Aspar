import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class Bank {
  final int? id;
  final String bankName;
  final String accountNumber;
  final double balance;

  Bank({
    this.id,
    required this.bankName,
    required this.accountNumber,
    required this.balance,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bankName': bankName,
    'accountNumber': accountNumber,
    'balance': balance,
  };

  factory Bank.fromMap(Map<String, dynamic> map) => Bank(
    id: map['id'],
    bankName: map['bankName'],
    accountNumber: map['accountNumber'],
    balance: (map['balance'] as num).toDouble(),
  );
}

class BankProvider extends ChangeNotifier {
  List<Bank> _banks = [];

  List<Bank> get banks => _banks;

  BankProvider() {
    loadBanks();
  }

  Future<void> loadBanks() async {
    _banks = await DatabaseHelper.getBanks();
    notifyListeners();
  }

  Future<void> addBank(Bank bank) async {
    await DatabaseHelper.insertBank(bank);
    await loadBanks();
  }

  Future<void> updateBank(Bank bank) async {
    await DatabaseHelper.updateBank(bank);
    await loadBanks();
  }

  Future<void> deleteBank(int id) async {
    await DatabaseHelper.deleteBank(id);
    await loadBanks();
  }

  double getTotalBalance() {
    return _banks.fold(0, (sum, b) => sum + b.balance);
  }
}
