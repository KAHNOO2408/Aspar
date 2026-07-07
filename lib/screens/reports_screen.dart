import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/profit_model.dart' hide TransactionType;
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(
              children: [
                buildCustomAppBar(title: 'گزارشات', context: context),
                const TabBar(labelColor: Colors.white, unselectedLabelColor: Colors.white60, indicatorColor: Colors.white, indicatorWeight: 3, labelStyle: TextStyle(fontWeight: FontWeight.w700), tabs: [Tab(text: 'تراکنش‌ها'), Tab(text: 'بانک‌ها')]),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [_TransactionReportsTab(formatDate: _formatDateToJalali), _buildBankReports(context)]),
      ),
    );
  }

  Widget _buildBankReports(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: const Color(0xFF11998E).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('کل موجودی بانک‌ها', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 15),
                        Text(formatAmount(provider.getTotalBalance()), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 30)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (provider.banks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('موجودی بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text(context))),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            barGroups: List.generate(provider.banks.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (provider.banks[i].balance / 1000000).clamp(0, 100), color: const Color(0xFF4F6BF5), width: 18, borderRadius: BorderRadius.circular(6))])),
                            titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(provider.banks[value.toInt()].bankName, style: TextStyle(fontSize: 10, color: AppColors.text(context)))))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: Text('جزئیات بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text(context)))),
              const SizedBox(height: 10),
              if (provider.banks.isEmpty)
                Padding(padding: const EdgeInsets.all(20), child: Text('بانکی وجود ندارد', style: TextStyle(color: AppColors.textSecondary(context))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.banks.length,
                  itemBuilder: (context, index) {
                    final bank = provider.banks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
                        child: Row(
                          children: [
                            Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)])), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(bank.bankName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text(context))), Text(bank.accountNumber, style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)))])),
                            Text(formatAmount(bank.balance), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF11998E), fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionReportsTab extends StatelessWidget {
  final String Function(DateTime) formatDate;
  const _TransactionReportsTab({required this.formatDate});

  void _showDetails(BuildContext context, Transaction trans) {
    final bankProvider = context.read<BankProvider>();
    String bankName = 'ثبت نشده';
    if (trans.bankId != null) {
      try {
        bankName = bankProvider.banks.firstWhere((b) => b.id == trans.bankId).bankName;
      } catch (e) {
        bankName = 'ثبت نشده';
      }
    }
    final isIncome = trans.type == TransactionType.income;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('جزئیات تراکنش', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(dialogContext, 'عنوان', trans.title),
              if (trans.contactName != null && trans.contactName!.isNotEmpty) _row(dialogContext, 'مخاطب', trans.contactName!),
              if (trans.productInfo != null && trans.productInfo!.isNotEmpty) _row(dialogContext, 'کالا', trans.productInfo!),
              _row(dialogContext, 'توضیح', trans.description.isNotEmpty ? trans.description : '-'),
              _row(dialogContext, 'نوع', isIncome ? 'درآمد' : 'خرج'),
              _row(dialogContext, 'دسته‌بندی', trans.category),
              _row(dialogContext, 'بانک', bankName),
              _row(dialogContext, 'مبلغ', '${formatAmount(trans.amount)} تومان'),
              if (trans.laborFee > 0) _row(dialogContext, 'دستمزد', '${formatAmount(trans.laborFee)} تومان'),
              _row(dialogContext, 'تاریخ', formatDate(trans.date)),
              _row(dialogContext, 'ساعت', '${trans.date.hour.toString().padLeft(2, '0')}:${trans.date.minute.toString().padLeft(2, '0')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showEditDialog(context, trans);
            },
            child: const Text('ویرایش', style: TextStyle(color: Color(0xFF2B3FBE), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showDeleteConfirm(context, trans);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('بستن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 90, child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary(context)))), Expanded(child: Text(value, style: TextStyle(color: AppColors.text(context))))]),
    );
  }

  void _showEditDialog(BuildContext context, Transaction trans) {
    final titleController = TextEditingController(text: trans.title);
    final descController = TextEditingController(text: trans.description);
    final amountController = TextEditingController(text: trans.amount.toStringAsFixed(0));
    DateTime selectedDate = trans.date;
    int? selectedBankId = trans.bankId;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('ویرایش تراکنش', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF2B3FBE).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: const Text('اگه مبلغ یا بانک رو عوض کنی، موجودی بانک هم خودکار تصحیح میشه', style: TextStyle(fontSize: 11, color: Color(0xFF2B3FBE), fontWeight: FontWeight.w600))),
                  const SizedBox(height: 12),
                  TextField(controller: titleController, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'عنوان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: descController, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'توضیح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'مبلغ (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  Consumer<BankProvider>(
                    builder: (context, bankProvider, _) {
                      return DropdownButtonFormField<int>(
                        value: selectedBankId,
                        items: bankProvider.banks.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.bankName))).toList(),
                        onChanged: (value) => setState(() => selectedBankId = value),
                        decoration: InputDecoration(labelText: 'بانک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(context: dialogContext, initialDate: Jalali.fromDateTime(selectedDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
                      if (picked != null) setState(() => selectedDate = picked.toDateTime());
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(formatDate(selectedDate)),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        final newAmount = double.tryParse(amountController.text) ?? trans.amount;
                        final bankProvider = context.read<BankProvider>();

                        if (trans.bankId != null) {
                          try {
                            final oldBank = bankProvider.banks.firstWhere((b) => b.id == trans.bankId);
                            final reversedBalance = trans.type == TransactionType.income ? oldBank.balance - trans.amount : oldBank.balance + trans.amount;
                            await bankProvider.updateBank(Bank(id: oldBank.id, bankName: oldBank.bankName, accountNumber: oldBank.accountNumber, balance: reversedBalance));
                          } catch (e) {}
                        }

                        if (selectedBankId != null) {
                          try {
                            final newBank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);
                            final appliedBalance = trans.type == TransactionType.income ? newBank.balance + newAmount : newBank.balance - newAmount;
                            await bankProvider.updateBank(Bank(id: newBank.id, bankName: newBank.bankName, accountNumber: newBank.accountNumber, balance: appliedBalance));
                          } catch (e) {}
                        }

                        final updated = Transaction(id: trans.id, title: titleController.text, description: descController.text, amount: newAmount, type: trans.type, category: trans.category, date: selectedDate, bankId: selectedBankId, contactName: trans.contactName, productInfo: trans.productInfo, laborFee: trans.laborFee);
                        await context.read<TransactionProvider>().editTransaction(updated);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                        }
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

  void _showDeleteConfirm(BuildContext context, Transaction trans) {
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('حذف تراکنش', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
            content: Text('آیا از حذف «${trans.title}» مطمئن هستید؟\n\nموجودی بانک هم به‌صورت خودکار اصلاح میشه.', style: TextStyle(color: AppColors.text(dialogContext))),
            actions: [
              TextButton(onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        if (trans.bankId != null) {
                          final bankProvider = context.read<BankProvider>();
                          try {
                            final bank = bankProvider.banks.firstWhere((b) => b.id == trans.bankId);
                            final reversedBalance = trans.type == TransactionType.income ? bank.balance - trans.amount : bank.balance + trans.amount;
                            await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: reversedBalance));
                          } catch (e) {}
                        }

                        await context.read<TransactionProvider>().deleteTransaction(trans.id!);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد'), backgroundColor: Colors.red));
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final income = provider.getTotalIncome(null, null);
        final expense = provider.getTotalExpense(null, null);
        final net = provider.getNetBalance();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _MiniStat(icon: Icons.arrow_downward_rounded, label: 'درآمد', value: formatAmount(income), gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)])),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniStat(icon: Icons.arrow_upward_rounded, label: 'خرج', value: formatAmount(expense), gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)])),
                ],
              ),
              const SizedBox(height: 12),
              _MiniStat(icon: Icons.account_balance_wallet_rounded, label: 'خالص', value: formatAmount(net), gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], fullWidth: true),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('توزیع درآمد و خرج', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text(context))),
                    const SizedBox(height: 20),
                    if (income > 0 && expense > 0)
                      SizedBox(
                        height: 200,
                        child: PieChart(PieChartData(sections: [
                          PieChartSectionData(color: const Color(0xFF11998E), value: income, title: 'درآمد', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                          PieChartSectionData(color: const Color(0xFFE64A19), value: expense, title: 'خرج', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                        ])),
                      )
                    else
                      Padding(padding: const EdgeInsets.all(20), child: Text('داده‌ای برای نمایش وجود ندارد', style: TextStyle(color: AppColors.textSecondary(context)))),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: Text('آخرین تراکنش‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text(context)))),
              const SizedBox(height: 10),
              if (provider.transactions.isEmpty)
                Padding(padding: const EdgeInsets.all(20), child: Text('تراکنشی وجود ندارد', style: TextStyle(color: AppColors.textSecondary(context))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final trans = provider.transactions[index];
                    final isIncome = trans.type == TransactionType.income;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(14),
                        elevation: 1,
                        shadowColor: Colors.black12,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showDetails(context, trans),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: isIncome ? const [Color(0xFF11998E), Color(0xFF38EF7D)] : const [Color(0xFFFF7A59), Color(0xFFE64A19)])), child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: Colors.white, size: 20)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(trans.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text(context))), Text(formatDate(trans.date), style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)))])),
                                Text(formatAmount(trans.amount), style: TextStyle(fontWeight: FontWeight.w800, color: isIncome ? const Color(0xFF11998E) : const Color(0xFFE64A19))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final bool fullWidth;

  const _MiniStat({required this.icon, required this.label, required this.value, required this.gradient, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 16)), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
