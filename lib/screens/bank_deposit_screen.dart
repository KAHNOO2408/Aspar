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
      appBar: AppBar(title: const Text('واریز به بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C6A9), Color(0xFF00897B)]), borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text('برای وقتی که یک مخاطب پول به حساب بانکی تو واریز می‌کنه', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily)))]),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _pickContact,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedContact == null ? AppColors.divider(context) : const Color(0xFF00897B), width: 2)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00C6A9), Color(0xFF00897B)]), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(selectedContact?.fullName ?? 'انتخاب مخاطب *', style: TextStyle(color: selectedContact != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                  ],
                ),
              ),
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
                  decoration: BoxDecoration(color: const Color(0xFF00C6A9).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(amount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF00897B))),
                ),
              ),
            const SizedBox(height: 16),

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
                  decoration: BoxDecoration(color: const Color(0xFF00C6A9).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(fee)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF00897B))),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: trackingCodeController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'کد رهگیری *'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: noteController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'یادداشت (اختیاری)'),
            ),
            const SizedBox(height: 16),

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
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00897B)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF00C6A9), Color(0xFF00897B)]),
                boxShadow: [BoxShadow(color: const Color(0xFF00897B).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
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
                          : const Text('ثبت واریز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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

    setState(() => _isSubmitting = true);

    final bankProvider = context.read<BankProvider>();
    final transProvider = context.read<TransactionProvider>();
    final ledgerProvider = context.read<LedgerProvider>();
    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

    await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance + amount - fee));

    final ledgerDescription = noteController.text.isNotEmpty ? 'واریز به بانک - ${noteController.text}' : 'واریز به بانک';

    await ledgerProvider.addEntry(LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: ledgerDescription,
      creditAmount: amount,
      bankId: bank.id,
      trackingCode: trackingCodeController.text,
    ));

    await transProvider.addTransaction(Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
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
      await transProvider.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        title: 'کارمزد واریز',
        description: 'کارمزد واریز از ${selectedContact!.fullName}',
        amount: fee,
        type: TransactionType.expense,
        category: 'کارمزد',
        date: selectedDate,
        bankId: bank.id,
      ));
    }

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
