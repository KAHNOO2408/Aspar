import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/bank_model.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({Key? key}) : super(key: key);

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  late TextEditingController bankNameController;
  late TextEditingController accountNumberController;
  late TextEditingController balanceController;

  @override
  void initState() {
    super.initState();
    bankNameController = TextEditingController();
    accountNumberController = TextEditingController();
    balanceController = TextEditingController();
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void _saveBank() async {
    try {
      if (bankNameController.text.isEmpty || balanceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فیلدهای الزامی را پر کنید')),
        );
        return;
      }

      final bank = Bank(
        bankName: bankNameController.text,
        accountNumber: accountNumberController.text,
        balance: double.parse(balanceController.text),
      );

      // Hive میں ذخیره کریں
      final box = Hive.box<Bank>('banks');
      await box.add(bank);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بانک اضافه شد')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('خطا: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اضافه کردن بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نام بانک', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: bankNameController,
              decoration: InputDecoration(
                hintText: 'مثل: بانک ملی',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('شماره حساب', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: accountNumberController,
              decoration: InputDecoration(
                hintText: '1234567890',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('موجودی (ریال)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1000000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBank,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('اضافه کن', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
