import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/debt_model.dart';
import '../models/bank_model.dart';
import '../models/payment_model.dart';
import '../models/product_model.dart';
import '../models/ledger_model.dart';
import '../models/contact_model.dart';
import '../models/loan_model.dart';

class DatabaseHelper {
  static late Box<dynamic> transactionBox;
  static late Box<dynamic> debtBox;
  static late Box<dynamic> bankBox;
  static late Box<dynamic> paymentBox;
  static late Box<dynamic> authBox;
  static late Box<dynamic> productBox;
  static late Box<dynamic> productBatchBox;
  static late Box<dynamic> productTransactionBox;
  static late Box<dynamic> ledgerBox;
  static late Box<dynamic> contactBox;
  static late Box<dynamic> loanBox;

  static Future<void> init() async {
    if (!Hive.isBoxOpen('transactions')) {
      transactionBox = await Hive.openBox('transactions');
    } else {
      transactionBox = Hive.box('transactions');
    }

    if (!Hive.isBoxOpen('debts')) {
      debtBox = await Hive.openBox('debts');
    } else {
      debtBox = Hive.box('debts');
    }

    if (!Hive.isBoxOpen('banks')) {
      bankBox = await Hive.openBox('banks');
    } else {
      bankBox = Hive.box('banks');
    }

    if (!Hive.isBoxOpen('payments')) {
      paymentBox = await Hive.openBox('payments');
    } else {
      paymentBox = Hive.box('payments');
    }

    if (!Hive.isBoxOpen('auth')) {
      authBox = await Hive.openBox('auth');
    } else {
      authBox = Hive.box('auth');
    }

    if (!Hive.isBoxOpen('products')) {
      productBox = await Hive.openBox('products');
    } else {
      productBox = Hive.box('products');
    }

    if (!Hive.isBoxOpen('productBatches')) {
      productBatchBox = await Hive.openBox('productBatches');
    } else {
      productBatchBox = Hive.box('productBatches');
    }

    if (!Hive.isBoxOpen('productTransactions')) {
      productTransactionBox = await Hive.openBox('productTransactions');
    } else {
      productTransactionBox = Hive.box('productTransactions');
    }

    if (!Hive.isBoxOpen('ledger')) {
      ledgerBox = await Hive.openBox('ledger');
    } else {
      ledgerBox = Hive.box('ledger');
    }

    if (!Hive.isBoxOpen('contacts')) {
      contactBox = await Hive.openBox('contacts');
    } else {
      contactBox = Hive.box('contacts');
    }

    if (!Hive.isBoxOpen('loans')) {
      loanBox = await Hive.openBox('loans');
    } else {
      loanBox = Hive.box('loans');
    }
  }

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

  static Future<void> updateProduct(Product product) async {
    await productBox.put(product.id, product.toMap());
  }

  static Future<List<Product>> getProducts() async {
    final products = <Product>[];
    for (var value in productBox.values) {
      products.add(Product.fromMap(Map<String, dynamic>.from(value)));
    }
    return products;
  }

  static Future<void> insertProductBatch(ProductBatch batch) async {
    await productBatchBox.put(batch.id, batch.toMap());
  }

  static Future<List<ProductBatch>> getProductBatches() async {
    final batches = <ProductBatch>[];
    for (var value in productBatchBox.values) {
      batches.add(ProductBatch.fromMap(Map<String, dynamic>.from(value)));
    }
    return batches;
  }

  static Future<void> updateProductBatch(ProductBatch batch) async {
    await productBatchBox.put(batch.id, batch.toMap());
  }

  static Future<void> insertProductTransaction(ProductTransaction tx) async {
    await productTransactionBox.put(tx.id, tx.toMap());
  }

  static Future<List<ProductTransaction>> getProductTransactions() async {
    final txs = <ProductTransaction>[];
    for (var value in productTransactionBox.values) {
      txs.add(ProductTransaction.fromMap(Map<String, dynamic>.from(value)));
    }
    return txs;
  }

  static Future<void> insertLedgerEntry(LedgerEntry entry) async {
    await ledgerBox.put(entry.id, entry.toMap());
  }

  static Future<List<LedgerEntry>> getLedgerEntries() async {
    final entries = <LedgerEntry>[];
    for (var value in ledgerBox.values) {
      entries.add(LedgerEntry.fromMap(Map<String, dynamic>.from(value)));
    }
    return entries;
  }

  static Future<void> updateLedgerEntry(LedgerEntry entry) async {
    await ledgerBox.put(entry.id, entry.toMap());
  }

  static Future<void> deleteLedgerEntry(int id) async {
    await ledgerBox.delete(id);
  }

  static Future<void> insertContact(Contact contact) async {
    await contactBox.put(contact.id, contact.toMap());
  }

  static Future<List<Contact>> getContacts() async {
    final contacts = <Contact>[];
    for (var value in contactBox.values) {
      contacts.add(Contact.fromMap(Map<String, dynamic>.from(value)));
    }
    return contacts;
  }

  static Future<void> updateContact(Contact contact) async {
    await contactBox.put(contact.id, contact.toMap());
  }

  static Future<void> deleteContact(int id) async {
    await contactBox.delete(id);
  }

  static Future<void> insertLoan(Loan loan) async {
    await loanBox.put(loan.id, loan.toMap());
  }

  static Future<List<Loan>> getLoans() async {
    final loans = <Loan>[];
    for (var value in loanBox.values) {
      loans.add(Loan.fromMap(Map<String, dynamic>.from(value)));
    }
    return loans;
  }

  static Future<void> updateLoan(Loan loan) async {
    await loanBox.put(loan.id, loan.toMap());
  }

  static Future<void> deleteLoan(int id) async {
    await loanBox.delete(id);
  }
}
