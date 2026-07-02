import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profit_model.dart';
import '../models/bank_model.dart';
import '../utils/formatters.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({Key? key}) : super(key: key);

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final productNameController = TextEditingController();
  final quantityController = TextEditingController();
  final pricePerUnitController = TextEditingController();
  final descriptionController = TextEditingController();

  TransactionType? selectedType = TransactionType.purchase;
  int? selectedBankId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اضافه کردن خرید/فروش')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedType = TransactionType.purchase),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedType == TransactionType.purchase ? Colors.red : Colors.grey[300],
                    ),
                    child: Text('خرید', style: TextStyle(color: selectedType == TransactionType.purchase ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedType = TransactionType.sale),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedType == TransactionType.sale ? Colors.green : Colors.grey[300],
                    ),
                    child: Text('فروش', style: TextStyle(color: selectedType == TransactionType.sale ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: 'نام کالا *',
                prefixIcon: const Icon(Icons.shopping_bag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'تعداد *',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: pricePerUnitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'قیمت واحد *',
                prefixIcon: const Icon(Icons.attach_money),
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
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedType == TransactionType.purchase ? Colors.red : Colors.green,
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
    if (productNameController.text.isEmpty || quantityController.text.isEmpty || pricePerUnitController.text.isEmpty || selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمام فیلدها الزامی هستند!')));
      return;
    }

    final quantity = double.tryParse(quantityController.text) ?? 0;
    final pricePerUnit = double.tryParse(pricePerUnitController.text) ?? 0;
    final totalAmount = quantity * pricePerUnit;

    final profitProvider = context.read<ProfitProvider>();
    final bankProvider = context.read<BankProvider>();

    final transaction = ProfitTransaction(
      productName: productNameController.text,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      totalPrice: totalAmount,
      type: selectedType!,
      date: DateTime.now(),
      bankId: selectedBankId,
      description: descriptionController.text,
    );

    final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);
    final updatedBank = Bank(
      id: bank.id,
      bankName: bank.bankName,
      accountNumber: bank.accountNumber,
      balance: selectedType == TransactionType.purchase
        ? bank.balance - totalAmount
        : bank.balance + totalAmount,
    );
    bankProvider.updateBank(updatedBank);

    profitProvider.addTransaction(transaction);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اضافه شد ✅')));
  }

  @override
  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    pricePerUnitController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
