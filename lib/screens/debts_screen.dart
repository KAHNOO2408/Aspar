import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';
import 'add_simple_debt_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'طلب و دهی', context: context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]),
          boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: PopupMenuButton(
            iconColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'owed') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSimpleDebtScreen(type: DebtType.owed)));
              if (value == 'receivable') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSimpleDebtScreen(type: DebtType.receivable)));
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'owed', child: Row(children: [Icon(Icons.arrow_upward, size: 16), SizedBox(width: 8), Text('ثبت دهی', style: TextStyle(fontFamily: 'YekanBakh'))])),
              const PopupMenuItem(value: 'receivable', child: Row(children: [Icon(Icons.arrow_downward, size: 16), SizedBox(width: 8), Text('ثبت طلب', style: TextStyle(fontFamily: 'YekanBakh'))])),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add, color: Colors.white), const SizedBox(width: 8), const Text('افزودن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'YekanBakh'))]),
            ),
          ),
        ),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          final owedDebts = provider.debts.where((d) => d.type == DebtType.owed).toList();
          final receivableDebts = provider.debts.where((d) => d.type == DebtType.receivable).toList();

          final totalOwed = owedDebts.fold(0.0, (sum, d) => sum + d.remainder);
          final totalReceivable = receivableDebts.fold(0.0, (sum, d) => sum + d.remainder);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'بدهکاری',
                          value: formatAmount(totalOwed),
                          gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.arrow_downward_rounded,
                          label: 'طلبکاری',
                          value: formatAmount(totalReceivable),
                          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                      ),
                    ],
                  ),
                ),

                if (owedDebts.isEmpty && receivableDebts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet_outlined, size: 55, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('طلب و دهی‌ای ثبت نشده', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      if (receivableDebts.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Align(alignment: Alignment.centerRight, child: Text('طلب‌های من', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh'))),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: receivableDebts.length,
                          itemBuilder: (context, index) {
                            final debt = receivableDebts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DebtCard(debt: debt, formatDate: _formatDateToJalali, gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)]),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (owedDebts.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Align(alignment: Alignment.centerRight, child: Text('بدهی‌های من', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh'))),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: owedDebts.length,
                          itemBuilder: (context, index) {
                            final debt = owedDebts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DebtCard(debt: debt, formatDate: _formatDateToJalali, gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)]),
                            );
                          },
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 16)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
          const SizedBox(height: 2),
          const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'YekanBakh')),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final String Function(DateTime) formatDate;
  final List<Color> gradient;

  const _DebtCard({
    required this.debt,
    required this.formatDate,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isOwed = debt.type == DebtType.owed;
    final isCompleted = debt.remainder <= 0;

    return Material(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.text(context),
          collapsedIconColor: AppColors.text(context),
          title: Text('${debt.personName} ${debt.personFamily}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh')),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${formatAmount(debt.totalAmount)} تومان', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context), fontFamily: 'YekanBakh')),
                if (!isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('باقی: ${formatAmount(debt.remainder)} تومان', style: TextStyle(fontSize: 11, color: gradient[1], fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                  ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'نوع', isOwed ? 'دهی' : 'طلب'),
                  _buildDetailRow(context, 'مبلغ کل', '${formatAmount(debt.totalAmount)} تومان'),
                  _buildDetailRow(context, 'پرداخت‌شده', '${formatAmount(debt.paidAmount)} تومان'),
                  _buildDetailRow(context, 'باقی مانده', '${formatAmount(debt.remainder)} تومان', isCompleted ? const Color(0xFF11998E) : gradient[1]),
                  if (debt.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildDetailRow(context, 'یادداشت', debt.description),
                    ),
                  _buildDetailRow(context, 'تاریخ', formatDate(debt.date)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.edit_rounded,
                          label: 'ویرایش',
                          gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
                          onTap: () => _showEditDialog(context, debt),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'حذف',
                          gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                          onTap: () => _showDeleteDialog(context, debt),
                        ),
                      ),
                      if (!isCompleted) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.check_circle_outline,
                            label: 'پرداخت',
                            gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                            onTap: () => _showPaymentDialog(context, debt),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context), fontFamily: 'YekanBakh')),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor ?? AppColors.text(context), fontFamily: 'YekanBakh')),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Debt debt) {
    final amountController = TextEditingController(text: debt.totalAmount.toStringAsFixed(0));
    final descController = TextEditingController(text: debt.description);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final amount = double.tryParse(amountController.text) ?? 0;

          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('ویرایش', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: 'YekanBakh')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: AppColors.text(dialogContext), fontFamily: 'YekanBakh'),
                    decoration: InputDecoration(labelText: 'مبلغ (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), labelStyle: TextStyle(fontFamily: 'YekanBakh')),
                  ),
                  if (amount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('${formatAmount(amount)} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1], fontSize: 12, fontFamily: 'YekanBakh')),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: TextStyle(color: AppColors.text(dialogContext), fontFamily: 'YekanBakh'),
                    decoration: InputDecoration(labelText: 'یادداشت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), labelStyle: TextStyle(fontFamily: 'YekanBakh')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting || amount <= 0
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        final updated = Debt(
                          id: debt.id,
                          personName: debt.personName,
                          personFamily: debt.personFamily,
                          totalAmount: amount,
                          description: descController.text,
                          date: debt.date,
                          type: debt.type,
                          paidAmount: debt.paidAmount,
                        );
                        await context.read<DebtProvider>().editDebt(updated);
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ذخیره', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Debt debt) {
    final paymentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final payment = double.tryParse(paymentController.text) ?? 0;
          final totalAfter = debt.paidAmount + payment;
          final canPay = payment > 0 && totalAfter <= debt.totalAmount;

          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('پرداخت', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: 'YekanBakh')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('باقی مانده: ${formatAmount(debt.remainder)} تومان', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(dialogContext), fontFamily: 'YekanBakh')),
                const SizedBox(height: 15),
                TextField(
                  controller: paymentController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: AppColors.text(dialogContext), fontFamily: 'YekanBakh'),
                  decoration: InputDecoration(hintText: 'مبلغ پرداخت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), hintStyle: TextStyle(fontFamily: 'YekanBakh')),
                ),
                if (payment > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${formatAmount(payment)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8), fontFamily: 'YekanBakh')),
                          const SizedBox(height: 6),
                          Text('باقی جدید: ${formatAmount((debt.remainder - payment).clamp(0, double.infinity))} تومان', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(dialogContext), fontFamily: 'YekanBakh')),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting || !canPay
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        await context.read<DebtProvider>().payDebt(debt.id!, payment);
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت شد ✅')));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11998E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأیید', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontFamily: 'YekanBakh')),
        content: Text('آیا مطمئن هستید؟', style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              context.read<DebtProvider>().deleteDebt(debt.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
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
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 4), Flexible(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'YekanBakh'), overflow: TextOverflow.ellipsis))]),
          ),
        ),
      ),
    );
  }
}
