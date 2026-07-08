import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/savings_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  final List<List<Color>> _gradients = const [
    [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
    [Color(0xFFE67E22), Color(0xFFD35400)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'پس انداز', context: context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]),
          boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddDialog(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 8), Text('هدف جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'YekanBakh'))]),
            ),
          ),
        ),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, savingsProvider, _) {
          final goals = savingsProvider.savingsGoals;
          final totalTarget = savingsProvider.getTotalTarget();
          final totalSavings = savingsProvider.getTotalSavings();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    children: [
                      // کل پس انداز و هدف
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 20)),
                                const SizedBox(width: 10),
                                const Text('پس انداز کلی', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(formatAmount(totalSavings), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                            const SizedBox(height: 2),
                            const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'YekanBakh')),
                            const SizedBox(height: 16),
                            Text('هدف: ${formatAmount(totalTarget)} تومان', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'YekanBakh')),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: totalTarget > 0 ? (totalSavings / totalTarget).clamp(0.0, 1.0) : 0,
                                minHeight: 6,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (goals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.savings_rounded, size: 60, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('هنوز هدف پس انداز نداری', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                        const SizedBox(height: 6),
                        Text('با دکمه‌ی پایین شروع کن', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12, fontFamily: 'YekanBakh')),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اهداف شما', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary(context), fontFamily: 'YekanBakh')),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final gradient = _gradients[index % _gradients.length];
                            final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(left: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white, fontFamily: 'YekanBakh')),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.9)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                onSelected: (value) {
                                                  if (value == 'add') _showAddAmountDialog(context, goal);
                                                  if (value == 'edit') _showEditDialog(context, goal);
                                                  if (value == 'delete') _showDeleteDialog(context, goal);
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(value: 'add', child: Row(children: [Icon(Icons.add_circle_outline, size: 18, color: Colors.green), SizedBox(width: 8), Text('اضافه کردن', style: TextStyle(fontFamily: 'YekanBakh'))])),
                                                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش', style: TextStyle(fontFamily: 'YekanBakh'))])),
                                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(fontFamily: 'YekanBakh'))])),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (goal.description.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(goal.description, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), fontFamily: 'YekanBakh')),
                                          ],
                                          const SizedBox(height: 16),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${formatAmount(goal.currentAmount)} / ${formatAmount(goal.targetAmount)} تومان', style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'YekanBakh')),
                                                    const SizedBox(height: 8),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(6),
                                                      child: LinearProgressIndicator(
                                                        value: (progress as double).clamp(0.0, 1.0),
                                                        minHeight: 6,
                                                        backgroundColor: Colors.white.withOpacity(0.2),
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'YekanBakh')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('هدف جدید', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'YekanBakh')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'عنوان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'توضیح (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'مبلغ هدف (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
          ElevatedButton(
            onPressed: () {
              final savingsProvider = context.read<SavingsProvider>();
              final goal = SavingsGoal(
                id: DateTime.now().millisecondsSinceEpoch,
                title: titleController.text,
                description: descriptionController.text,
                targetAmount: double.tryParse(targetController.text) ?? 0,
                currentAmount: 0,
                createdDate: DateTime.now(),
                targetDate: null,
              );
              savingsProvider.addSavingsGoal(goal);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A3DE8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ایجاد', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
          ),
        ],
      ),
    );
  }

  void _showAddAmountDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();
    String? selectedSource; // 'bank' یا 'cashbox'
    int? selectedBankId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final bankProvider = context.read<BankProvider>();
          final selectedBank = selectedBankId != null ? bankProvider.banks.firstWhere((b) => b.id == selectedBankId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)) : null;

          return AlertDialog(
            backgroundColor: AppColors.card(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('اضافه کردن مبلغ', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'YekanBakh')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
                    decoration: InputDecoration(labelText: 'مبلغ (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
                  ),
                  const SizedBox(height: 16),
                  Text('برداشت از:', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'YekanBakh')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedSource = 'bank'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedSource == 'bank' ? const Color(0xFF4F6BF5).withOpacity(0.1) : AppColors.background(context),
                              border: Border.all(color: selectedSource == 'bank' ? const Color(0xFF4F6BF5) : AppColors.divider(context), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('بانک', style: TextStyle(color: selectedSource == 'bank' ? const Color(0xFF4F6BF5) : AppColors.textSecondary(context), fontWeight: FontWeight.w600, fontFamily: 'YekanBakh'))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedSource = 'cashbox'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedSource == 'cashbox' ? const Color(0xFFE67E22).withOpacity(0.1) : AppColors.background(context),
                              border: Border.all(color: selectedSource == 'cashbox' ? const Color(0xFFE67E22) : AppColors.divider(context), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('صندوق', style: TextStyle(color: selectedSource == 'cashbox' ? const Color(0xFFE67E22) : AppColors.textSecondary(context), fontWeight: FontWeight.w600, fontFamily: 'YekanBakh'))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedSource == 'bank') ...[
                    const SizedBox(height: 12),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedBankId,
                      hint: Text('انتخاب بانک', style: TextStyle(color: AppColors.textMuted(context), fontFamily: 'YekanBakh')),
                      items: bankProvider.banks.map((bank) => DropdownMenuItem(value: bank.id, child: Text('${bank.bankName} (${formatAmount(bank.balance)} تومان)', style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh')))).toList(),
                      onChanged: (value) => setState(() => selectedBankId = value),
                      dropdownColor: AppColors.card(context),
                      style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
                      underline: const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
              ElevatedButton(
                onPressed: () {
                  final savingsProvider = context.read<SavingsProvider>();
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد', style: TextStyle(fontFamily: 'YekanBakh'))));
                    return;
                  }
                  if (selectedSource == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انتخاب کن از کجا برداشت کنی', style: TextStyle(fontFamily: 'YekanBakh'))));
                    return;
                  }
                  if (selectedSource == 'bank' && selectedBankId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بانک رو انتخاب کن', style: TextStyle(fontFamily: 'YekanBakh'))));
                    return;
                  }

                  savingsProvider.addToSavingsGoal(goal.id ?? 0, amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('${selectedSource == 'bank' ? 'از بانک' : 'از صندوق'} برداشت شد ✅', style: TextStyle(fontFamily: 'YekanBakh'))));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A3DE8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('اضافه کن', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, SavingsGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final descriptionController = TextEditingController(text: goal.description);
    final targetController = TextEditingController(text: goal.targetAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ویرایش هدف', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'YekanBakh')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'عنوان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'توضیح (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'),
              decoration: InputDecoration(labelText: 'مبلغ هدف (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
          ElevatedButton(
            onPressed: () {
              final savingsProvider = context.read<SavingsProvider>();
              final updatedGoal = SavingsGoal(
                id: goal.id,
                title: titleController.text,
                description: descriptionController.text,
                targetAmount: double.tryParse(targetController.text) ?? 0,
                currentAmount: goal.currentAmount,
                createdDate: goal.createdDate,
                targetDate: goal.targetDate,
              );
              savingsProvider.updateSavingsGoal(updatedGoal);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A3DE8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف هدف', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontFamily: 'YekanBakh')),
        content: const Text('آیا مطمئن‌اید؟', style: TextStyle(fontFamily: 'YekanBakh')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
          ElevatedButton(
            onPressed: () {
              final savingsProvider = context.read<SavingsProvider>();
              savingsProvider.deleteSavingsGoal(goal.id ?? 0);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
          ),
        ],
      ),
    );
  }
}
