import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupService {
  static const List<String> boxNames = [
    'transactions',
    'debts',
    'banks',
    'payments',
    'auth',
    'products',
    'productBatches',
    'productTransactions',
    'ledger',
    'contacts',
    'loans',
    'settings',
  ];

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

  static Future<String> createBackup() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      throw Exception('دسترسی به حافظه گوشی داده نشد');
    }

    final Map<String, dynamic> boxesData = {};

    for (final name in boxNames) {
      final box = Hive.isBoxOpen(name) ? Hive.box(name) : await Hive.openBox(name);
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

  static Future<File?> getLatestBackupFile() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) return null;

    final dir = await _getAsparDirectory();
    if (!await dir.exists()) return null;

    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
    if (files.isEmpty) return null;

    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files.first;
  }

  static Future<void> restoreFromFile(File file) async {
    final content = await file.readAsString();
    final Map<String, dynamic> backupData = jsonDecode(content);
    final Map<String, dynamic> boxesData = backupData['boxes'] ?? {};

    for (final name in boxNames) {
      if (!boxesData.containsKey(name)) continue;
      final box = Hive.isBoxOpen(name) ? Hive.box(name) : await Hive.openBox(name);
      await box.clear();

      final Map<String, dynamic> boxMap = Map<String, dynamic>.from(boxesData[name]);
      for (final entry in boxMap.entries) {
        final parsedKey = int.tryParse(entry.key);
        final key = parsedKey ?? entry.key;
        await box.put(key, entry.value);
      }
    }
  }
}
