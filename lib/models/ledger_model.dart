import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/db_helper.dart';

class LedgerEntry extends HiveObject {
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

  // فیلدهای ردیابی: برای اینکه حذف یه فاکتور بتونه همه‌ی اثراتش رو (انبار، بانک) برگردونه
  final String? sourceType; // 'purchase' | 'sale' | 'returnFromPurchase' | 'returnFromSale'
  final int? productId;
  final double? quantity;
  final double? unitPrice;
  final double? unitCost;
  final int? relatedProductTxId; // برای خرید/فروش: خودِ رکورد؛ برای برگشت‌ها: رکورد اصلی که اصلاح شده
  final int? logProductTxId; // فقط برگشت‌ها: رکورد لاگ برگشتی
  final int? linkedBatchId; // فقط خرید: بچ انبار ساخته‌شده
  final int? affectedBankId;
  final double? bankAmount;
  final bool? bankIsIncome;
  final double? feeAmount;
  final int? linkedTransactionId;
  final int? linkedFeeTransactionId;

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
    this.sourceType,
    this.productId,
    this.quantity,
    this.unitPrice,
    this.unitCost,
    this.relatedProductTxId,
    this.logProductTxId,
    this.linkedBatchId,
    this.affectedBankId,
    this.bankAmount,
    this.bankIsIncome,
    this.feeAmount,
    this.linkedTransactionId,
    this.linkedFeeTransactionId,
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
        'sourceType': sourceType,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'unitCost': unitCost,
        'relatedProductTxId': relatedProductTxId,
        'logProductTxId': logProductTxId,
        'linkedBatchId': linkedBatchId,
        'affectedBankId': affectedBankId,
        'bankAmount': bankAmount,
        'bankIsIncome': bankIsIncome,
        'feeAmount': feeAmount,
        'linkedTransactionId': linkedTransactionId,
        'linkedFeeTransactionId': linkedFeeTransactionId,
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
        sourceType: map['sourceType'],
        productId: map['productId'],
        quantity: map['quantity'] == null ? null : (map['quantity'] as num).toDouble(),
        unitPrice: map['unitPrice'] == null ? null : (map['unitPrice'] as num).toDouble(),
        unitCost: map['unitCost'] == null ? null : (map['unitCost'] as num).toDouble(),
        relatedProductTxId: map['relatedProductTxId'],
        logProductTxId: map['logProductTxId'],
        linkedBatchId: map['linkedBatchId'],
        affectedBankId: map['affectedBankId'],
        bankAmount: map['bankAmount'] == null ? null : (map['bankAmount'] as num).toDouble(),
        bankIsIncome: map['bankIsIncome'],
        feeAmount: map['feeAmount'] == null ? null : (map['feeAmount'] as num).toDouble(),
        linkedTransactionId: map['linkedTransactionId'],
        linkedFeeTransactionId: map['linkedFeeTransactionId'],
      );
}

class LedgerEntryAdapter extends TypeAdapter<LedgerEntry> {
  @override
  final int typeId = 6;

  @override
  LedgerEntry read(BinaryReader reader) {
    final id = reader.read() as int?;
    final personName = reader.read() as String;
    final personFamily = reader.read() as String;
    final date = reader.read() as DateTime;
    final description = reader.read() as String;
    final debitAmount = reader.read() as double;
    final creditAmount = reader.read() as double;
    final bankId = reader.read() as int?;
    final trackingCode = reader.read() as String?;
    final laborFee = reader.read() as double;

    // فیلدهای جدید: فقط اگه دیتای بیشتری تو رکورد باشه می‌خونیم
    // (فاکتورهای قدیمی‌تر این فیلدها رو ندارن، و این طبیعیه)
    String? sourceType;
    int? productId;
    double? quantity;
    double? unitPrice;
    double? unitCost;
    int? relatedProductTxId;
    int? logProductTxId;
    int? linkedBatchId;
    int? affectedBankId;
    double? bankAmount;
    bool? bankIsIncome;
    double? feeAmount;
    int? linkedTransactionId;
    int? linkedFeeTransactionId;

    if (reader.availableBytes > 0) {
      sourceType = reader.read() as String?;
      productId = reader.read() as int?;
      quantity = reader.read() as double?;
      unitPrice = reader.read() as double?;
      unitCost = reader.read() as double?;
      relatedProductTxId = reader.read() as int?;
      logProductTxId = reader.read() as int?;
      linkedBatchId = reader.read() as int?;
      affectedBankId = reader.read() as int?;
      bankAmount = reader.read() as double?;
      bankIsIncome = reader.read() as bool?;
      feeAmount = reader.read() as double?;
      linkedTransactionId = reader.read() as int?;
      linkedFeeTransactionId = reader.read() as int?;
    }

    return LedgerEntry(
      id: id,
      personName: personName,
      personFamily: personFamily,
      date: date,
      description: description,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      bankId: bankId,
      trackingCode: trackingCode,
      laborFee: laborFee,
      sourceType: sourceType,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      unitCost: unitCost,
      relatedProductTxId: relatedProductTxId,
      logProductTxId: logProductTxId,
      linkedBatchId: linkedBatchId,
      affectedBankId: affectedBankId,
      bankAmount: bankAmount,
      bankIsIncome: bankIsIncome,
      feeAmount: feeAmount,
      linkedTransactionId: linkedTransactionId,
      linkedFeeTransactionId: linkedFeeTransactionId,
    );
  }

  @override
  void write(BinaryWriter writer, LedgerEntry obj) {
    writer.write(obj.id);
    writer.write(obj.personName);
    writer.write(obj.personFamily);
    writer.write(obj.date);
    writer.write(obj.description);
    writer.write(obj.debitAmount);
    writer.write(obj.creditAmount);
    writer.write(obj.bankId);
    writer.write(obj.trackingCode);
    writer.write(obj.laborFee);
    writer.write(obj.sourceType);
    writer.write(obj.productId);
    writer.write(obj.quantity);
    writer.write(obj.unitPrice);
    writer.write(obj.unitCost);
    writer.write(obj.relatedProductTxId);
    writer.write(obj.logProductTxId);
    writer.write(obj.linkedBatchId);
    writer.write(obj.affectedBankId);
    writer.write(obj.bankAmount);
    writer.write(obj.bankIsIncome);
    writer.write(obj.feeAmount);
    writer.write(obj.linkedTransactionId);
    writer.write(obj.linkedFeeTransactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LedgerEntryAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
      sourceType: entry.sourceType,
      productId: entry.productId,
      quantity: entry.quantity,
      unitPrice: entry.unitPrice,
      unitCost: entry.unitCost,
      relatedProductTxId: entry.relatedProductTxId,
      logProductTxId: entry.logProductTxId,
      linkedBatchId: entry.linkedBatchId,
      affectedBankId: entry.affectedBankId,
      bankAmount: entry.bankAmount,
      bankIsIncome: entry.bankIsIncome,
      feeAmount: entry.feeAmount,
      linkedTransactionId: entry.linkedTransactionId,
      linkedFeeTransactionId: entry.linkedFeeTransactionId,
    );
    await DatabaseHelper.insertLedgerEntry(toSave);
    await loadEntries();
    return id;
  }

  Future<void> updateEntry(LedgerEntry updated) async {
    LedgerEntry? existing;
    try {
      existing = entries.firstWhere((e) => e.id == updated.id);
    } catch (e) {
      existing = null;
    }

    if (existing != null && existing.isInBox) {
      await existing.delete();
    }
    await DatabaseHelper.ledgerEntryBox.put(updated.id, updated);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    LedgerEntry? existing;
    try {
      existing = entries.firstWhere((e) => e.id == id);
    } catch (e) {
      existing = null;
    }

    if (existing != null && existing.isInBox) {
      await existing.delete();
    } else {
      await DatabaseHelper.deleteLedgerEntry(id);
    }
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
