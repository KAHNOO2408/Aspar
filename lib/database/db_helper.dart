import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/contact_model.dart';
import '../models/debt_model.dart';
import '../models/product_model.dart';
import '../models/ledger_model.dart';
import '../models/loan_model.dart';
import '../models/savings_model.dart';

class DatabaseHelper {
  static const String _dbName = 'accounting_app.db';
  static const int _dbVersion = 1;
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _createTables);
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS banks (
        id INTEGER PRIMARY KEY,
        bankName TEXT NOT NULL,
        accountNumber TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        bankId INTEGER,
        contactName TEXT,
        productInfo TEXT,
        laborFee REAL DEFAULT 0,
        ledgerEntryId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS debts (
        id INTEGER PRIMARY KEY,
        personName TEXT NOT NULL,
        personFamily TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        paidAmount REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        currentStock REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_transactions (
        id INTEGER PRIMARY KEY,
        productId INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        pricePerUnit REAL NOT NULL,
        profit REAL DEFAULT 0,
        costOfGoods REAL DEFAULT 0,
        laborFee REAL DEFAULT 0,
        contactName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ledger_entries (
        id INTEGER PRIMARY KEY,
        personName TEXT NOT NULL,
        personFamily TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        debitAmount REAL DEFAULT 0,
        creditAmount REAL DEFAULT 0,
        bankId INTEGER,
        trackingCode TEXT,
        laborFee REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS loans (
        id INTEGER PRIMARY KEY,
        bankName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        principalAmount REAL NOT NULL,
        interestPercent REAL DEFAULT 0,
        monthlyPayment REAL NOT NULL,
        months INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        bankId INTEGER,
        description TEXT,
        paidAmount REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_goals (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        targetAmount REAL NOT NULL,
        currentAmount REAL DEFAULT 0,
        createdDate TEXT NOT NULL,
        targetDate TEXT
      )
    ''');
  }

  // ============ BANKS ============
  static Future<void> insertBank(Bank bank) async {
    final db = await database;
    await db.insert('banks', bank.toMap());
  }

  static Future<void> updateBank(Bank bank) async {
    final db = await database;
    await db.update('banks', bank.toMap(), where: 'id = ?', whereArgs: [bank.id]);
  }

  static Future<void> deleteBank(int id) async {
    final db = await database;
    await db.delete('banks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Bank>> getBanks() async {
    final db = await database;
    final data = await db.query('banks');
    return data.map((map) => Bank.fromMap(map)).toList();
  }

  // ============ TRANSACTIONS ============
  static Future<void> insertTransaction(Transaction trans) async {
    final db = await database;
    await db.insert('transactions', trans.toMap());
  }

  static Future<void> updateTransaction(Transaction trans) async {
    final db = await database;
    await db.update('transactions', trans.toMap(), where: 'id = ?', whereArgs: [trans.id]);
  }

  static Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final data = await db.query('transactions', orderBy: 'date DESC');
    return data.map((map) => Transaction.fromMap(map)).toList();
  }

  // ============ CONTACTS ============
  static Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
  }

  static Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update('contacts', contact.toMap(), where: 'id = ?', whereArgs: [contact.id]);
  }

  static Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Contact>> getContacts() async {
    final db = await database;
    final data = await db.query('contacts', orderBy: 'firstName ASC');
    return data.map((map) => Contact.fromMap(map)).toList();
  }

  // ============ DEBTS ============
  static Future<void> insertDebt(Debt debt) async {
    final db = await database;
    await db.insert('debts', debt.toMap());
  }

  static Future<void> updateDebt(Debt debt) async {
    final db = await database;
    await db.update('debts', debt.toMap(), where: 'id = ?', whereArgs: [debt.id]);
  }

  static Future<void> deleteDebt(int id) async {
    final db = await database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Debt>> getDebts() async {
    final db = await database;
    final data = await db.query('debts', orderBy: 'date DESC');
    return data.map((map) => Debt.fromMap(map)).toList();
  }

  // ============ PRODUCTS ============
  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
  }

  static Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  static Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final data = await db.query('products', orderBy: 'name ASC');
    return data.map((map) => Product.fromMap(map)).toList();
  }

  // ============ PRODUCT TRANSACTIONS ============
  static Future<void> insertProductTransaction(ProductTransaction pt) async {
    final db = await database;
    await db.insert('product_transactions', pt.toMap());
  }

  static Future<List<ProductTransaction>> getProductTransactions() async {
    final db = await database;
    final data = await db.query('product_transactions', orderBy: 'date DESC');
    return data.map((map) => ProductTransaction.fromMap(map)).toList();
  }

  // ============ LEDGER ENTRIES ============
  static Future<void> insertLedgerEntry(LedgerEntry entry) async {
    final db = await database;
    await db.insert('ledger_entries', entry.toMap());
  }

  static Future<void> updateLedgerEntry(LedgerEntry entry) async {
    final db = await database;
    await db.update('ledger_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  static Future<void> deleteLedgerEntry(int id) async {
    final db = await database;
    await db.delete('ledger_entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<LedgerEntry>> getLedgerEntries() async {
    final db = await database;
    final data = await db.query('ledger_entries', orderBy: 'date DESC');
    return data.map((map) => LedgerEntry.fromMap(map)).toList();
  }

  // ============ LOANS ============
  static Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert('loans', loan.toMap());
  }

  static Future<void> updateLoan(Loan loan) async {
    final db = await database;
    await db.update('loans', loan.toMap(), where: 'id = ?', whereArgs: [loan.id]);
  }

  static Future<void> deleteLoan(int id) async {
    final db = await database;
    await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Loan>> getLoans() async {
    final db = await database;
    final data = await db.query('loans', orderBy: 'startDate DESC');
    return data.map((map) => Loan.fromMap(map)).toList();
  }

  // ============ SAVINGS GOALS ============
  static Future<void> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    await db.insert('savings_goals', goal.toMap());
  }

  static Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    await db.update('savings_goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  static Future<void> deleteSavingsGoal(int id) async {
    final db = await database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<SavingsGoal>> getSavingsGoals() async {
    final db = await database;
    final data = await db.query('savings_goals', orderBy: 'createdDate DESC');
    return data.map((map) => SavingsGoal.fromMap(map)).toList();
  }
}
