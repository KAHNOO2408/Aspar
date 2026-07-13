import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';

class Bank extends HiveObject {
  int id;
  String bankName;
  String accountNumber;
  double balance;
  double cashBox;
  Bank({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.balance,
    this.cashBox = 0,
  });
  double get totalBalance => balance + cashBox;

  Map<String, dynamic> toMap() => {
        'id': id,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'balance': balance,
        'cashBox': cashBox,
      };

  factory Bank.fromMap(Map<String, dynamic> map) => Bank(
        id: map['id'],
        bankName: map['bankName'],
        accountNumber: map['accountNumber'],
        balance: (map['balance'] as num).toDouble(),
        cashBox: (map['cashBox'] ?? 0 as num).toDouble(),
      );
}

class BankAdapter extends TypeAdapter<Bank> {
  @override
  final int typeId = 0;

  @override
  Bank read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bank(
      id: fields[0] as int,
      bankName: fields[1] as String,
      accountNumber: fields[2] as String,
      balance: fields[3] as double,
      cashBox: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Bank obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.accountNumber)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.cashBox);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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
