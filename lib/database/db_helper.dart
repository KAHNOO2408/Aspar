import 'package:hive_flutter/hive_flutter.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/contact_model.dart';
import '../models/debt_model.dart';
import '../models/product_model.dart';
import '../models/ledger_model.dart';
import '../models/loan_model.dart';
import '../models/savings_model.dart';
import '../models/payment_model.dart';

class DatabaseHelper {
  static late Box<Bank> bankBox;
  static late Box<Transaction> transactionBox;
  static late Box<Contact> contactBox;
  static late Box<Debt> debtBox;
  static late Box<Product> productBox;
  static late Box<ProductTransaction> productTransactionBox;
  static late Box<LedgerEntry> ledgerEntryBox;
  static late Box<Loan> loanBox;
  static late Box<SavingsGoal> savingsGoalBox;
  static late Box<Payment> paymentBox;
  static late Box<ProductBatch> productBatchBox;
  static late Box authBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BankAdapter());
    }

    bankBox = await Hive.openBox<Bank>('banks');
    transactionBox = await Hive.openBox<Transaction>('transactions');
    contactBox = await Hive.openBox<Contact>('contacts');
    debtBox = await Hive.openBox<Debt>('debts');
    productBox = await Hive.openBox<Product>('products');
    productTransactionBox = await Hive.openBox<ProductTransaction>('productTransactions');
    ledgerEntryBox = await Hive.openBox<LedgerEntry>('ledgerEntries');
    loanBox = await Hive.openBox<Loan>('loans');
    savingsGoalBox = await Hive.openBox<SavingsGoal>('savingsGoals');
    paymentBox = await Hive.openBox<Payment>('payments');
    productBatchBox = await Hive.openBox<ProductBatch>('productBatches');
    authBox = await Hive.openBox('auth');
  }

  // ============ BANKS ============
  static Future<void> insertBank(Bank bank) async {
    await bankBox.put(bank.id, bank);
  }

  static Future<void> updateBank(Bank bank) async {
    await bankBox.put(bank.id, bank);
  }

  static Future<void> deleteBank(int id) async {
    await bankBox.delete(id);
  }

  static Future<List<Bank>> getBanks() async {
    return bankBox.values.toList();
  }

  // ============ TRANSACTIONS ============
  static Future<void> insertTransaction(Transaction trans) async {
    await transactionBox.put(trans.id, trans);
  }

  static Future<void> updateTransaction(Transaction trans) async {
    await transactionBox.put(trans.id, trans);
  }

  static Future<void> deleteTransaction(int id) async {
    await transactionBox.delete(id);
  }

  static Future<List<Transaction>> getTransactions() async {
    return transactionBox.values.toList();
  }

  // ============ CONTACTS ============
  static Future<void> insertContact(Contact contact) async {
    await contactBox.put(contact.id, contact);
  }

  static Future<void> updateContact(Contact contact) async {
    await contactBox.put(contact.id, contact);
  }

  static Future<void> deleteContact(int id) async {
    await contactBox.delete(id);
  }

  static Future<List<Contact>> getContacts() async {
    return contactBox.values.toList();
  }

  // ============ DEBTS ============
  static Future<void> insertDebt(Debt debt) async {
    await debtBox.put(debt.id, debt);
  }

  static Future<void> updateDebt(Debt debt) async {
    await debtBox.put(debt.id, debt);
  }

  static Future<void> deleteDebt(int id) async {
    await debtBox.delete(id);
  }

  static Future<List<Debt>> getDebts() async {
    return debtBox.values.toList();
  }

  // ============ PRODUCTS ============
  static Future<void> insertProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  static Future<void> updateProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  static Future<void> deleteProduct(int id) async {
    await productBox.delete(id);
  }

  static Future<List<Product>> getProducts() async {
    return productBox.values.toList();
  }

  // ============ PRODUCT TRANSACTIONS ============
  static Future<void> insertProductTransaction(ProductTransaction pt) async {
    await productTransactionBox.put(pt.id, pt);
  }

  static Future<List<ProductTransaction>> getProductTransactions() async {
    return productTransactionBox.values.toList();
  }

  // ============ LEDGER ENTRIES ============
  static Future<void> insertLedgerEntry(LedgerEntry entry) async {
    await ledgerEntryBox.put(entry.id, entry);
  }

  static Future<void> updateLedgerEntry(LedgerEntry entry) async {
    await ledgerEntryBox.put(entry.id, entry);
  }

  static Future<void> deleteLedgerEntry(int id) async {
    await ledgerEntryBox.delete(id);
  }

  static Future<List<LedgerEntry>> getLedgerEntries() async {
    return ledgerEntryBox.values.toList();
  }

  // ============ LOANS ============
  static Future<void> insertLoan(Loan loan) async {
    await loanBox.put(loan.id, loan);
  }

  static Future<void> updateLoan(Loan loan) async {
    await loanBox.put(loan.id, loan);
  }

  static Future<void> deleteLoan(int id) async {
    await loanBox.delete(id);
  }

  static Future<List<Loan>> getLoans() async {
    return loanBox.values.toList();
  }

  // ============ SAVINGS GOALS ============
  static Future<void> insertSavingsGoal(SavingsGoal goal) async {
    await savingsGoalBox.put(goal.id, goal);
  }

  static Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await savingsGoalBox.put(goal.id, goal);
  }

  static Future<void> deleteSavingsGoal(int id) async {
    await savingsGoalBox.delete(id);
  }

  static Future<List<SavingsGoal>> getSavingsGoals() async {
    return savingsGoalBox.values.toList();
  }

  // ============ PAYMENTS ============
  static Future<void> insertPayment(Payment payment) async {
    await paymentBox.put(payment.id, payment);
  }

  static Future<void> deletePayment(int id) async {
    await paymentBox.delete(id);
  }

  static Future<List<Payment>> getPayments() async {
    return paymentBox.values.toList();
  }

  // ============ PRODUCT BATCHES ============
  static Future<void> insertProductBatch(ProductBatch batch) async {
    await productBatchBox.put(batch.id, batch);
  }

  static Future<void> updateProductBatch(ProductBatch batch) async {
    await productBatchBox.put(batch.id, batch);
  }

  static Future<List<ProductBatch>> getProductBatches() async {
    return productBatchBox.values.toList();
  }
}
