import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/contact_model.dart';
import '../models/ledger_model.dart';
import '../utils/app_colors.dart';

class TransferBetweenAccountsScreen extends StatefulWidget {
  const TransferBetweenAccountsScreen({Key? key}) : super(key: key);
  @override
  State<TransferBetweenAccountsScreen> createState() => _TransferBetweenAccountsScreenState();
}

class _TransferBetweenAccountsScreenState extends State<TransferBetweenAccountsScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  Contact? payerContact;
  Contact? receiverContact;
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
      appBar: AppBar(title: const Text('دریافت و پرداخت بین حساب‌ها')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]), borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text('برای وقتی که یک نفر به‌جای تو، مستقیم به شخص دیگه‌ای پول پرداخت می‌کنه', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily)))]),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: Text('انتخاب کنید', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                  value: payerContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName, style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                  onChanged: (c) => setState(() => payerContact = c),
                  decoration: _decoration(context, 'پرداخت‌کننده *'),
                  style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: Text('انتخاب کنید', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                  value: receiverContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName, style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                  onChanged: (c) => setState(() => receiverContact = c),
                  decoration: _decoration(context, 'دریافت‌کننده *'),
                  style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                ),
                const SizedBox(height: 16),
                TextField(controller: amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'مبلغ (تومان) *')),
                const SizedBox(height: 16),
                TextField(controller: noteController, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'یادداشت (اختیاری)')),
                const SizedBox(height: 16),
                _DateButton(label: _formatDateToJalali(selectedDate), onTap: _pickDate),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]), boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))]),
                  child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: _submit, child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('ثبت کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))))),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit() async {
    if (payerContact == null || receiverContact == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت‌کننده، دریافت‌کننده و مبلغ الزامی هستند')));
      return;
    }
    if (payerContact!.id == receiverContact!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت‌کننده و دریافت‌کننده نمی‌توانند یکی باشند')));
      return;
    }
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد')));
      return;
    }

    final ledgerProvider = context.read<LedgerProvider>();
    final note = noteController.text.isNotEmpty ? noteController.text : 'انتقال واسطه‌ای';

    await ledgerProvider.addEntry(LedgerEntry(personName: payerContact!.firstName, personFamily: payerContact!.lastName, date: selectedDate, description: 'پرداخت واسطه‌ای به ${receiverContact!.fullName} - $note', creditAmount: amount));
    await ledgerProvider.addEntry(LedgerEntry(personName: receiverContact!.firstName, personFamily: receiverContact!.lastName, date: selectedDate, description: 'دریافت واسطه‌ای از ${payerContact!.fullName} - $note', debitAmount: amount));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تسویه‌ی واسطه‌ای ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6A3DE8)), const SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context)))]),
          ),
        ),
      ),
    );
  }
}
