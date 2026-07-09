import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/db_helper.dart';

class BackupService {
  // این اسم‌ها دقیقاً باید با اسم باکس‌هایی که DatabaseHelper.init() باز می‌کنه یکی باشن
  static const List<String> boxNames = [
    'banks',
    'transactions',
    'contacts',
    'debts',
    'products',
    'productBatches',
    'productTransactions',
    'ledgerEntries',
    'loans',
    'savingsGoals',
    'payments',
    'auth',
  ];

  // این باکس‌ها موقع «پاک کردن تمام داده‌ها» دست‌نخورده می‌مونن
  // (رمز ورود و تنظیمات امنیتی) تا از حساب پرت نشی
  static const List<String> _protectedFromDelete = ['auth'];

  static Future<bool> _requestPermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  static Future<Directory> _getAsparDirectory() async {
    Directory baseDir;
    try {
      baseDir = Directory('/storage/emulated/0');
      if (!await baseDir.exists()) {
        baseDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      baseDir = await getApplicationDocumentsDirectory();
    }
    final asparDir = Directory('${baseDir.path}/اسپار');
    if (!await asparDir.exists()) {
      await asparDir.create(recursive: true);
    }
    return asparDir;
  }

  // به‌جای اینکه دوباره Hive.box(name) رو صدا بزنیم (که با نوع اشتباه باعث خطا میشه)،
  // مستقیم از باکس‌های از قبل بازِ DatabaseHelper استفاده می‌کنیم
  static dynamic _getOpenBox(String name) {
    switch (name) {
      case 'banks':
        return DatabaseHelper.bankBox;
      case 'transactions':
        return DatabaseHelper.transactionBox;
      case 'contacts':
        return DatabaseHelper.contactBox;
      case 'debts':
        return DatabaseHelper.debtBox;
      case 'products':
        return DatabaseHelper.productBox;
      case 'productBatches':
        return DatabaseHelper.productBatchBox;
      case 'productTransactions':
        return DatabaseHelper.productTransactionBox;
      case 'ledgerEntries':
        return DatabaseHelper.ledgerEntryBox;
      case 'loans':
        return DatabaseHelper.loanBox;
      case 'savingsGoals':
        return DatabaseHelper.savingsGoalBox;
      case 'payments':
        return DatabaseHelper.paymentBox;
      case 'auth':
        return DatabaseHelper.authBox;
      default:
        return null;
    }
  }

  static Future<String> createBackup() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      throw Exception('دسترسی به حافظه گوشی داده نشد');
    }

    final Map<String, dynamic> boxesData = {};

    for (final name in boxNames) {
      final box = _getOpenBox(name);
      if (box == null) continue;
      final Map<String, dynamic> boxMap = {};
      for (final key in box.keys) {
        boxMap[key.toString()] = box.get(key);
      }
      boxesData[name] = boxMap;
    }

    final backupData = {
      'app': 'Aspar',
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'boxes': boxesData,
    };

    final dir = await _getAsparDirectory();
    final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonEncode(backupData));

    return file.path;
  }

  static Future<void> restoreFromFile(File file) async {
    final content = await file.readAsString();
    final Map<String, dynamic> backupData = jsonDecode(content);
    final Map<String, dynamic> boxesData = backupData['boxes'] ?? {};

    for (final name in boxNames) {
      if (!boxesData.containsKey(name)) continue;
      final box = _getOpenBox(name);
      if (box == null) continue;
      await box.clear();

      final Map<String, dynamic> boxMap = Map<String, dynamic>.from(boxesData[name]);
      for (final entry in boxMap.entries) {
        final parsedKey = int.tryParse(entry.key);
        final key = parsedKey ?? entry.key;
        await box.put(key, entry.value);
      }
    }
  }

  static Future<void> deleteAllData() async {
    for (final name in boxNames) {
      if (_protectedFromDelete.contains(name)) continue;
      final box = _getOpenBox(name);
      if (box == null) continue;
      await box.clear();
    }
  }
}
