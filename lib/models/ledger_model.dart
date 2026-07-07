import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class LedgerEntry {
  final int? id;
  final String personName;
  final String personFamily;
  final DateTime date;
  final String description;
  final double debitAmount;
  final double creditAmount;
  final int? bankId;
  final String? trackingCode;
  final double laborFee;

  LedgerEntry({
    this.id,
    required this.personName,
    required this.personFamily,
    required this.date,
    required this.description,
    this.debitAmount = 0,
    this.creditAmount = 0,
    this.bankId,
    this.trackingCode,
    this.laborFee = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'personName': personName,
        'personFamily': personFamily,
        'date': date.toIso8601String(),
        'description': description,
        'debitAmount': debitAmount,
        'creditAmount': creditAmount,
        'bankId': bankId,
        'trackingCode': trackingCode,
        'laborFee': laborFee,
      };

  factory LedgerEntry.fromMap(Map<String, dynamic> map) => LedgerEntry(
        id: map['id'],
        personName: map['personName'],
        personFamily: map['personFamily'],
        date: DateTime.parse(map['date']),
        description: map['description'],
        debitAmount: (map['debitAmount'] ?? 0 as num).toDouble(),
        creditAmount: (map['creditAmount'] ?? 0 as num).toDouble(),
        bankId: map['bankId'],
        trackingCode: map['trackingCode'],
        laborFee: (map['laborFee'] ?? 0 as num).toDouble(),
      );
}

class LedgerProvider extends ChangeNotifier {
  List<LedgerEntry> entries = [];

  LedgerProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    entries = await DatabaseHelper.getLedgerEntries();
    notifyListeners();
  }

  Future<int> addEntry(LedgerEntry entry) async {
    final id = entry.id ?? DateTime.now().millisecondsSinceEpoch;
    final toSave = LedgerEntry(
      id: id,
      personName: entry.personName,
      personFamily: entry.personFamily,
      date: entry.date,
      description: entry.description,
      debitAmount: entry.debitAmount,
      creditAmount: entry.creditAmount,
      bankId: entry.bankId,
      trackingCode: entry.trackingCode,
      laborFee: entry.laborFee,
    );
    await DatabaseHelper.insertLedgerEntry(toSave);
    await loadEntries();
    return id;
  }

  Future<void> updateEntry(LedgerEntry entry) async {
    await DatabaseHelper.updateLedgerEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.deleteLedgerEntry(id);
    await loadEntries();
  }

  List<LedgerEntry> getEntriesForContact(String name, String family) {
    final list = entries.where((e) => e.personName == name && e.personFamily == family).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  double getBalance(String name, String family) {
    final list = getEntriesForContact(name, family);
    return list.fold(0.0, (sum, e) => sum + e.debitAmount - e.creditAmount);
  }

  List<Map<String, dynamic>> getAllBalances() {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final e in entries) {
      final key = '${e.personName}|${e.personFamily}';
      grouped.putIfAbsent(key, () => {
            'personName': e.personName,
            'personFamily': e.personFamily,
            'balance': 0.0,
          });
      grouped[key]!['balance'] = (grouped[key]!['balance'] as double) + e.debitAmount - e.creditAmount;
    }
    return grouped.values.where((v) => (v['balance'] as double).abs() > 0.01).toList();
  }
}
