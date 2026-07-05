import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  TransactionType? selectedType = TransactionType.income;
  String selectedCategory = 'حقوق';
  int? selectedBankId;

  final categories = {
    'income': ['حقوق', 'فریلنس', 'سرمایه‌گذاری', 'دیگر'],
    'expense': ['غذا', 'حمل‌ونقل', 'خانه', 'سلامت', 'تفریح', 'دیگر'],
  };

  InputDecoration _decoration(BuildContext context, String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4F6BF5)),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(14),
        labelStyle: TextStyle(color: AppColors.textSecondary(context)),
      );

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == TransactionType.income;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('اضافه کردن تراکنش')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _TypeButton(label: 'درآمد', selected: isIncome, gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)], onTap: () => setState(() => selectedType = TransactionType.income))),
                const SizedBox(width: 12),
                Expanded(child: _TypeButton(label: 'خرج', selected: !isIncome, gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)], onTap: () => setState(() => selectedType = TransactionType.expense))),
              ],
            ),
            const SizedBox(height: 20),
            TextField(controller: titleController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'عنوان', Icons.title_rounded)),
            const SizedBox(height: 15),
            TextField(controller: descriptionController, maxLines: 2, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'توضیح', Icons.description_outlined)),
            const SizedBox(height: 15),
            TextField(controller: amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'مبلغ (تومان)', Icons.payments_outlined)),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories[isIncome ? 'income' : 'expense']!.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: _decoration(context, 'دسته‌بندی', Icons.category_outlined),
              style: TextStyle(color: AppColors.text(context)),
            ),
            const SizedBox(height: 15),
            Consumer<BankProvider>(
              builder: (context, bankProvider, _) {
                return DropdownButtonFormField<int>(
                  value: selectedBankId,
                  hint: const Text('انتخاب بانک *'),
                  items: bankProvider.banks.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان'))).toList(),
                  onChanged: (value) => setState(() => selectedBankId = value),
                  decoration: _decoration(context, 'بانک *', Icons.account_balance_outlined),
                  style: TextStyle(color: AppColors.text(context)),
                );
              },
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: isIncome ? const [Color(0xFF11998E), Color(0xFF38EF7D)] : const [Color(0xFFFF7A59), Color(0xFFE64A19)]), boxShadow: [BoxShadow(color: (isIncome ? const Color(0xFF11998E) : const Color(0xFFE64A19)).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))]),
              child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: _addTransaction, child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('اضافه کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))))),
            ),
          ],
        ),
      ),
    );
  }

  void _addTransaction() {
    if (titleController.text.isEmpty || amountController.text.isEmpty || selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عنوان، مبلغ و بانک الزامی هستند!')));
      return;
    }
    final amount = double.tryParse(amountController.text) ?? 0;
    final bankProvider = context.read<BankProvider>();
    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

    final transaction = Transaction(title: titleController.text, description: descriptionController.text, amount: amount, type: selectedType!, category: selectedCategory, date: DateTime.now(), bankId: selectedBankId);

    final updatedBank = Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: selectedType == TransactionType.income ? bank.balance + amount : bank.balance - amount);
    bankProvider.updateBank(updatedBank);
    context.read<TransactionProvider>().addTransaction(transaction);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اضافه شد ✅')));
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _TypeButton({required this.label, required this.selected, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: selected ? LinearGradient(colors: gradient) : null,
        color: selected ? null : AppColors.card(context),
        boxShadow: selected ? [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700)))),
        ),
      ),
    );
  }
}
