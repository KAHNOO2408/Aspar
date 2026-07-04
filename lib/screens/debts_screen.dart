import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
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
            final owedDebts = provider.debts.where((d) => d.type == DebtType.owed && d.remainder > 0).toList();
            final receivableDebts = provider.debts.where((d) => d.type == DebtType.receivable && d.remainder > 0).toList();

            return TabBarView(
              children: [
                _buildDebtList(context, provider, owedDebts, DebtType.owed, Colors.red, 'کل بدهی‌های من', 'بدهی‌ای نداری', '📤'),
                _buildDebtList(context, provider, receivableDebts, DebtType.receivable, Colors.green, 'کل طلب‌های من', 'طلبی ندارم', '📥'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDebtList(BuildContext context, DebtProvider provider, List<Debt> debts, DebtType type, Color color, String totalTitle, String emptyText, String emoji) {
    final total = type == DebtType.owed ? provider.getTotalOwed(null, null) : provider.getTotalReceivable(null, null);

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
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(totalTitle, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatAmount(total), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                            const Text('ریال', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Text(emoji, style: const TextStyle(fontSize: 48)),
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddDebtScreen(type: type))),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('اضافه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (debts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  Icon(Icons.done_all, size: 100, color: Colors.grey[200]),
                  const SizedBox(height: 20),
                  Text(emptyText, style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
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
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Icon(Icons.person, color: color, size: 24)),
                      ),
                      title: Text('${debt.personName} ${debt.personFamily}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(_formatDateToJalali(debt.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatAmount(debt.remainder), style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
                              const Text('ریال', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(context, provider, debt);
                              } else if (value == 'delete') {
                                _showDeleteConfirm(context, provider, debt);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف')])),
                            ],
                          ),
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
    );
  }

  void _showEditDialog(BuildContext context, DebtProvider debtProvider, Debt debt) {
    final nameController = TextEditingController(text: debt.personName);
    final familyController = TextEditingController(text: debt.personFamily);
    final totalController = TextEditingController(text: debt.totalAmount.toStringAsFixed(0));
    final descController = TextEditingController(text: debt.description);
    DateTime selectedDate = debt.date;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('ویرایش', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'نام', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: familyController,
                    decoration: InputDecoration(labelText: 'نام خانوادگی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'مبلغ کل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'توضیح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(
                        context: dialogContext,
                        initialDate: Jalali.fromDateTime(selectedDate),
                        firstDate: Jalali(1390, 1),
                        lastDate: Jalali(1420, 12, 29),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked.toDateTime());
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_formatDateToJalali(selectedDate)),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () {
                  final newTotal = double.tryParse(totalController.text) ?? debt.totalAmount;
                  if (newTotal < debt.paidAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('مبلغ کل نمی‌تواند کمتر از مبلغ پرداخت‌شده باشد')),
                    );
                    return;
                  }
                  final updatedDebt = Debt(
                    id: debt.id,
                    personName: nameController.text,
                    personFamily: familyController.text,
                    totalAmount: newTotal,
                    description: descController.text,
                    date: selectedDate,
                    type: debt.type,
                    paidAmount: debt.paidAmount,
                  );
                  debtProvider.editDebt(updatedDebt);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, DebtProvider debtProvider, Debt debt) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text('آیا از حذف «${debt.personName} ${debt.personFamily}» مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              debtProvider.deleteDebt(debt.id!);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                Text('باقی‌مانده: ${formatAmount(debt.remainder)} ریال', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
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
