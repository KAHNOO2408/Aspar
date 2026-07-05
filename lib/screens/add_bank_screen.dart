import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';
import '../utils/app_colors.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({Key? key}) : super(key: key);
  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final balanceController = TextEditingController();
  bool _isSubmitting = false;

  InputDecoration _decoration(BuildContext context, String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
        labelStyle: TextStyle(color: AppColors.textSecondary(context)),
      );

  void _saveBank() async {
    if (_isSubmitting) return;
    try {
      if (bankNameController.text.isEmpty || balanceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فیلدهای الزامی را پر کنید')));
        return;
      }
      setState(() => _isSubmitting = true);
      final bank = Bank(id: DateTime.now().millisecondsSinceEpoch, bankName: bankNameController.text, accountNumber: accountNumberController.text, balance: double.parse(balanceController.text));
      await Provider.of<BankProvider>(context, listen: false).addBank(bank);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بانک اضافه شد')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('اضافه کردن بانک')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نام بانک', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary(context))),
            const SizedBox(height: 8),
            TextField(controller: bankNameController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, '', hint: 'مثل: بانک ملی')),
            const SizedBox(height: 20),
            Text('شماره حساب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary(context))),
            const SizedBox(height: 8),
            TextField(controller: accountNumberController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, '', hint: '1234567890')),
            const SizedBox(height: 20),
            Text('موجودی (تومان)', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary(context))),
            const SizedBox(height: 8),
            TextField(controller: balanceController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, '', hint: '1000000')),
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
                  onTap: _isSubmitting ? null : _saveBank,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('اضافه کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
}
