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

class BankWithdrawalScreen extends StatefulWidget {
  const BankWithdrawalScreen({Key? key}) : super(key: key);
  @override
  State<BankWithdrawalScreen> createState() => _BankWithdrawalScreenState();
}

class _BankWithdrawalScreenState extends State<BankWithdrawalScreen> {
  final amountController = TextEditingController();
  final feeController = TextEditingController();
  final trackingCodeController = TextEditingController();
  final noteController = TextEditingController();
  Contact? selectedContact;
  int? selectedBankId;
  DateTime selectedDate = DateTime.now();
  bool _isSubmitting = false;

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

  Future<void> _pickContact() async {
    final contactProvider = context.read<ContactProvider>();
    final searchController = TextEditingController();

    final result = await showDialog<Contact>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = contactProvider.contacts.where((c) => c.fullName.toLowerCase().contains(query)).toList();

            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('انتخاب مخاطب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setDialogState(() {}),
                      style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                      decoration: InputDecoration(hintText: 'جستجو...', hintStyle: const TextStyle(fontFamily: _fontFamily), prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('مخاطبی یافت نشد', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontWeight: FontWeight.w600, fontFamily: _fontFamily)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final contact = filtered[index];
                                return ListTile(
                                  title: Text(contact.fullName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                                  onTap: () => Navigator.pop(dialogContext, contact),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) setState(() => selectedContact = result);
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 0;
    final fee = double.tryParse(feeController.text) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('برداشت از بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF7A59), Color(0xFFE64A19)]), borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text('برای وقتی که از حساب بانکی تو به یک مخاطب پول پرداخت میشه', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily)))]),
            ),
            const SizedBox(height: 20),

            // مخاطب (دکمه)
            InkWell(
              onTap: _pickContact,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedContact == null ? AppColors.divider(context) : const Color(0xFFE64A19), width: 2)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF7A59), Color(0xFFE64A19)]), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(selectedContact?.fullName ?? 'انتخاب مخاطب *', style: TextStyle(color: selectedContact != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بانک
            Consumer<BankProvider>(
              builder: (context, bankProvider, _) => DropdownButtonFormField<int>(
                value: selectedBankId,
                hint: Text('انتخاب بانک', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                items: bankProvider.banks.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان', style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                onChanged: (value) => setState(() => selectedBankId = value),
                decoration: _decoration(context, 'بانک مبدا *'),
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              ),
            ),
            const SizedBox(height: 16),

            // مبلغ
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'مبلغ (تومان) *'),
            ),
            if (amount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFF7A59).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(amount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE64A19))),
                ),
              ),
            const SizedBox(height: 16),

            // کارمزد
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'کارمزد (تومان) - اختیاری'),
            ),
            if (fee > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFF7A59).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(fee)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE64A19))),
                ),
              ),
            const SizedBox(height: 16),

            // کد رهگیری
            TextField(
              controller: trackingCodeController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'کد رهگیری *'),
            ),
            const SizedBox(height: 16),

            // یادداشت
            TextField(
              controller: noteController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'یادداشت (اختیاری)'),
            ),
            const SizedBox(height: 16),

            // تاریخ
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFFE64A19)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // دکمه ثبت
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFFFF7A59), Color(0xFFE64A19)]),
                boxShadow: [BoxShadow(color: const Color(0xFFE64A19).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('ثبت برداشت', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_isSubmitting) return;
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
    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

    if (amount + fee > bank.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('موجودی بانک کافی نیست (با احتساب کارمزد)')));
      return;
    }

    setState(() => _isSubmitting = true);

    final transProvider = context.read<TransactionProvider>();
    final ledgerProvider = context.read<LedgerProvider>();

    await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance - amount - fee));

    final ledgerDescription = noteController.text.isNotEmpty ? 'برداشت از بانک - ${noteController.text}' : 'برداشت از بانک';

    await ledgerProvider.insertLedgerEntry(LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: ledgerDescription,
      debitAmount: amount,
      bankId: bank.id,
      trackingCode: trackingCodeController.text,
    ));

    await transProvider.insertTransaction(Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'برداشت از بانک',
      description: 'برداشت از بانک',
      amount: amount,
      type: TransactionType.expense,
      category: 'برداشت بانکی',
      date: selectedDate,
      bankId: bank.id,
      contactName: selectedContact!.fullName,
    ));

    if (fee > 0) {
      await transProvider.insertTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        title: 'کارمزد برداشت',
        description: 'کارمزد برداشت به ${selectedContact!.fullName}',
        amount: fee,
        type: TransactionType.expense,
        category: 'کارمزد',
        date: selectedDate,
        bankId: bank.id,
      ));
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برداشت ثبت شد ✅')));
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
