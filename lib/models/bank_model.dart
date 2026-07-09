import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';

@HiveType(typeId: 0)
class Bank extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String bankName;
  @HiveField(2)
  String accountNumber;
  @HiveField(3)
  double balance;
  @HiveField(4)
  double cashBox;
  Bank({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.balance,
    this.cashBox = 0,
  });
  double get totalBalance => balance + cashBox;
}
class BankProvider extends ChangeNotifier {
  List<Bank> banks = [];
  BankProvider() {
    loadBanks();
  }
  Future<void> loadBanks() async {
    banks = DatabaseHelper.bankBox.values.toList();
    notifyListeners();
  }
  Future<void> insertBank(Bank bank) async {
    await DatabaseHelper.bankBox.put(bank.id, bank);
    banks = DatabaseHelper.bankBox.values.toList();
    notifyListeners();
  }
  Future<void> updateBank(Bank bank) async {
    await DatabaseHelper.bankBox.put(bank.id, bank);
    banks = DatabaseHelper.bankBox.values.toList();
    notifyListeners();
  }
  Future<void> deleteBank(int id) async {
    await DatabaseHelper.bankBox.delete(id);
    banks = DatabaseHelper.bankBox.values.toList();
    notifyListeners();
  }
  double getTotalBalance() {
    return banks.fold(0.0, (sum, bank) => sum + bank.balance);
  }
  double getTotalCashBox() {
    return banks.fold(0.0, (sum, bank) => sum + bank.cashBox);
  }
  double getTotalBalanceWithCashBox() {
    return banks.fold(0.0, (sum, bank) => sum + bank.totalBalance);
  }
}
