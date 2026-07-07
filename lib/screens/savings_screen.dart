import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/savings_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';
import 'add_savings_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSavingsScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 8), Text('هدف جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
            ),
          ),
        ),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, _) {
          final totalSavings = provider.getTotalSavings();
          final totalTarget = provider.getTotalTarget();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.savings, color: Colors.white, size: 24)),
                            const SizedBox(width: 12),
                            const Text('کل پس انداز', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(formatAmount(totalSavings), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 20),
                        Container(width: double.infinity, height: 1, color: Colors.white24),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('هدف کل', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount(totalTarget), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('باقی مانده', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount((totalTarget - totalSavings).clamp(0, double.infinity)), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (provider.savingsGoals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.savings_outlined, size: 55, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('هدفی برای پس انداز تعریف نکردی', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.savingsGoals.length,
                    itemBuilder: (context, index) {
                      final goal = provider.savingsGoals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(18),
                          elevation: 2,
                          shadowColor: Colors.black12,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: AppColors.text(context),
                              collapsedIconColor: AppColors.text(context),
                              title: Text(goal.title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: goal.progressPercent,
                                        minHeight: 8,
                                        backgroundColor: AppColors.divider(context),
                                        valueColor: AlwaysStoppedAnimation(goal.isCompleted ? const Color(0xFF11998E) : const Color(0xFF9B6DFF)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('${formatAmount(goal.currentAmount)} از ${formatAmount(goal.targetAmount)} تومان', style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
                                  ],
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (goal.description.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _buildDetailRow(context, 'توضیح', goal.description),
                                        ),
                                      _buildDetailRow(context, 'هدف', '${formatAmount(goal.targetAmount)} تومان'),
                                      _buildDetailRow(context, 'جمع‌شده', '${formatAmount(goal.currentAmount)} تومان'),
                                      _buildDetailRow(context, 'باقی مانده', '${formatAmount(goal.remainingAmount)} تومان', goal.isCompleted ? const Color(0xFF11998E) : const Color(0xFF9B6DFF)),
                                      _buildDetailRow(context, 'درصد پیشرفت', '${(goal.progressPercent * 100).toStringAsFixed(0)}٪'),
                                      if (goal.targetDate != null)
                                        _buildDetailRow(context, 'تاریخ هدف', _formatDateToJalali(goal.targetDate!)),
                                      _buildDetailRow(context, 'تاریخ ایجاد', _formatDateToJalali(goal.createdDate)),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          if (!goal.isCompleted)
                                            Expanded(
                                              child: _ActionButton(
                                                icon: Icons.add_circle_outline,
                                                label: 'افزودن پول',
                                                gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                                                onTap: () => _showAddMoneyDialog(context, provider, goal),
                                              ),
                                            ),
                                          if (!goal.isCompleted) const SizedBox(width: 8),
                                          Expanded(child: _ActionButton(icon: Icons.edit_rounded, label: 'ویرایش', gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], onTap: () => _showEditDialog(context, provider, goal))),
                                          const SizedBox(width: 8),
                                          Expanded(child: _ActionButton(icon: Icons.delete_outline_rounded, label: 'حذف', gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)], onTap: () => _showDeleteDialog(context, provider, goal))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor ?? AppColors.text(context))),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, SavingsProvider provider, SavingsGoal goal) {
    final amountController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final amount = double.tryParse(amountController.text) ?? 0;
          final newTotal = goal.currentAmount + amount;
          final canAdd = newTotal <= goal.targetAmount;

          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('افزودن پول به «${goal.title}»', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('موجودی فعلی: ${formatAmount(goal.currentAmount)} تومان', style: TextStyle(fontSize: 13, color: AppColors.textSecondary(dialogContext))),
                const SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: AppColors.text(dialogContext)),
                  decoration: InputDecoration(hintText: 'مبلغ اضافه‌شده', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                if (amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${formatAmount(amount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                          const SizedBox(height: 6),
                          Text('جمع جدید: ${formatAmount(newTotal)} تومان', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(dialogContext))),
                          if (!canAdd)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('⚠️ بیشتر از هدف!', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting || amount <= 0 || !canAdd
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        
                        final bankProvider = context.read<BankProvider>();
                        try {
                          final firstBank = bankProvider.banks.first;
                          if (firstBank.balance >= amount) {
                            await bankProvider.updateBank(Bank(
                              id: firstBank.id,
                              bankName: firstBank.bankName,
                              accountNumber: firstBank.accountNumber,
                              balance: firstBank.balance - amount,
                            ));

                            await provider.addToSavingsGoal(goal.id!, amount);

                            final transProvider = context.read<TransactionProvider>();
                            await transProvider.addTransaction(Transaction(
                              title: 'انتقال به پس انداز',
                              description: 'انتقال به «${goal.title}»',
                              amount: amount,
                              type: TransactionType.expense,
                              category: 'پس انداز',
                              date: DateTime.now(),
                              bankId: firstBank.id,
                            ));

                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اضافه شد ✅')));
                          } else {
                            setState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('موجودی بانک کافی نیست')));
                          }
                        } catch (e) {
                          setState(() => isSubmitting = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11998E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأیید', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, SavingsProvider provider, SavingsGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final descriptionController = TextEditingController(text: goal.description);
    final targetAmountController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));
    DateTime? selectedTargetDate = goal.targetDate;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final targetAmount = double.tryParse(targetAmountController.text) ?? 0;

          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('ویرایش «${goal.title}»', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'عنوان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: descriptionController, maxLines: 2, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'توضیح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: targetAmountController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'هدف (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  if (targetAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('${formatAmount(targetAmount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8), fontSize: 12)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(context: dialogContext, initialDate: selectedTargetDate != null ? Jalali.fromDateTime(selectedTargetDate!) : Jalali.now(), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
                      if (picked != null) setState(() => selectedTargetDate = picked.toDateTime());
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(selectedTargetDate != null ? _formatDateToJalali(selectedTargetDate!) : 'انتخاب تاریخ'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting || titleController.text.isEmpty || targetAmount <= 0
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        final updatedGoal = SavingsGoal(
                          id: goal.id,
                          title: titleController.text,
                          description: descriptionController.text,
                          targetAmount: targetAmount,
                          currentAmount: goal.currentAmount,
                          createdDate: goal.createdDate,
                          targetDate: selectedTargetDate,
                        );
                        await provider.updateSavingsGoal(updatedGoal);
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ذخیره', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SavingsProvider provider, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف هدف', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text('آیا مطمئن هستید؟', style: TextStyle(color: AppColors.text(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              provider.deleteSavingsGoal(goal.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: gradient),
        boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 4), Flexible(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis))]),
          ),
        ),
      ),
    );
  }
}
