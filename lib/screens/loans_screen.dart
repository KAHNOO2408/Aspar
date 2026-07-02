import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      appBar: buildCustomAppBar(title: 'وام', context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLoanScreen())),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body: Consumer<LoanProvider>(
        builder: (context, provider, _) {
          final totalLoans = provider.getTotalRemainingLoans();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.withOpacity(0.9), Colors.purple.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('کل وام‌های باقی', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatAmount(totalLoans), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                              const Text('💳', style: TextStyle(fontSize: 48)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (provider.loans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(Icons.handshake, size: 100, color: Colors.grey[200]),
                        const SizedBox(height: 20),
                        const Text('وام‌ای نداری', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.loans.length,
                    itemBuilder: (context, index) {
                      final loan = provider.loans[index];
                      final progress = loan.paidAmount / loan.totalAmount;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ExpansionTile(
                            title: Text(loan.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation(progress > 0.75 ? Colors.green : Colors.blue)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('مبلغ کل', '${formatAmount(loan.totalAmount)} ریال'),
                                    _buildDetailRow('قسط ماهیانه', '${formatAmount(loan.monthlyPayment)} ریال'),
                                    _buildDetailRow('پرداخت شده', '${formatAmount(loan.paidAmount)} ریال'),
                                    _buildDetailRow('باقی مانده', '${formatAmount(loan.remainingAmount)} ریال', Colors.red),
                                    _buildDetailRow('تاریخ شروع', _formatDateToJalali(loan.startDate)),
                                    _buildDetailRow('تاریخ پایان', _formatDateToJalali(loan.endDate)),
                                    _buildDetailRow('ماه‌های باقی', '${loan.remainingMonths}'),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _showPaymentDialog(context, provider, loan),
                                          icon: const Icon(Icons.payment, size: 18),
                                          label: const Text('پرداخت قسط'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showDeleteDialog(context, provider, loan),
                                          icon: const Icon(Icons.delete, size: 18),
                                          label: const Text('حذف'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

                const SizedBox(height: 20),
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
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor ?? Colors.black)),
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
            title: const Text('پرداخت قسط', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('وام: ${loan.bankName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('قسط پیش‌فرض: ${formatAmount(loan.monthlyPayment)} ریال', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مبلغ پرداخت',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) {
                    return DropdownButtonFormField<int>(
                      value: selectedBankIndex,
                      hint: const Text('انتخاب بانک پرداخت *'),
                      items: List.generate(bankProvider.banks.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text('${bankProvider.banks[i].bankName} - ${formatAmount(bankProvider.banks[i].balance)}'),
                        );
                      }),
                      onChanged: (value) => setState(() => selectedBankIndex = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
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

                    final updatedBank = Bank(
                      id: bank.id,
                      bankName: bank.bankName,
                      accountNumber: bank.accountNumber,
                      balance: bank.balance - amount,
                    );
                    bankProvider.updateBank(updatedBank);

                    final transaction = Transaction(
                      title: 'پرداخت قسط وام',
                      description: loan.bankName,
                      amount: amount,
                      type: TransactionType.expense,
                      category: 'وام',
                      date: DateTime.now(),
                      bankId: bank.id,
                    );
                    transProvider.addTransaction(transaction);

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قسط پرداخت شد ✅')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        title: const Text('حذف وام', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: const Text('آیا مطمئن‌اید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              provider.deleteLoan(loan.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
