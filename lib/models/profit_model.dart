import 'package:flutter/material.dart';

enum TransactionType { purchase, sale }

class ProfitTransaction {
  final int? id;
  final String productName;
  final double quantity;
  final double pricePerUnit;
  final double totalPrice;
  final TransactionType type;
  final DateTime date;
  final int? bankId;
  final String description;

  double get totalAmount => quantity * pricePerUnit;

  ProfitTransaction({
    this.id,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.type,
    required this.date,
    this.bankId,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'type': type == TransactionType.purchase ? 'purchase' : 'sale',
      'date': date.toString(),
      'bankId': bankId,
      'description': description,
    };
  }

  factory ProfitTransaction.fromMap(Map<String, dynamic> map) {
    return ProfitTransaction(
      id: map['id'],
      productName: map['productName'],
      quantity: map['quantity'],
      pricePerUnit: map['pricePerUnit'],
      totalPrice: map['totalPrice'],
      type: map['type'] == 'purchase' ? TransactionType.purchase : TransactionType.sale,
      date: DateTime.parse(map['date']),
      bankId: map['bankId'],
      description: map['description'],
    );
  }
}

class ProfitProvider extends ChangeNotifier {
  List<ProfitTransaction> transactions = [];

  void addTransaction(ProfitTransaction transaction) {
    transactions.add(ProfitTransaction(
      id: transactions.isEmpty ? 1 : transactions.last.id! + 1,
      productName: transaction.productName,
      quantity: transaction.quantity,
      pricePerUnit: transaction.pricePerUnit,
      totalPrice: transaction.totalPrice,
      type: transaction.type,
      date: transaction.date,
      bankId: transaction.bankId,
      description: transaction.description,
    ));
    notifyListeners();
  }

  void deleteTransaction(int id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // کل خریدها
  double getTotalPurchases(DateTime? startDate, DateTime? endDate) {
    return transactions
        .where((t) => t.type == TransactionType.purchase)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  // کل فروش‌ها
  double getTotalSales(DateTime? startDate, DateTime? endDate) {
    return transactions
        .where((t) => t.type == TransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  // سود کل
  double getTotalProfit() {
    return getTotalSales(null, null) - getTotalPurchases(null, null);
  }

  // سود ماهیانه
  Map<String, double> getMonthlProfit() {
    Map<String, double> monthly = {};
    for (var transaction in transactions) {
      String month = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      double amount = transaction.type == TransactionType.sale ? transaction.totalAmount : -transaction.totalAmount;
      monthly[month] = (monthly[month] ?? 0) + amount;
    }
    return monthly;
  }

  // سود هر فروش
  List<Map<String, dynamic>> getProfitPerSale() {
    List<Map<String, dynamic>> profits = [];
    for (var sale in transactions.where((t) => t.type == TransactionType.sale)) {
      double purchasePrice = transactions
          .where((t) => t.type == TransactionType.purchase && t.productName == sale.productName)
          .fold(0.0, (sum, t) => sum + t.totalAmount) / 
          transactions
          .where((t) => t.type == TransactionType.purchase && t.productName == sale.productName)
          .fold(0.0, (sum, t) => sum + t.quantity);
      
      double profit = (sale.pricePerUnit - purchasePrice) * sale.quantity;
      
      profits.add({
        'product': sale.productName,
        'date': sale.date,
        'salePrice': sale.totalAmount,
        'profit': profit,
        'profitPercent': (profit / sale.totalAmount * 100),
      });
    }
    return profits;
  }
}
