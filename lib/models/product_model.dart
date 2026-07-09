import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/db_helper.dart';

class Product {
  final int? id;
  final String name;
  Product({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory Product.fromMap(Map<String, dynamic> map) => Product(id: map['id'], name: map['name']);
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 4;

  @override
  Product read(BinaryReader reader) {
    return Product(
      id: reader.read() as int?,
      name: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.write(obj.id);
    writer.write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ProductBatch {
  final int? id;
  final int productId;
  final double originalQuantity;
  double remainingQuantity;
  final double purchasePrice;
  final DateTime date;

  ProductBatch({
    this.id,
    required this.productId,
    required this.originalQuantity,
    required this.remainingQuantity,
    required this.purchasePrice,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'originalQuantity': originalQuantity,
        'remainingQuantity': remainingQuantity,
        'purchasePrice': purchasePrice,
        'date': date.toIso8601String(),
      };

  factory ProductBatch.fromMap(Map<String, dynamic> map) => ProductBatch(
        id: map['id'],
        productId: map['productId'],
        originalQuantity: (map['originalQuantity'] as num).toDouble(),
        remainingQuantity: (map['remainingQuantity'] as num).toDouble(),
        purchasePrice: (map['purchasePrice'] as num).toDouble(),
        date: DateTime.parse(map['date']),
      );
}

class ProductBatchAdapter extends TypeAdapter<ProductBatch> {
  @override
  final int typeId = 10;

  @override
  ProductBatch read(BinaryReader reader) {
    return ProductBatch(
      id: reader.read() as int?,
      productId: reader.read() as int,
      originalQuantity: reader.read() as double,
      remainingQuantity: reader.read() as double,
      purchasePrice: reader.read() as double,
      date: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductBatch obj) {
    writer.write(obj.id);
    writer.write(obj.productId);
    writer.write(obj.originalQuantity);
    writer.write(obj.remainingQuantity);
    writer.write(obj.purchasePrice);
    writer.write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductBatchAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

enum ProductTxType { purchase, sale }

class ProductTransaction {
  final int? id;
  final int productId;
  final String productName;
  final double quantity;
  final double pricePerUnit;
  final double totalAmount;
  final ProductTxType type;
  final DateTime date;
  final double profit;
  final double costOfGoods;
  final double laborFee;
  final String? contactName;

  ProductTransaction({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.type,
    required this.date,
    this.profit = 0,
    this.costOfGoods = 0,
    this.laborFee = 0,
    this.contactName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'totalAmount': totalAmount,
        'type': type == ProductTxType.purchase ? 'purchase' : 'sale',
        'date': date.toIso8601String(),
        'profit': profit,
        'costOfGoods': costOfGoods,
        'laborFee': laborFee,
        'contactName': contactName,
      };

  factory ProductTransaction.fromMap(Map<String, dynamic> map) => ProductTransaction(
        id: map['id'],
        productId: map['productId'],
        productName: map['productName'],
        quantity: (map['quantity'] as num).toDouble(),
        pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
        totalAmount: (map['totalAmount'] as num).toDouble(),
        type: map['type'] == 'purchase' ? ProductTxType.purchase : ProductTxType.sale,
        date: DateTime.parse(map['date']),
        profit: (map['profit'] ?? 0 as num).toDouble(),
        costOfGoods: (map['costOfGoods'] ?? 0 as num).toDouble(),
        laborFee: (map['laborFee'] ?? 0 as num).toDouble(),
        contactName: map['contactName'],
      );
}

class ProductTransactionAdapter extends TypeAdapter<ProductTransaction> {
  @override
  final int typeId = 5;

  @override
  ProductTransaction read(BinaryReader reader) {
    return ProductTransaction(
      id: reader.read() as int?,
      productId: reader.read() as int,
      productName: reader.read() as String,
      quantity: reader.read() as double,
      pricePerUnit: reader.read() as double,
      totalAmount: reader.read() as double,
      type: ProductTxType.values[reader.readByte()],
      date: reader.read() as DateTime,
      profit: reader.read() as double,
      costOfGoods: reader.read() as double,
      laborFee: reader.read() as double,
      contactName: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductTransaction obj) {
    writer.write(obj.id);
    writer.write(obj.productId);
    writer.write(obj.productName);
    writer.write(obj.quantity);
    writer.write(obj.pricePerUnit);
    writer.write(obj.totalAmount);
    writer.writeByte(obj.type.index);
    writer.write(obj.date);
    writer.write(obj.profit);
    writer.write(obj.costOfGoods);
    writer.write(obj.laborFee);
    writer.write(obj.contactName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductTransactionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ProductProvider extends ChangeNotifier {
  List<Product> products = [];
  List<ProductBatch> batches = [];
  List<ProductTransaction> productTransactions = [];

  ProductProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    products = await DatabaseHelper.getProducts();
    batches = await DatabaseHelper.getProductBatches();
    productTransactions = await DatabaseHelper.getProductTransactions();
    notifyListeners();
  }

  double getStock(int productId) {
    return batches.where((b) => b.productId == productId).fold(0.0, (sum, b) => sum + b.remainingQuantity);
  }

  Future<Product> getOrCreateProduct(String name) async {
    final trimmed = name.trim();
    final existing = products.where((p) => p.name == trimmed).toList();
    if (existing.isNotEmpty) return existing.first;
    final newProduct = Product(id: DateTime.now().millisecondsSinceEpoch, name: trimmed);
    await DatabaseHelper.insertProduct(newProduct);
    await loadAll();
    return newProduct;
  }

  Future<void> updateProductName(Product product, String newName) async {
    final updated = Product(id: product.id, name: newName.trim());
    await DatabaseHelper.updateProduct(updated);
    await loadAll();
  }

  Future<void> recordPurchase({
    required Product product,
    required double quantity,
    required double pricePerUnit,
    required DateTime date,
    String? contactName,
  }) async {
    final batch = ProductBatch(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: product.id!,
      originalQuantity: quantity,
      remainingQuantity: quantity,
      purchasePrice: pricePerUnit,
      date: date,
    );
    await DatabaseHelper.insertProductBatch(batch);

    final tx = ProductTransaction(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      totalAmount: quantity * pricePerUnit,
      type: ProductTxType.purchase,
      date: date,
      contactName: contactName,
    );
    await DatabaseHelper.insertProductTransaction(tx);

    await loadAll();
  }

  bool hasEnoughStock(int productId, double quantity) {
    return getStock(productId) >= quantity;
  }

  Future<double> recordSale({
    required Product product,
    required double quantity,
    required double pricePerUnit,
    required DateTime date,
    double laborFee = 0,
    String? contactName,
  }) async {
    if (!hasEnoughStock(product.id!, quantity)) {
      throw Exception('موجودی کافی نیست');
    }

    final productBatches = batches.where((b) => b.productId == product.id && b.remainingQuantity > 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double remainingToSell = quantity;
    double totalCost = 0;

    for (final batch in productBatches) {
      if (remainingToSell <= 0) break;
      final consumed = remainingToSell < batch.remainingQuantity ? remainingToSell : batch.remainingQuantity;
      totalCost += consumed * batch.purchasePrice;
      batch.remainingQuantity -= consumed;
      await DatabaseHelper.updateProductBatch(batch);
      remainingToSell -= consumed;
    }

    final totalAmount = quantity * pricePerUnit;
    final profit = totalAmount - totalCost;

    final tx = ProductTransaction(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      totalAmount: totalAmount,
      type: ProductTxType.sale,
      date: date,
      profit: profit,
      costOfGoods: totalCost,
      laborFee: laborFee,
      contactName: contactName,
    );
    await DatabaseHelper.insertProductTransaction(tx);

    await loadAll();
    return profit;
  }

  List<ProductTransaction> getHistoryForProduct(int productId) {
    final list = productTransactions.where((t) => t.productId == productId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Map<String, dynamic>> getProfitReport(DateTime? start, DateTime? end) {
    final filtered = productTransactions.where((t) {
      if (start != null && t.date.isBefore(start)) return false;
      if (end != null && t.date.isAfter(end)) return false;
      return true;
    }).toList();

    final Map<String, Map<String, dynamic>> grouped = {};
    for (final t in filtered) {
      grouped.putIfAbsent(t.productName, () => {
            'productName': t.productName,
            'totalPurchase': 0.0,
            'totalSale': 0.0,
            'profit': 0.0,
          });
      if (t.type == ProductTxType.purchase) {
        grouped[t.productName]!['totalPurchase'] += t.totalAmount;
      } else {
        grouped[t.productName]!['totalSale'] += t.totalAmount;
        grouped[t.productName]!['profit'] += t.profit;
      }
    }
    return grouped.values.toList();
  }

  double getTotalProfit(DateTime? start, DateTime? end) {
    return productTransactions.where((t) {
      if (t.type != ProductTxType.sale) return false;
      if (start != null && t.date.isBefore(start)) return false;
      if (end != null && t.date.isAfter(end)) return false;
      return true;
    }).fold(0.0, (sum, t) => sum + t.profit);
  }

  double getTotalLaborFee(DateTime? start, DateTime? end) {
    return productTransactions.where((t) {
      if (t.type != ProductTxType.sale) return false;
      if (start != null && t.date.isBefore(start)) return false;
      if (end != null && t.date.isAfter(end)) return false;
      return true;
    }).fold(0.0, (sum, t) => sum + t.laborFee);
  }
}
