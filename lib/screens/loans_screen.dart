import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/loan_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';
import 'add_loan_screen.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'وام', context: context),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLoanScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 8), Text('وام جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
            ),
          ),
        ),
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, _) {
          final totalLoans = provider.getTotalRemainingLoans();

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 20)),
                                const SizedBox(width: 10),
                                const Text('کل وام‌های باقی', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(formatAmount(totalLoans), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 30)),
                      ],
                    ),
                  ),
                ),

                if (provider.loans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.handshake_outlined, size: 55, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('وام‌ای نداری', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.loans.length,
                    itemBuilder: (context, index) {
                      final loan = provider.loans[index];
                      final progress = loan.totalAmount > 0 ? (loan.paidAmount / loan.totalAmount).clamp(0.0, 1.0) : 0.0;

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
                              title: Text(loan.bankName, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: AppColors.divider(context), valueColor: AlwaysStoppedAnimation(progress > 0.75 ? const Color(0xFF11998E) : const Color(0xFF4F6BF5))),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (loan.principalAmount > 0) _buildDetailRow(context, 'اصل وام', '${formatAmount(loan.principalAmount)} تومان'),
                                      if (loan.interestPercent > 0) _buildDetailRow(context, 'درصد سود', '${loan.interestPercent.toStringAsFixed(0)}٪'),
                                      _buildDetailRow(context, 'مبلغ کل', '${formatAmount(loan.totalAmount)} تومان'),
                                      _buildDetailRow(context, 'قسط ماهیانه', '${formatAmount(loan.monthlyPayment)} تومان'),
                                      _buildDetailRow(context, 'پرداخت شده', '${formatAmount(loan.paidAmount)} تومان'),
                                      _buildDetailRow(context, 'باقی مانده', '${formatAmount(loan.remainingAmount)} تومان', const Color(0xFFE64A19)),
                                      _buildDetailRow(context, 'تاریخ شروع', _formatDateToJalali(loan.startDate)),
                                      _buildDetailRow(context, 'تاریخ پایان', _formatDateToJalali(loan.endDate)),
                                      _buildDetailRow(context, 'ماه‌های باقی', '${loan.remainingMonths}'),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(child: _ActionButton(icon: Icons.payment_rounded, label: 'پرداخت قسط', gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)], onTap: () => _showPaymentDialog(context, provider, loan))),
                                          const SizedBox(width: 8),
                                          Expanded(child: _ActionButton(icon: Icons.edit_rounded, label: 'ویرایش', gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], onTap: () => _showEditDialog(context, provider, loan))),
                                          const SizedBox(width: 8),
                                          Expanded(child: _ActionButton(icon: Icons.delete_outline_rounded, label: 'حذف', gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)], onTap: () => _showDeleteDialog(context, provider, loan))),
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

  void _showPaymentDialog(BuildContext context, LoanProvider loanProvider, Loan loan) {
    final amountController = TextEditingController(text: loan.monthlyPayment.toStringAsFixed(0));
    int? selectedBankIndex;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('پرداخت قسط', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('وام: ${loan.bankName}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text(dialogContext))),
                const SizedBox(height: 10),
                Text('قسط پیش‌فرض: ${formatAmount(loan.monthlyPayment)} تومان', style: TextStyle(fontSize: 13, color: AppColors.textSecondary(dialogContext))),
                const SizedBox(height: 15),
                TextField(controller: amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(hintText: 'مبلغ پرداخت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 15),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) {
                    return DropdownButtonFormField<int>(
                      value: selectedBankIndex,
                      hint: const Text('انتخاب بانک پرداخت *'),
                      items: List.generate(bankProvider.banks.length, (i) => DropdownMenuItem<int>(value: i, child: Text('${bankProvider.banks[i].bankName} - ${formatAmount(bankProvider.banks[i].balance)}'))),
                      onChanged: (value) => setState(() => selectedBankIndex = value),
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount > 0 && selectedBankIndex != null) {
                          setState(() => isSubmitting = true);
                          final bankProvider = context.read<BankProvider>();
                          final transProvider = context.read<TransactionProvider>();
                          final bank = bankProvider.banks[selectedBankIndex!];

                          await loanProvider.payLoanInstallment(loan.id!, amount);

                          final updatedBank = Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance - amount);
                          await bankProvider.updateBank(updatedBank);

                          await transProvider.addTransaction(Transaction(title: 'پرداخت قسط وام', description: loan.bankName, amount: amount, type: TransactionType.expense, category: 'وام', date: DateTime.now(), bankId: bank.id));

                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قسط پرداخت شد ✅')));
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

  void _showEditDialog(BuildContext context, LoanProvider provider, Loan loan) {
    final bankNameController = TextEditingController(text: loan.bankName);
    final principalController = TextEditingController(text: loan.principalAmount > 0 ? loan.principalAmount.toStringAsFixed(0) : loan.totalAmount.toStringAsFixed(0));
    final monthsController = TextEditingController(text: loan.months > 0 ? loan.months.toString() : loan.totalMonths.toString());
    final interestPercentController = TextEditingController(text: loan.interestPercent > 0 ? loan.interestPercent.toStringAsFixed(0) : '');
    final paidAmountController = TextEditingController(text: loan.paidAmount.toStringAsFixed(0));
    final descriptionController = TextEditingController(text: loan.description);
    DateTime selectedStartDate = loan.startDate;
    bool isSubmitting = false;

    String formatJalali(DateTime date) {
      final j = Jalali.fromDateTime(date);
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final principal = double.tryParse(principalController.text) ?? 0;
          final months = int.tryParse(monthsController.text) ?? 0;
          final percent = double.tryParse(interestPercentController.text) ?? 0;
          final totalPayable = principal + (principal * percent / 100);
          final monthlyPayment = months > 0 ? totalPayable / months : 0.0;

          return AlertDialog(
            backgroundColor: AppColors.card(dialogContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('ویرایش وام', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: bankNameController, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'نام وام/بانک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: principalController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'اصل مبلغ وام (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: monthsController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'تعداد ماه وام', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: interestPercentController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'درصد سود (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  if (principal > 0 && months > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('قسط ماهیانه‌ی جدید: ${formatAmount(monthlyPayment)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                    ),
                  const SizedBox(height: 12),
                  TextField(controller: paidAmountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'مبلغ پرداخت‌شده تاکنون (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: descriptionController, style: TextStyle(color: AppColors.text(dialogContext)), decoration: InputDecoration(labelText: 'توضیح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(context: dialogContext, initialDate: Jalali.fromDateTime(selectedStartDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
                      if (picked != null) setState(() => selectedStartDate = picked.toDateTime());
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(formatJalali(selectedStartDate)),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (bankNameController.text.isEmpty || principal <= 0 || months <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام وام، اصل مبلغ و تعداد ماه الزامی هستند')));
                          return;
                        }
                        final paidAmount = double.tryParse(paidAmountController.text) ?? 0;
                        if (paidAmount > totalPayable) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداخت‌شده نمی‌تواند بیشتر از مبلغ کل باشد')));
                          return;
                        }

                        setState(() => isSubmitting = true);

                        final endDate = DateTime(selectedStartDate.year, selectedStartDate.month + months, selectedStartDate.day);

                        final updatedLoan = Loan(
                          id: loan.id,
                          bankName: bankNameController.text,
                          totalAmount: totalPayable,
                          principalAmount: principal,
                          interestPercent: percent,
                          monthlyPayment: monthlyPayment,
                          months: months,
                          startDate: selectedStartDate,
                          endDate: endDate,
                          bankId: loan.bankId,
                          description: descriptionController.text,
                          paidAmount: paidAmount,
                        );

                        await provider.editLoan(updatedLoan);
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

  void _showDeleteDialog(BuildContext context, LoanProvider provider, Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف وام', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text('آیا مطمئن‌اید؟', style: TextStyle(color: AppColors.text(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              provider.deleteLoan(loan.id!);
              Navigator.pop(context);
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
