import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/loan_model.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({Key? key}) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final bankNameController = TextEditingController();
  final totalAmountController = TextEditingController();
  final monthlyPaymentController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  String _formatDateToJalali(DateTime? date) {
    if (date == null) return '';
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      setState(() => selectedStartDate = picked.toDateTime());
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      setState(() => selectedEndDate = picked.toDateTime());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اضافه کردن وام')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: bankNameController,
              decoration: InputDecoration(
                labelText: 'نام وام/بانک *',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: totalAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'مبلغ کل وام *',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: monthlyPaymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'قسط ماهیانه *',
                prefixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedStartDate == null
                  ? 'انتخاب تاریخ شروع *'
                  : _formatDateToJalali(selectedStartDate),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _pickEndDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedEndDate == null
                  ? 'انتخاب تاریخ پایان *'
                  : _formatDateToJalali(selectedEndDate),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _addLoan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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

  void _addLoan() {
    if (bankNameController.text.isEmpty || totalAmountController.text.isEmpty || monthlyPaymentController.text.isEmpty || selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمام فیلدها الزامی هستند!')));
      return;
    }

    final totalAmount = double.tryParse(totalAmountController.text) ?? 0;
    final monthlyPayment = double.tryParse(monthlyPaymentController.text) ?? 0;

    final loan = Loan(
      bankName: bankNameController.text,
      totalAmount: totalAmount,
      monthlyPayment: monthlyPayment,
      startDate: selectedStartDate!,
      endDate: selectedEndDate!,
      bankId: 0,
      description: descriptionController.text,
    );

    context.read<LoanProvider>().addLoan(loan);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وام اضافه شد ✅')));
  }

  @override
  void dispose() {
    bankNameController.dispose();
    totalAmountController.dispose();
    monthlyPaymentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
