import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/contact_model.dart';
import '../models/ledger_model.dart';

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
      appBar: AppBar(title: const Text('دریافت و پرداخت بین حساب‌ها')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    'برای وقتی که یک نفر به‌جای تو، مستقیم به شخص دیگه‌ای پول پرداخت می‌کنه (بدون این‌که از بانک تو رد بشه)',
                    style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('چه کسی پرداخت کرد؟ (پرداخت‌کننده) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: const Text('انتخاب کنید'),
                  value: payerContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
                  onChanged: (c) => setState(() => payerContact = c),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 20),

                const Text('به چه کسی پرداخت شد؟ (دریافت‌کننده) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: const Text('انتخاب کنید'),
                  value: receiverContact,
                  items: contactProvider.contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
                  onChanged: (c) => setState(() => receiverContact = c),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'مبلغ *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: 'یادداشت (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

    await ledgerProvider.addEntry(LedgerEntry(
      personName: payerContact!.firstName,
      personFamily: payerContact!.lastName,
      date: selectedDate,
      description: 'پرداخت واسطه‌ای به ${receiverContact!.fullName} - $note',
      creditAmount: amount,
    ));

    await ledgerProvider.addEntry(LedgerEntry(
      personName: receiverContact!.firstName,
      personFamily: receiverContact!.lastName,
      date: selectedDate,
      description: 'دریافت واسطه‌ای از ${payerContact!.fullName} - $note',
      debitAmount: amount,
    ));

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
