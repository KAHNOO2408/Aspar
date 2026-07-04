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

class BankDepositScreen extends StatefulWidget {
  const BankDepositScreen({Key? key}) : super(key: key);

  @override
  State<BankDepositScreen> createState() => _BankDepositScreenState();
}

class _BankDepositScreenState extends State<BankDepositScreen> {
  final amountController = TextEditingController();
  final trackingCodeController = TextEditingController();
  final noteController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(title: const Text('واریز به بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'برای وقتی که یک مخاطب پول به حساب بانکی تو واریز می‌کنه',
                    style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('واریزکننده (مخاطب) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: const Text('انتخاب کنید'),
                  value: selectedContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
                  onChanged: (c) => setState(() => selectedContact = c),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('بانک مقصد *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) {
                    return DropdownButtonFormField<int>(
                      value: selectedBankId,
                      hint: const Text('انتخاب بانک'),
                      items: bankProvider.banks.map((bank) {
                        return DropdownMenuItem<int>(
                          value: bank.id,
                          child: Text('${bank.bankName} - ${formatAmount(bank.balance)}'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedBankId = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: trackingCodeController,
                  decoration: InputDecoration(
                    labelText: 'کد رهگیری *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'یادداشت (اختیاری)',
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

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ثبت واریز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
    if (selectedContact == null || selectedBankId == null || amountController.text.isEmpty || trackingCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب، بانک، مبلغ و کد رهگیری الزامی هستند')));
      return;
    }
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد')));
      return;
    }

    final bankProvider = context.read<BankProvider>();
    final debtProvider = context.read<DebtProvider>();
    final transProvider = context.read<TransactionProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

    // موجودی بانک زیاد میشه
    final updatedBank = Bank(
      id: bank.id,
      bankName: bank.bankName,
      accountNumber: bank.accountNumber,
      balance: bank.balance + amount,
    );
    await bankProvider.updateBank(updatedBank);

    // واریز از مخاطب یعنی طلب اون از من کم میشه (یا اگه طلبی نداشت، حالا من بهش بدهکار میشم)
    final debtId = await debtProvider.applyContactPayment(
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      amount: amount,
      reduceType: DebtType.receivable,
      date: selectedDate,
      description: 'واریز به بانک - کد رهگیری: ${trackingCodeController.text}',
    );

    final noteText = noteController.text.isNotEmpty
        ? 'کد رهگیری: ${trackingCodeController.text} - ${noteController.text}'
        : 'کد رهگیری: ${trackingCodeController.text}';

    final transaction = Transaction(
      title: 'واریز به بانک',
      description: '${selectedContact!.fullName} - $noteText',
      amount: amount,
      type: TransactionType.income,
      category: 'واریز بانکی',
      date: selectedDate,
      bankId: bank.id,
    );
    transProvider.addTransaction(transaction);

    final payment = Payment(
      debtId: debtId,
      amount: amount,
      date: selectedDate,
      description: noteText,
      type: PaymentType.receivablePayment,
      bankId: bank.id,
    );
    await paymentProvider.addPayment(payment);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('واریز ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    trackingCodeController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
