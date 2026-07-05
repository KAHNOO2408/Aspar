import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/contact_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/ledger_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class BankDepositScreen extends StatefulWidget {
  const BankDepositScreen({Key? key}) : super(key: key);
  @override
  State<BankDepositScreen> createState() => _BankDepositScreenState();
}

class _BankDepositScreenState extends State<BankDepositScreen> {
  final amountController = TextEditingController();
  final feeController = TextEditingController();
  final trackingCodeController = TextEditingController();
  final noteController = TextEditingController();
  Contact? selectedContact;
  int? selectedBankId;
  DateTime selectedDate = DateTime.now();

  static const _fontFamily = 'YekanBakh';

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
        hintStyle: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(14),
      );

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.fromDateTime(selectedDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedDate = picked.toDateTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('واریز به بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C6A9), Color(0xFF00897B)]), borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text('برای وقتی که یک مخاطب پول به حساب بانکی تو واریز می‌کنه', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily)))]),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: Text('انتخاب کنید', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                  value: selectedContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName, style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                  onChanged: (c) => setState(() => selectedContact = c),
                  decoration: _decoration(context, 'واریزکننده (مخاطب) *'),
                  style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                ),
                const SizedBox(height: 16),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) => DropdownButtonFormField<int>(
                    value: selectedBankId,
                    hint: Text('انتخاب بانک', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                    items: bankProvider.banks.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان', style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                    onChanged: (value) => setState(() => selectedBankId = value),
                    decoration: _decoration(context, 'بانک مقصد *'),
                    style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'مبلغ (تومان) *')),
                const SizedBox(height: 16),
                TextField(controller: feeController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'کارمزد (تومان) - اختیاری')),
                const SizedBox(height: 16),
                TextField(controller: trackingCodeController, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'کد رهگیری *')),
                const SizedBox(height: 16),
                TextField(controller: noteController, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'یادداشت (اختیاری)')),
                const SizedBox(height: 16),
                _DateButton(label: _formatDateToJalali(selectedDate), onTap: _pickDate, color: const Color(0xFF00897B)),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF00C6A9), Color(0xFF00897B)]), boxShadow: [BoxShadow(color: const Color(0xFF00897B).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))]),
                  child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: _submit, child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('ثبت واریز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))))),
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
    final fee = double.tryParse(feeController.text) ?? 0;

    final bankProvider = context.read<BankProvider>();
    final transProvider = context.read<TransactionProvider>();
    final ledgerProvider = context.read<LedgerProvider>();
    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

    await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance + amount - fee));

    final ledgerDescription = noteController.text.isNotEmpty ? 'واریز به بانک - ${noteController.text}' : 'واریز به بانک';

    transProvider.addTransaction(Transaction(
      title: 'واریز به بانک',
      description: 'واریز به بانک',
      amount: amount,
      type: TransactionType.income,
      category: 'واریز بانکی',
      date: selectedDate,
      bankId: bank.id,
      contactName: selectedContact!.fullName,
    ));

    if (fee > 0) {
      transProvider.addTransaction(Transaction(title: 'کارمزد واریز', description: 'کارمزد واریز از ${selectedContact!.fullName}', amount: fee, type: TransactionType.expense, category: 'کارمزد', date: selectedDate, bankId: bank.id));
    }

    await ledgerProvider.addEntry(LedgerEntry(personName: selectedContact!.firstName, personFamily: selectedContact!.lastName, date: selectedDate, description: ledgerDescription, creditAmount: amount, bankId: bank.id, trackingCode: trackingCodeController.text));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('واریز ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    feeController.dispose();
    trackingCodeController.dispose();
    noteController.dispose();
    super.dispose();
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _DateButton({required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
      child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, size: 16, color: color), const SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context)))])))),
    );
  }
}
