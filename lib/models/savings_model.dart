import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class SavingsGoal {
  final int? id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdDate;
  final DateTime? targetDate;

  SavingsGoal({
    this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.createdDate,
    this.targetDate,
  });

  double get remainingAmount => targetAmount - currentAmount;
  double get progressPercent => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0 as num).toDouble(),
      createdDate: DateTime.parse(map['createdDate']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
    );
  }
}

class SavingsProvider extends ChangeNotifier {
  List<SavingsGoal> savingsGoals = [];

  SavingsProvider() {
    loadSavingsGoals();
  }

  Future<void> loadSavingsGoals() async {
    savingsGoals = await DatabaseHelper.getSavingsGoals();
    notifyListeners();
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    final toSave = goal.id == null
        ? SavingsGoal(
            id: DateTime.now().millisecondsSinceEpoch,
            title: goal.title,
            description: goal.description,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            createdDate: goal.createdDate,
            targetDate: goal.targetDate,
          )
        : goal;
    await DatabaseHelper.insertSavingsGoal(toSave);
    await loadSavingsGoals();
  }

  Future<void> addToSavingsGoal(int id, double amount) async {
    final goalIndex = savingsGoals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final goal = savingsGoals[goalIndex];
      final updatedGoal = SavingsGoal(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount + amount,
        createdDate: goal.createdDate,
        targetDate: goal.targetDate,
      );
      await DatabaseHelper.updateSavingsGoal(updatedGoal);
      await loadSavingsGoals();
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await DatabaseHelper.updateSavingsGoal(goal);
    await loadSavingsGoals();
  }

  Future<void> deleteSavingsGoal(int id) async {
    await DatabaseHelper.deleteSavingsGoal(id);
    await loadSavingsGoals();
  }

  double getTotalSavings() {
    return savingsGoals.fold(0, (sum, goal) => sum + goal.currentAmount);
  }

  double getTotalTarget() {
    return savingsGoals.fold(0, (sum, goal) => sum + goal.targetAmount);
  }
}
