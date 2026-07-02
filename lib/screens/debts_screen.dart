import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/debt_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import '../widgets/custom_app_bar.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              buildCustomAppBar(title: 'حساب‌های باز', context: context),
              const TabBar(
                tabs: [
                  Tab(text: 'بدهی‌های من 📤'),
                  Tab(text: 'طلب‌های من 📥'),
                ],
              ),
            ],
          ),
        ),
        body: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final owedDebts = provider.debts.where((d) => d.type == DebtType.owed).toList();
            final receivableDebts = provider.debts.where((d) => d.type == DebtType.receivable).toList();

            return TabBarView(
              children: [
                // بدهی‌های من
                SingleChildScrollView(
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
                                colors: [Colors.red.withOpacity(0.9), Colors.red.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('کل بدهی‌های من', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${provider.getTotalOwed(null, null).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                                        const Text('ریال', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                    const Text('📤', style: TextStyle(fontSize: 48)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('فهرست تفصیلی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.owed))),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('اضافه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (owedDebts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            children: [
                              Icon(Icons.done_all, size: 100, color: Colors.grey[200]),
                              const SizedBox(height: 20),
                              const Text('بدهی‌ای نداری', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: owedDebts.length,
                          itemBuilder: (context, index) {
                            final debt = owedDebts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                    child: const Center(child: Icon(Icons.person, color: Colors.red, size: 24)),
                                  ),
                                  title: Text('${debt.personName} ${debt.personFamily}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text('${_formatDateToJalali(debt.date)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${debt.remainder.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red, fontSize: 14)),
                                      const Text('ریال', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  onTap: () => _showPaymentDialog(context, provider, debt),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // طلب‌های من
                SingleChildScrollView(
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
                                colors: [Colors.green.withOpacity(0.9), Colors.green.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('کل طلب‌های من', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${provider.getTotalReceivable(null, null).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                                        const Text('ریال', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                    const Text('📥', style: TextStyle(fontSize: 48)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('فهرست تفصیلی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.receivable))),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('اضافه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (receivableDebts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            children: [
                              Icon(Icons.done_all, size: 100, color: Colors.grey[200]),
                              const SizedBox(height: 20),
                              const Text('طلبی ندارم', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: receivableDebts.length,
                          itemBuilder: (context, index) {
                            final debt = receivableDebts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                    child: const Center(child: Icon(Icons.person, color: Colors.green, size: 24)),
                                  ),
                                  title: Text('${debt.personName} ${debt.personFamily}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text('${_formatDateToJalali(debt.date)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${debt.remainder.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 14)),
                                      const Text('ریال', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  onTap: () => _showPaymentDialog(context, provider, debt),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, DebtProvider debtProvider, Debt debt) {
    final amountController = TextEditingController();
    int? selectedBankIndex;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(debt.type == DebtType.owed ? 'پرداخت بدهی' : 'دریافت طلب', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('نام: ${debt.personName} ${debt.personFamily}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('باقی‌مانده: ${debt.remainder.toStringAsFixed(0)} ریال', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
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
                      hint: const Text('انتخاب بانک *'),
                      items: List.generate(bankProvider.banks.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text('${bankProvider.banks[i].bankName} - ${bankProvider.banks[i].balance.toStringAsFixed(0)}'),
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
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف', style: TextStyle(fontWeight: FontWeight.w600))),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0 && amount <= debt.remainder && selectedBankIndex != null) {
                    final bankProvider = context.read<BankProvider>();
                    final transProvider = context.read<TransactionProvider>();
                    final paymentProvider = context.read<PaymentProvider>();
                    final bank = bankProvider.banks[selectedBankIndex!];

                    debtProvider.payDebt(debt.id!, amount);

                    final updatedBank = Bank(
                      id: bank.id,
                      bankName: bank.bankName,
                      accountNumber: bank.accountNumber,
                      balance: debt.type == DebtType.owed 
                        ? bank.balance - amount 
                        : bank.balance + amount,
                    );
                    bankProvider.updateBank(updatedBank);

                    final transaction = Transaction(
                      title: debt.type == DebtType.owed ? 'پرداخت بدهی' : 'دریافت طلب',
                      description: '${debt.personName} ${debt.personFamily}',
                      amount: amount,
                      type: debt.type == DebtType.owed ? TransactionType.expense : TransactionType.income,
                      category: 'پرداخت',
                      date: DateTime.now(),
                      bankId: bank.id,
                    );
                    transProvider.addTransaction(transaction);

                    final payment = Payment(
                      debtId: debt.id!,
                      amount: amount,
                      date: DateTime.now(),
                      description: debt.description,
                      type: debt.type == DebtType.owed ? PaymentType.debtPayment : PaymentType.receivablePayment,
                      bankId: bank.id,
                    );
                    paymentProvider.addPayment(payment);

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تسویه شد ✅', style: TextStyle(fontWeight: FontWeight.w600))));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: debt.type == DebtType.owed ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('تأیید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }
}
