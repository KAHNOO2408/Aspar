import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/debt_model.dart';
import '../models/bank_model.dart';
import '../models/payment_model.dart';

class DatabaseHelper {
  static late Box<dynamic> transactionBox;
  static late Box<dynamic> debtBox;
  static late Box<dynamic> bankBox;
  static late Box<dynamic> paymentBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    transactionBox = await Hive.openBox('transactions');
    debtBox = await Hive.openBox('debts');
    bankBox = await Hive.openBox('banks');
    paymentBox = await Hive.openBox('payments');
  }

  // Transactions
  static Future<void> insertTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction.toMap());
  }

  static Future<List<Transaction>> getTransactions() async {
    final transactions = <Transaction>[];
    for (var value in transactionBox.values) {
      transactions.add(Transaction.fromMap(Map<String, dynamic>.from(value)));
    }
    return transactions;
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction.toMap());
  }

  static Future<void> deleteTransaction(int id) async {
    await transactionBox.delete(id);
  }

  // Debts
  static Future<void> insertDebt(Debt debt) async {
    await debtBox.put(debt.id, debt.toMap());
  }

  static Future<List<Debt>> getDebts() async {
    final debts = <Debt>[];
    for (var value in debtBox.values) {
      debts.add(Debt.fromMap(Map<String, dynamic>.from(value)));
    }
    return debts;
  }

  static Future<void> updateDebt(Debt debt) async {
    await debtBox.put(debt.id, debt.toMap());
  }

  static Future<void> deleteDebt(int id) async {
    await debtBox.delete(id);
  }

  // Banks
  static Future<void> insertBank(Bank bank) async {
    await bankBox.put(bank.id, bank.toMap());
  }

  static Future<List<Bank>> getBanks() async {
    final banks = <Bank>[];
    for (var value in bankBox.values) {
      banks.add(Bank.fromMap(Map<String, dynamic>.from(value)));
    }
    return banks;
  }

  static Future<void> updateBank(Bank bank) async {
    await bankBox.put(bank.id, bank.toMap());
  }

  static Future<void> deleteBank(int id) async {
    await bankBox.delete(id);
  }

  // Payments
  static Future<void> insertPayment(Payment payment) async {
    await paymentBox.put(payment.id, payment.toMap());
  }

  static Future<List<Payment>> getPayments() async {
    final payments = <Payment>[];
    for (var value in paymentBox.values) {
      payments.add(Payment.fromMap(Map<String, dynamic>.from(value)));
    }
    return payments;
  }

  static Future<void> updatePayment(Payment payment) async {
    await paymentBox.put(payment.id, payment.toMap());
  }

  static Future<void> deletePayment(int id) async {
    await paymentBox.delete(id);
  }
}
