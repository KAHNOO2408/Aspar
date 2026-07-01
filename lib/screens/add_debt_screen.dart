import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt_model.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtType type;

  const AddDebtScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == DebtType.owed ? 'افزودن بدهی' : 'افزودن طلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'نام',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'نام خانوادگی',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'توضیح',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _addDebt,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.type == DebtType.owed ? Colors.red : Colors.green,
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

  void _addDebt() {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final amount = double.tryParse(amountController.text) ?? 0;
    final description = descriptionController.text;

    if (firstName.isEmpty || lastName.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تمام فیلدها را پر کنید')));
      return;
    }

    final debt = Debt(
      personName: firstName,
      personFamily: lastName,
      totalAmount: amount,
      description: description,
      date: DateTime.now(),
      type: widget.type,
    );

    context.read<DebtProvider>().addDebt(debt);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('افزودن شد ✅')));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
