import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../utils/formatters.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اضافه کردن تراکنش')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedType = TransactionType.income),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedType == TransactionType.income ? Colors.green : Colors.grey[300],
                    ),
                    child: Text('درآمد', style: TextStyle(color: selectedType == TransactionType.income ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedType = TransactionType.expense),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedType == TransactionType.expense ? Colors.red : Colors.grey[300],
                    ),
                    child: Text('خرج', style: TextStyle(color: selectedType == TransactionType.expense ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'عنوان',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'توضیح',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'مبلغ',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories[selectedType == TransactionType.income ? 'income' : 'expense']!
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: InputDecoration(
                labelText: 'دسته‌بندی',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            Consumer<BankProvider>(
              builder: (context, bankProvider, _) {
                return DropdownButtonFormField<int>(
                  value: selectedBankId,
                  hint: const Text('انتخاب بانک *'),
                  items: bankProvider.banks.map((bank) {
                    return DropdownMenuItem<int>(
                      value: bank.id,
                      child: Text('${bank.bankName} - ${formatAmount(bank.balance)} ریال'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedBankId = value),
                  decoration: InputDecoration(
                    labelText: 'بانک *',
                    prefixIcon: const Icon(Icons.account_balance, color: Colors.deepOrange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.deepOrange, width: 2)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedType == TransactionType.income ? Colors.green : Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('اضافه کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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

    final transaction = Transaction(
      title: titleController.text,
      description: descriptionController.text,
      amount: amount,
      type: selectedType!,
      category: selectedCategory,
      date: DateTime.now(),
      bankId: selectedBankId,
    );

    final updatedBank = Bank(
      id: bank.id,
      bankName: bank.bankName,
      accountNumber: bank.accountNumber,
      balance: selectedType == TransactionType.income ? bank.balance + amount : bank.balance - amount,
    );
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
