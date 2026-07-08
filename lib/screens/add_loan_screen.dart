import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/loan_model.dart';
import '../models/bank_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({Key? key}) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final bankNameController = TextEditingController();
  final principalController = TextEditingController();
  final interestPercentController = TextEditingController();
  final monthsController = TextEditingController();
  final paidAmountController = TextEditingController();
  final descController = TextEditingController();
  
  int? selectedBankId;
  DateTime selectedStartDate = DateTime.now();
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

  Future<void> _pickStartDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.fromDateTime(selectedStartDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedStartDate = picked.toDateTime());
  }

  @override
  Widget build(BuildContext context) {
    final principal = double.tryParse(principalController.text) ?? 0;
    final interestPercent = double.tryParse(interestPercentController.text) ?? 0;
    final months = int.tryParse(monthsController.text) ?? 0;
    
    final totalPayable = principal * (1 + (interestPercent / 100));
    final monthlyPayment = months > 0 ? totalPayable / months : 0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('ثبت وام جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: bankNameController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'نام بانک/مؤسسه *'),
            ),
            const SizedBox(height: 16),

            Consumer<BankProvider>(
              builder: (context, bankProvider, _) => DropdownButtonFormField<int>(
                value: selectedBankId,
                hint: Text('انتخاب حساب بانکی (اختیاری)', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                items: bankProvider.banks.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان', style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                onChanged: (value) => setState(() => selectedBankId = value),
                decoration: _decoration(context, 'حساب بانکی'),
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: principalController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'اصل وام (تومان) *'),
            ),
            if (principal > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(principal)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: monthsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'تعداد ماه *'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: interestPercentController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'درصد سود (اختیاری)'),
            ),
            const SizedBox(height: 16),

            if (principal > 0 && months > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مبلغ کل قابل بازپرداخت:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context), fontFamily: _fontFamily)),
                    Text('${formatAmount(totalPayable)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8), fontSize: 14, fontFamily: _fontFamily)),
                    const SizedBox(height: 8),
                    Text('قسط ماهیانه:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context), fontFamily: _fontFamily)),
                    Text('${formatAmount(monthlyPayment)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8), fontSize: 14, fontFamily: _fontFamily)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: paidAmountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'مبلغ پرداخت‌شده تاکنون (اختیاری)'),
            ),
            if (double.tryParse(paidAmountController.text) ?? 0 > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(double.tryParse(paidAmountController.text) ?? 0)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: descController,
              maxLines: 2,
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
                  onTap: _pickStartDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6A3DE8)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedStartDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
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
                gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]),
                boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
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
                          : const Text('ثبت وام', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
    if (bankNameController.text.isEmpty || principalController.text.isEmpty || monthsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام بانک، اصل وام و تعداد ماه الزامی هستند')));
      return;
    }

    final principal = double.tryParse(principalController.text) ?? 0;
    final months = int.tryParse(monthsController.text) ?? 0;
    
    if (principal <= 0 || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مقادیر باید بزرگتر از صفر باشند')));
      return;
    }

    setState(() => _isSubmitting = true);

    final interestPercent = double.tryParse(interestPercentController.text) ?? 0;
    final totalPayable = principal * (1 + (interestPercent / 100));
    final monthlyPayment = totalPayable / months;
    final endDate = DateTime(selectedStartDate.year, selectedStartDate.month + months, selectedStartDate.day);
    final paidAmount = double.tryParse(paidAmountController.text) ?? 0;

    final loan = Loan(
      id: DateTime.now().millisecondsSinceEpoch,
      bankName: bankNameController.text,
      totalAmount: totalPayable,
      principalAmount: principal,
      interestPercent: interestPercent,
      monthlyPayment: monthlyPayment,
      months: months,
      startDate: selectedStartDate,
      endDate: endDate,
      bankId: selectedBankId,
      description: descController.text,
      paidAmount: paidAmount,
    );

    await context.read<LoanProvider>().addLoan(loan);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وام ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    bankNameController.dispose();
    principalController.dispose();
    interestPercentController.dispose();
    monthsController.dispose();
    paidAmountController.dispose();
    descController.dispose();
    super.dispose();
  }
}
