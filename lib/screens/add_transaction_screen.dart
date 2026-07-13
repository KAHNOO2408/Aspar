import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../database/db_helper.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String transactionType = 'درآمد';
  String? selectedCategory;
  List<String> categories = [];
  DateTime selectedDate = DateTime.now();
  int? selectedBankId;
  int? selectedCashboxId;
  String? selectedPaymentMethod;
  bool _isSubmitting = false;

  static const _fontFamily = 'YekanBakh';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final saved = DatabaseHelper.authBox.get('categories_$transactionType');
    setState(() {
      categories = saved != null ? List<String>.from(saved) : [];
    });
  }

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
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

  void _showAddCategoryDialog() {
    final newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('دسته‌بندی جدید', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
        content: TextField(
          controller: newCategoryController,
          style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
          decoration: InputDecoration(labelText: 'نام دسته‌بندی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: _fontFamily))),
          ElevatedButton(
            onPressed: () async {
              if (newCategoryController.text.isNotEmpty) {
                final updated = {...categories, newCategoryController.text}.toList();
                await DatabaseHelper.authBox.put('categories_$transactionType', updated);
                setState(() {
                  categories = updated;
                  selectedCategory = newCategoryController.text;
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6BF5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('اضافه کن', style: TextStyle(color: Colors.white, fontFamily: _fontFamily)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBank() async {
    final bankProvider = context.read<BankProvider>();
    final banks = bankProvider.banks.where((b) => b.accountNumber != 'صندوق').toList();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتخاب بانک', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: banks.isEmpty
              ? Center(child: Text('بانکی موجود نیست', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontFamily: _fontFamily)))
              : ListView.builder(
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return ListTile(
                      title: Text(bank.bankName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                      subtitle: Text('${formatAmount(bank.balance)} تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontFamily: _fontFamily)),
                      onTap: () => Navigator.pop(dialogContext, bank.id),
                    );
                  },
                ),
        ),
      ),
    );

    if (result != null) setState(() => selectedBankId = result);
  }

  Future<void> _pickCashbox() async {
    final bankProvider = context.read<BankProvider>();
    final cashboxes = bankProvider.banks.where((b) => b.accountNumber == 'صندوق').toList();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتخاب صندوق', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: cashboxes.isEmpty
              ? Center(child: Text('صندوقی موجود نیست', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontFamily: _fontFamily)))
              : ListView.builder(
                  itemCount: cashboxes.length,
                  itemBuilder: (context, index) {
                    final cashbox = cashboxes[index];
                    return ListTile(
                      title: Text(cashbox.bankName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                      subtitle: Text('${formatAmount(cashbox.cashBox)} تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontFamily: _fontFamily)),
                      onTap: () => Navigator.pop(dialogContext, cashbox.id),
                    );
                  },
                ),
        ),
      ),
    );

    if (result != null) setState(() => selectedCashboxId = result);
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 0;
    final isIncome = transactionType == 'درآمد';
    final gradient = isIncome ? const [Color(0xFF11998E), Color(0xFF38EF7D)] : const [Color(0xFFFF7A59), Color(0xFFE64A19)];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('تراکنش جدید', style: TextStyle(fontFamily: _fontFamily))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(isIncome ? 'درآمد' : 'خرج', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                  Segmented(
                    options: const ['درآمد', 'خرج'],
                    selected: transactionType,
                    onOptionSelected: (value) {
                      setState(() {
                        transactionType = value;
                        selectedCategory = null;
                      });
                      _loadCategories();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider(context))),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      hint: Text('دسته‌بندی *', style: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily)),
                      underline: const SizedBox(),
                      items: [
                        ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)))),
                      ],
                      onChanged: (value) => setState(() => selectedCategory = value),
                      style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      dropdownColor: AppColors.card(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF4F6BF5)),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
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
                  decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(amount)} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1], fontFamily: _fontFamily)),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'توضیح (اختیاری)'),
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
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4F6BF5)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('${isIncome ? 'واریز به' : 'برداشت از'} (بانک یا صندوق) *', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedPaymentMethod == 'cash' ? LinearGradient(colors: gradient) : null,
                      color: selectedPaymentMethod != 'cash' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'cash' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() {
                          selectedPaymentMethod = selectedPaymentMethod == 'cash' ? null : 'cash';
                          selectedBankId = null;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('صندوق', style: TextStyle(color: selectedPaymentMethod == 'cash' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily))),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedPaymentMethod == 'card' ? LinearGradient(colors: gradient) : null,
                      color: selectedPaymentMethod != 'card' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'card' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() {
                          selectedPaymentMethod = selectedPaymentMethod == 'card' ? null : 'card';
                          selectedCashboxId = null;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('بانک', style: TextStyle(color: selectedPaymentMethod == 'card' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily))),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (selectedPaymentMethod == 'cash')
              InkWell(
                onTap: _pickCashbox,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedCashboxId == null ? AppColors.divider(context) : gradient[1], width: 2)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedCashboxId == null ? 'انتخاب صندوق' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedCashboxId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                          style: TextStyle(color: selectedCashboxId != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),

            if (selectedPaymentMethod == 'card')
              InkWell(
                onTap: _pickBank,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedBankId == null ? AppColors.divider(context) : gradient[1], width: 2)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.account_balance, color: Colors.white, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedBankId == null ? 'انتخاب بانک' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedBankId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                          style: TextStyle(color: selectedBankId != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: gradient),
                boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
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
                          : Text('ثبت ${transactionType == 'درآمد' ? 'درآمد' : 'خرج'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
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
    if (selectedCategory == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دسته‌بندی و مبلغ الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    if (selectedPaymentMethod == 'cash' && selectedCashboxId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انتخاب صندوق الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'card' && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انتخاب بانک الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انتخاب بانک یا صندوق الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    setState(() => _isSubmitting = true);

    final isIncome = transactionType == 'درآمد';
    final bankProvider = context.read<BankProvider>();
    final transProvider = context.read<TransactionProvider>();
    int selectedAccountId;

    if (selectedPaymentMethod == 'cash') {
      final cashbox = bankProvider.banks.firstWhere((b) => b.id == selectedCashboxId);
      selectedAccountId = cashbox.id;
      await bankProvider.updateBank(Bank(
        id: cashbox.id,
        bankName: cashbox.bankName,
        accountNumber: cashbox.accountNumber,
        balance: cashbox.balance,
        cashBox: isIncome ? cashbox.cashBox + amount : cashbox.cashBox - amount,
      ));
    } else {
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);
      selectedAccountId = bank.id;
      await bankProvider.updateBank(Bank(
        id: bank.id,
        bankName: bank.bankName,
        accountNumber: bank.accountNumber,
        balance: isIncome ? bank.balance + amount : bank.balance - amount,
        cashBox: bank.cashBox,
      ));
    }

    await transProvider.addTransaction(Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      title: selectedCategory ?? 'تراکنش',
      description: descriptionController.text,
      amount: amount,
      type: isIncome ? TransactionType.income : TransactionType.expense,
      category: selectedCategory ?? 'عمومی',
      date: selectedDate,
      bankId: selectedAccountId,
      contactName: '',
    ));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تراکنش ثبت شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class Segmented extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onOptionSelected;

  const Segmented({required this.options, required this.selected, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onOptionSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(option, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 11, fontFamily: 'YekanBakh')),
          ),
        );
      }).toList(),
    );
  }
}
