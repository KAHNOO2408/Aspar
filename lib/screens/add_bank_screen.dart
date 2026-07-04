import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({Key? key}) : super(key: key);
  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final balanceController = TextEditingController();

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      );

  void _saveBank() async {
    try {
      if (bankNameController.text.isEmpty || balanceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فیلدهای الزامی را پر کنید')));
        return;
      }
      final bank = Bank(
        id: DateTime.now().millisecondsSinceEpoch,
        bankName: bankNameController.text,
        accountNumber: accountNumberController.text,
        balance: double.parse(balanceController.text),
      );
      await Provider.of<BankProvider>(context, listen: false).addBank(bank);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بانک اضافه شد')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(title: const Text('اضافه کردن بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نام بانک', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(controller: bankNameController, decoration: _decoration('', hint: 'مثل: بانک ملی')),
            const SizedBox(height: 20),
            Text('شماره حساب', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(controller: accountNumberController, decoration: _decoration('', hint: '1234567890')),
            const SizedBox(height: 20),
            Text('موجودی (تومان)', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(controller: balanceController, keyboardType: TextInputType.number, decoration: _decoration('', hint: '1000000')),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
                boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _saveBank,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text('اضافه کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
