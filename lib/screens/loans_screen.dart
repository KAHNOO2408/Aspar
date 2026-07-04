import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/loan_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
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
      backgroundColor: const Color(0xFFF4F6FB),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 20),
                                ),
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
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                ),

                if (provider.loans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.handshake_outlined, size: 55, color: Colors.grey.shade300),
                        ),
                        const SizedBox(height: 20),
                        Text('وام‌ای نداری', style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)),
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
                      final progress = loan.paidAmount / loan.totalAmount;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          elevation: 2,
                          shadowColor: Colors.black12,
                          child: ExpansionTile(
                            shape: const RoundedRectangleBorder(side: BorderSide.none),
                            title: Text(loan.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 7,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(progress > 0.75 ? const Color(0xFF11998E) : const Color(0xFF4F6BF5)),
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('مبلغ کل', '${formatAmount(loan.totalAmount)} تومان'),
                                    _buildDetailRow('قسط ماهیانه', '${formatAmount(loan.monthlyPayment)} تومان'),
                                    _buildDetailRow('پرداخت شده', '${formatAmount(loan.paidAmount)} تومان'),
                                    _buildDetailRow('باقی مانده', '${formatAmount(loan.remainingAmount)} تومان', const Color(0xFFE64A19)),
                                    _buildDetailRow('تاریخ شروع', _formatDateToJalali(loan.startDate)),
                                    _buildDetailRow('تاریخ پایان', _formatDateToJalali(loan.endDate)),
                                    _buildDetailRow('ماه‌های باقی', '${loan.remainingMonths}'),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ActionButton(
                                            icon: Icons.payment_rounded,
                                            label: 'پرداخت قسط',
                                            gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                                            onTap: () => _showPaymentDialog(context, provider, loan),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _ActionButton(
                                            icon: Icons.delete_outline_rounded,
                                            label: 'حذف',
                                            gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                                            onTap: () => _showDeleteDialog(context, provider, loan),
                                          ),
                                        ),
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
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, LoanProvider loanProvider, Loan loan) {
    final amountController = TextEditingController(text: loan.monthlyPayment.toString());
    int? selectedBankIndex;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('پرداخت قسط', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('وام: ${loan.bankName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('قسط پیش‌فرض: ${formatAmount(loan.monthlyPayment)} تومان', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 15),
                TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'مبلغ پرداخت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
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
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0 && selectedBankIndex != null) {
                    final bankProvider = context.read<BankProvider>();
                    final transProvider = context.read<TransactionProvider>();
                    final bank = bankProvider.banks[selectedBankIndex!];

                    loanProvider.payLoanInstallment(loan.id!, amount);

                    final updatedBank = Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance - amount);
                    bankProvider.updateBank(updatedBank);

                    final transaction = Transaction(title: 'پرداخت قسط وام', description: loan.bankName, amount: amount, type: TransactionType.expense, category: 'وام', date: DateTime.now(), bankId: bank.id);
                    transProvider.addTransaction(transaction);

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قسط پرداخت شد ✅')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11998E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('تأیید', style: TextStyle(color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف وام', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: const Text('آیا مطمئن‌اید؟'),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))],
            ),
          ),
        ),
      ),
    );
  }
}
