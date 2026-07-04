import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../models/contact_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import '../utils/formatters.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtType type;
  const AddDebtScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final paidNowController = TextEditingController();
  Contact? selectedContact;
  int? selectedBankId;
  DateTime selectedDate = DateTime.now();

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.fromDateTime(selectedDate),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      setState(() => selectedDate = picked.toDateTime());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPurchase = widget.type == DebtType.owed;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPurchase ? 'ثبت خرید (بدهی جدید)' : 'ثبت فروش (طلب جدید)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتخاب مخاطب *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: const Text('مخاطب را انتخاب کنید'),
                  value: selectedContact,
                  items: contactProvider.contacts.map((contact) {
                    return DropdownMenuItem(value: contact, child: Text(contact.fullName));
                  }).toList(),
                  onChanged: (contact) => setState(() => selectedContact = contact),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: isPurchase ? 'کالا / بابت خرید *' : 'کالا / بابت فروش *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ کل معامله *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_formatDateToJalali(selectedDate)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  isPurchase ? '💰 پرداخت فوری (اختیاری - اگه همون لحظه پول دادی)' : '💰 دریافت فوری (اختیاری - اگه همون لحظه پول گرفتی)',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: paidNowController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: isPurchase ? 'مبلغ پرداخت شده الان' : 'مبلغ دریافت شده الان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                if ((double.tryParse(paidNowController.text) ?? 0) > 0) ...[
                  const SizedBox(height: 15),
                  Consumer<BankProvider>(
                    builder: (context, bankProvider, _) {
                      return DropdownButtonFormField<int>(
                        value: selectedBankId,
                        hint: const Text('انتخاب بانک *'),
                        items: bankProvider.banks.map((bank) {
                          return DropdownMenuItem<int>(
                            value: bank.id,
                            child: Text('${bank.bankName} - ${formatAmount(bank.balance)}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedBankId = value),
                        decoration: InputDecoration(
                          labelText: 'بانک *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPurchase ? Colors.red : Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ثبت کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit() async {
    if (selectedContact == null || amountController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب، کالا و مبلغ الزامی هستند')));
      return;
    }

    final totalAmount = double.tryParse(amountController.text) ?? 0;
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد')));
      return;
    }

    final paidNow = double.tryParse(paidNowController.text) ?? 0;
    if (paidNow > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداختی نمی‌تواند بیشتر از مبلغ کل باشد')));
      return;
    }
    if (paidNow > 0 && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای مبلغ پرداختی، انتخاب بانک الزامی است')));
      return;
    }

    final debtProvider = context.read<DebtProvider>();
    final sameType = widget.type;
    final oppositeType = sameType == DebtType.owed ? DebtType.receivable : DebtType.owed;

    // ساخت رکورد جدید بدهی/طلب
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newDebt = Debt(
      id: newId,
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      totalAmount: totalAmount,
      description: descriptionController.text,
      date: selectedDate,
      type: sameType,
      paidAmount: paidNow,
    );
    await debtProvider.addDebt(newDebt);

    // خالص‌سازی خودکار با بدهی/طلب مخالف همین مخاطب
    final oppositeDebts = debtProvider.debts
        .where((d) =>
            d.personName == selectedContact!.firstName &&
            d.personFamily == selectedContact!.lastName &&
            d.type == oppositeType &&
            d.remainder > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double remainingNew = totalAmount - paidNow;
    for (final oppDebt in oppositeDebts) {
      if (remainingNew <= 0) break;
      final offset = remainingNew < oppDebt.remainder ? remainingNew : oppDebt.remainder;
      oppDebt.paidAmount += offset;
      await debtProvider.editDebt(oppDebt);
      remainingNew -= offset;
    }

    newDebt.paidAmount = totalAmount - remainingNew;
    await debtProvider.editDebt(newDebt);

    // ثبت پرداخت/دریافت فوری (اگه بود)
    if (paidNow > 0) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

      final updatedBank = Bank(
        id: bank.id,
        bankName: bank.bankName,
        accountNumber: bank.accountNumber,
        balance: sameType == DebtType.owed ? bank.balance - paidNow : bank.balance + paidNow,
      );
      await bankProvider.updateBank(updatedBank);

      final transaction = Transaction(
        title: sameType == DebtType.owed ? 'پرداخت به مخاطب' : 'دریافت از مخاطب',
        description: '${selectedContact!.fullName} - ${descriptionController.text}',
        amount: paidNow,
        type: sameType == DebtType.owed ? TransactionType.expense : TransactionType.income,
        category: 'معامله با مخاطب',
        date: selectedDate,
        bankId: bank.id,
      );
      await transProvider.addTransaction(transaction);

      final payment = Payment(
        debtId: newId,
        amount: paidNow,
        date: selectedDate,
        description: descriptionController.text,
        type: sameType == DebtType.owed ? PaymentType.debtPayment : PaymentType.receivablePayment,
        bankId: bank.id,
      );
      await paymentProvider.addPayment(payment);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    paidNowController.dispose();
    super.dispose();
  }
}
